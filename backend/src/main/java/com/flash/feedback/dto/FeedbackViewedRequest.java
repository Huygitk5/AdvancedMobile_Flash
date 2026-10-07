package com.flash.feedback.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.constraints.NotNull;

/** Admin đánh dấu đã xem / chưa xem. */
@Getter
@Setter
@NoArgsConstructor
public class FeedbackViewedRequest {

    @NotNull
    private Boolean isViewed;
}
