package com.flash.common.util;

import java.util.Locale;

public final class Emails {

    private Emails() {
    }

    /** Email luôn được lưu và so sánh ở dạng chữ thường, bỏ khoảng trắng. */
    public static String normalize(String email) {
        return email == null ? null : email.trim().toLowerCase(Locale.ROOT);
    }
}
