package com.salonvala.salonmanagement.repository;

import com.salonvala.salonmanagement.entity.AdminLog;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AdminLogRepository extends JpaRepository<AdminLog, Long> {
}
