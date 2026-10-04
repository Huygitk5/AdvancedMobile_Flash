package com.flash.sync.service;

import com.flash.sync.repository.SyncOperationRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;

/**
 * Dọn sổ idempotency: op cũ hơn 30 ngày gần như không còn được gửi lại (client giữ op tối đa vài ngày
 * với backoff 30 phút). Nếu vẫn bị gửi lại, các service G4 còn chốt chặn riêng theo id (review log,
 * lesson, attempt, ledger XP) nên không bị cộng hai lần.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class SyncOperationCleanupJob {

    static final Duration RETENTION = Duration.ofDays(30);

    private final SyncOperationRepository repository;

    @Scheduled(cron = "${app.sync.cleanup-cron:0 30 3 * * *}", zone = "UTC")
    @Transactional
    public void purgeOldOperations() {
        int deleted = repository.deleteProcessedBefore(Instant.now().minus(RETENTION));
        if (deleted > 0) {
            log.info("Đã xoá {} dòng sync_operations cũ hơn {} ngày", deleted, RETENTION.toDays());
        }
    }
}
