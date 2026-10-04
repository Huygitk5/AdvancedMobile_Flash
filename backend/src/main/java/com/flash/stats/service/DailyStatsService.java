package com.flash.stats.service;

import com.flash.stats.entity.DailyStatistic;
import com.flash.stats.repository.DailyStatisticRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.UUID;

/**
 * Dòng daily_statistics của (user, ngày địa phương). Chỉ gọi khi đang giữ khoá dòng users
 * (UserRepository.findActiveForUpdate), nên find-or-create không bị hai request tạo trùng.
 */
@Service
@RequiredArgsConstructor
public class DailyStatsService {

    private final DailyStatisticRepository repository;

    @Transactional(propagation = Propagation.MANDATORY)
    public DailyStatistic forDate(UUID userId, LocalDate date) {
        return repository.findByUserIdAndStatDate(userId, date).orElseGet(() -> {
            DailyStatistic stat = new DailyStatistic();
            stat.setUserId(userId);
            stat.setStatDate(date);
            return repository.save(stat);
        });
    }
}
