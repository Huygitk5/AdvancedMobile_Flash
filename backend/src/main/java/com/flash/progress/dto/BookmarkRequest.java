package com.flash.progress.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import javax.validation.constraints.NotNull;
import java.time.Instant;
import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
public class BookmarkRequest {

    @NotNull
    private UUID flashcardId;

    /** Thời điểm bấm trên thiết bị; null = dùng giờ server. */
    private Instant clientUpdatedAt;
}
