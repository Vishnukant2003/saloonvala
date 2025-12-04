package com.salonvala.salonmanagement.dto.payment;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PaymentResponse {

    private Long id;
    private String provider;
    private String transactionId;

    private Double amount;
    private String status;
    private String method;
}
