package com.flash;

import com.fasterxml.jackson.databind.JsonNode;
import com.flash.support.IntegrationTestBase;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.mvc.method.RequestMappingInfo;
import org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.TreeSet;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Swagger UI đọc /v3/api-docs do springdoc sinh từ controller. Test này đảm bảo mọi endpoint /v1/**
 * đều có trong tài liệu, có tag và summary, đồng thời ghi bản api-docs ra target/openapi.json để xem lại.
 */
class OpenApiDocsTest extends IntegrationTestBase {

    @Autowired
    @Qualifier("requestMappingHandlerMapping")
    private RequestMappingHandlerMapping handlerMapping;

    @Test
    void everyEndpointIsDocumentedWithTagAndSummary() throws Exception {
        String json = mockMvc.perform(get("/v3/api-docs")).andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString(StandardCharsets.UTF_8);
        Files.createDirectories(Path.of("target"));
        Files.writeString(Path.of("target/openapi.json"), json);
        JsonNode paths = objectMapper.readTree(json).get("paths");

        TreeSet<String> endpoints = new TreeSet<>();
        for (RequestMappingInfo info : handlerMapping.getHandlerMethods().keySet()) {
            for (String pattern : info.getPatternValues()) {
                if (!pattern.startsWith("/v1/")) {
                    continue;
                }
                for (RequestMethod method : info.getMethodsCondition().getMethods()) {
                    endpoints.add(method.name() + " " + pattern);
                }
            }
        }
        assertThat(endpoints).isNotEmpty();

        List<String> missing = new ArrayList<>();
        List<String> undocumented = new ArrayList<>();
        for (String endpoint : endpoints) {
            String[] parts = endpoint.split(" ");
            JsonNode operation = paths.path(parts[1]).path(parts[0].toLowerCase(Locale.ROOT));
            if (operation.isMissingNode()) {
                missing.add(endpoint);
            } else if (!operation.hasNonNull("summary") || operation.path("tags").isEmpty()) {
                undocumented.add(endpoint);
            }
        }
        assertThat(missing).as("Endpoint không có trên Swagger").isEmpty();
        assertThat(undocumented).as("Endpoint thiếu @Operation(summary) hoặc @Tag").isEmpty();
        assertThat(paths.has("/v1/sync/push")).isTrue();
        assertThat(paths.has("/v1/sync/pull")).isTrue();
        assertThat(paths.has("/v1/sync/content")).isTrue();
    }
}
