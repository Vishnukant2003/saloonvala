package com.salonvala.salonmanagement.repository;

import com.salonvala.salonmanagement.entity.User;
import com.salonvala.salonmanagement.enums.Role;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByMobile(String mobile);

    boolean existsByMobile(String mobile);

    List<User> findByRole(Role role);
    long countByRole(Role role);

}
