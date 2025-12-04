package com.salonvala.salonmanagement.service;

public interface AdminService {
    void logAction(Long adminId, String action, String entityType, Long entityId);
}
