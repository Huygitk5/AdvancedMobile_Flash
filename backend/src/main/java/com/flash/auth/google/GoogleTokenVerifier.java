package com.flash.auth.google;

public interface GoogleTokenVerifier {

    /**
     * Xác minh chữ ký, issuer, audience và hạn của idToken.
     *
     * @throws com.flash.common.BusinessException INVALID_TOKEN nếu token không hợp lệ
     */
    GoogleUserInfo verify(String idToken);
}
