package com.salonvala.salonmanagement.dto.payment;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PayRequest {

    private Long invoiceId;
    private String provider;         // Razorpay, GPay, PhonePe
    private String transactionId;

    private Double amount;
}
