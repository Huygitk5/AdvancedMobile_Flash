package com.flash.feedback.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.constraints.NotBlank;

/** Sửa nội dung feedback (chỉ khi chưa được admin xem). */
@Getter
@Setter
@NoArgsConstructor
public class FeedbackUpdateRequest {

    @NotBlank
    private String content;
}
