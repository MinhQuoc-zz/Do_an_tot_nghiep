package com.haui.Demotesting.repository;

import com.haui.Demotesting.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface IUserRepository extends JpaRepository<User , Integer> {
    Optional<User> findByEmail(String email);
    Optional<User> findByUsername(String username);
}
