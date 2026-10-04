package com.flash.stats.repository;

import com.flash.stats.entity.DailyStatistic;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface DailyStatisticRepository extends JpaRepository<DailyStatistic, UUID> {

    Optional<DailyStatistic> findByUserIdAndStatDate(UUID userId, LocalDate statDate);

    List<DailyStatistic> findByUserIdAndStatDateBetweenOrderByStatDate(UUID userId, LocalDate from, LocalDate to);

    List<DailyStatistic> findByUserIdOrderByStatDate(UUID userId);

    /** Ngày "có hoạt động" = có ít nhất một sự kiện học hợp lệ (review, bài học hoặc quiz). */
    @Query("select d.statDate from DailyStatistic d where d.userId = :userId and d.statDate <= :upTo "
            + "and (d.cardsReviewed > 0 or d.lessonsCompleted > 0 or d.quizzesCompleted > 0) "
            + "order by d.statDate desc")
    List<LocalDate> findActiveDatesDesc(@Param("userId") UUID userId, @Param("upTo") LocalDate upTo);
}
