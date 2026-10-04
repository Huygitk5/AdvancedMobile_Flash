package com.flash.progress.entity;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.UUID;

/** Khoá chính phức hợp của {@link UserTopicProgress}. */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserTopicProgressId implements Serializable {

    private UUID userId;
    private UUID topicId;
}
