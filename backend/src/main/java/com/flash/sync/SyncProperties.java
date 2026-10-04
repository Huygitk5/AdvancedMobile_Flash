package com.flash.sync;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Getter
@Setter
@ConfigurationProperties(prefix = "app.sync")
public class SyncProperties {

    /** Số request /v1/sync/** tối đa mỗi phút cho mỗi user. */
    private int rateLimitPerMinute = 30;
}
