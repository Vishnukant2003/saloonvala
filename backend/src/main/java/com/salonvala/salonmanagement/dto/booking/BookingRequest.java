package com.salonvala.salonmanagement.dto.booking;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BookingRequest {

    private Long salonId;
    private Long serviceId;
    private Long userId;
    private Long staffId;  // Optional - selected staff for the booking

    private String scheduledAt;   // ISO Date-Time String
}
