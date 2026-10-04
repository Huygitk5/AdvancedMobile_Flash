package com.flash.sync.repository;

import com.flash.sync.entity.SyncOperation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.UUID;

public interface SyncOperationRepository extends JpaRepository<SyncOperation, UUID> {

    @Modifying
    @Query("delete from SyncOperation o where o.processedAt < :before")
    int deleteProcessedBefore(@Param("before") Instant before);
}
