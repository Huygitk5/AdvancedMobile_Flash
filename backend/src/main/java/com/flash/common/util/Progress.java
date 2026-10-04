package com.flash.common.util;

public final class Progress {

    private Progress() {
    }

    /** Tỷ lệ 0..1, chia cho 0 thì trả 0. */
    public static double ratio(int done, int total) {
        if (total <= 0) {
            return 0d;
        }
        return Math.min(1d, (double) done / total);
    }
}
