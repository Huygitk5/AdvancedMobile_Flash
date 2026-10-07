package com.flash;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

import java.util.TimeZone;

@SpringBootApplication
@ConfigurationPropertiesScan
public class FlashApplication {

    public static void main(String[] args) {
        // Mọi thời gian trong hệ thống là UTC (DATETIME(3) lưu UTC)
        TimeZone.setDefault(TimeZone.getTimeZone("UTC"));
        SpringApplication.run(FlashApplication.class, args);
    }
}
