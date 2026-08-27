package com.ryzo.Taxcompliance.repository;


import com.ryzo.Taxcompliance.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByUsername(String username);

    Optional<User> findByEmail(String email);

    Optional<User> findByTinNumber(String tinNumber);

    boolean existsByUsername(String username);

    boolean existsByEmail(String email);

    boolean existsByTinNumber(String tinNumber);

    @Query("SELECT u FROM User u WHERE u.isActive = true AND (u.username = :login OR u.email = :login)")
    Optional<User> findByUsernameOrEmail(@Param("login") String login);

    long countByIsActiveTrue();

    long countByCreatedAtAfter(LocalDateTime since);

    long countByRole(String role);

    List<User> findByRole(String role);

    List<User> findByIsActive(Boolean isActive);

    List<User> findByRoleAndIsActive(String role, Boolean isActive);

    List<User> findTop10ByOrderByCreatedAtDesc();
}
