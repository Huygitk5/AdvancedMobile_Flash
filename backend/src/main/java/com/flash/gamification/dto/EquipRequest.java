package com.flash.gamification.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;

@Getter
@Setter
@NoArgsConstructor
public class EquipRequest {

    /** Thời điểm bấm trên thiết bị (LWW); null = dùng giờ server. */
    private Instant clientUpdatedAt;
}
