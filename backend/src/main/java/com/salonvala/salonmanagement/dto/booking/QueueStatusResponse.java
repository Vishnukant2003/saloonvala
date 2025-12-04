package com.salonvala.salonmanagement.dto.booking;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class QueueStatusResponse {

    private Integer currentServing;
    private Integer totalWaiting;

    private Integer userQueueNumber;
    private Integer estimatedMinutes;
}
