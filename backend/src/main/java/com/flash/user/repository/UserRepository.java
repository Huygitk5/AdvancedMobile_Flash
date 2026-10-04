package com.flash.user.repository;

import com.flash.user.entity.User;
import com.flash.user.entity.UserStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {

    Optional<User> findByIdAndDeletedAtIsNull(UUID id);

    Optional<User> findByEmailAndDeletedAtIsNull(String email);

    /** Gồm cả user đã xoá; email của user đã xoá được ẩn danh hoá nên không chặn đăng ký lại. */
    boolean existsByEmail(String email);

    @Query("select u from User u where u.deletedAt is null "
            + "and (:status is null or u.status = :status) "
            + "and (:keyword is null or lower(u.email) like lower(concat('%', :keyword, '%')) "
            + "     or lower(u.fullName) like lower(concat('%', :keyword, '%')))")
    Page<User> search(@Param("keyword") String keyword, @Param("status") UserStatus status, Pageable pageable);
}
