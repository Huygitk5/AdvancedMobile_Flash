package com.flash.config;

import com.flash.security.UserPrincipal;
import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import org.springdoc.core.SpringDocUtils;
import org.springframework.context.annotation.Configuration;

@Configuration
@OpenAPIDefinition(
        info = @Info(title = "AdvancedMobile_Flash API", version = "v1",
                description = "REST API cho ứng dụng học từ vựng Flashcard (Offline-First)"),
        security = @SecurityRequirement(name = "bearerAuth"))
@SecurityScheme(name = "bearerAuth", type = SecuritySchemeType.HTTP, scheme = "bearer", bearerFormat = "JWT")
public class OpenApiConfig {

    static {
        // Tham số @CurrentUser lấy từ JWT, không hiển thị trên Swagger như một request param
        SpringDocUtils.getConfig().addRequestWrapperToIgnore(UserPrincipal.class);
    }
}
