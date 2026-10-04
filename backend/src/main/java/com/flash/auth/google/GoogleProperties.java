package com.flash.auth.google;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@ConfigurationProperties(prefix = "app.google")
public class GoogleProperties {

    /** OAuth client id (Android, iOS, Web) được chấp nhận làm "aud" của idToken. */
    private List<String> clientIds = new ArrayList<>();
}
