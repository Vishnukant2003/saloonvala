package com.salonvala.salonmanagement.service.impl;

import com.salonvala.salonmanagement.entity.AdminLog;
import com.salonvala.salonmanagement.repository.AdminLogRepository;
import com.salonvala.salonmanagement.service.AdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class AdminServiceImpl implements AdminService {

    private final AdminLogRepository adminLogRepository;

    @Autowired
    public AdminServiceImpl(AdminLogRepository adminLogRepository) {
        this.adminLogRepository = adminLogRepository;
    }

    @Override
    public void logAction(Long adminId, String action, String entityType, Long entityId) {
        AdminLog log = new AdminLog();
        log.setAdminId(adminId);
        log.setAction(action);
        log.setEntityType(entityType);
        log.setEntityId(entityId);
        adminLogRepository.save(log);
    }
}
