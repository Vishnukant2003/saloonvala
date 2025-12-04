package com.salonvala.salonmanagement.dto.payment;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class InvoiceResponse {

    private Long invoiceId;
    private Double amount;

    private Double tax;
    private Double discount;
    private Double totalAmount;

    private String paymentStatus;
    private Long bookingId;
}
