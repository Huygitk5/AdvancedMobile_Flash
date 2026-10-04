package com.flash.auth.google;

import com.flash.common.BusinessException;
import com.flash.common.ErrorCode;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Component
public class GoogleApiTokenVerifier implements GoogleTokenVerifier {

    /** null khi chưa cấu hình app.google.client-ids. */
    private final GoogleIdTokenVerifier verifier;

    public GoogleApiTokenVerifier(GoogleProperties properties) {
        List<String> clientIds = properties.getClientIds().stream()
                .filter(StringUtils::hasText)
                .map(String::trim)
                .collect(Collectors.toList());
        if (clientIds.isEmpty()) {
            log.warn("Chưa cấu hình app.google.client-ids, POST /v1/auth/google sẽ luôn bị từ chối");
            this.verifier = null;
        } else {
            this.verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(), GsonFactory.getDefaultInstance())
                    .setAudience(clientIds)
                    .build();
        }
    }

    @Override
    public GoogleUserInfo verify(String idToken) {
        if (verifier == null) {
            throw new BusinessException(ErrorCode.INVALID_TOKEN, "Google Sign-In chưa được cấu hình trên server");
        }
        GoogleIdToken token;
        try {
            token = verifier.verify(idToken);
        } catch (GeneralSecurityException | IOException | IllegalArgumentException e) {
            log.debug("Verify Google idToken lỗi: {}", e.getMessage());
            token = null;
        }
        if (token == null) {
            throw new BusinessException(ErrorCode.INVALID_TOKEN, "idToken Google không hợp lệ");
        }
        GoogleIdToken.Payload payload = token.getPayload();
        return new GoogleUserInfo(
                payload.getSubject(),
                payload.getEmail(),
                Boolean.TRUE.equals(payload.getEmailVerified()),
                (String) payload.get("name"),
                (String) payload.get("picture"));
    }
}
