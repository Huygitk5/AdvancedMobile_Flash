package com.flash.auth.repository;

import com.flash.auth.entity.AuthProviderType;
import com.flash.auth.entity.UserAuthProvider;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;
import java.util.UUID;

public interface UserAuthProviderRepository extends JpaRepository<UserAuthProvider, UUID> {

    Optional<UserAuthProvider> findByProviderAndProviderUserId(AuthProviderType provider, String providerUserId);

    @Modifying
    @Query("delete from UserAuthProvider p where p.userId = :userId")
    int deleteByUserId(@Param("userId") UUID userId);
}
