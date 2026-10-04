package com.flash.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.flash.common.ErrorCode;
import com.flash.common.JsonErrorWriter;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/** Trả 401 dạng JSON envelope thay vì trang lỗi mặc định. */
@Component
@RequiredArgsConstructor
public class RestAuthenticationEntryPoint implements AuthenticationEntryPoint {

    private final ObjectMapper objectMapper;

    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response,
                         AuthenticationException authException) throws IOException {
        JsonErrorWriter.write(response, objectMapper, ErrorCode.UNAUTHORIZED);
    }
}
