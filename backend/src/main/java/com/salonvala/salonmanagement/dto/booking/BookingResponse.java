package com.salonvala.salonmanagement.dto.booking;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BookingResponse {

    private Long bookingId;
    private Integer queueNumber;
    private String status;

    private String salonName;
    private String serviceName;
    private Double servicePrice;  // Service price
    private Integer serviceDurationMinutes;  // Service duration in minutes
    
    private Long userId;  // Customer user ID
    private String userName;  // Customer name who made the booking
    private String userMobile;  // Customer mobile
    
    private Long staffId;  // Selected staff ID
    private String staffName;  // Selected staff name

    private String scheduledAt;
    private String rejectionReason;  // Reason for rejection if booking is rejected
}
