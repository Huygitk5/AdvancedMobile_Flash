package com.flash.sync.repository;

import com.flash.sync.entity.SyncOperation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface SyncOperationRepository extends JpaRepository<SyncOperation, UUID> {
}
