package com.flash.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;

/** Bật các job @Scheduled (VD: dọn sync_operations). */
@Configuration
@EnableScheduling
public class SchedulingConfig {
}
