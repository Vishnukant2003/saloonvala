package com.salonvala.salonmanagement.entity;

import com.salonvala.salonmanagement.enums.PaymentStatus;
import jakarta.persistence.*;
import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "invoices")
public class Invoice {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Double amount;

    private Double tax;

    private Double discount;

    private Double totalAmount;

    private String invoicePdfUrl;

    @Enumerated(EnumType.STRING)
    private PaymentStatus paymentStatus = PaymentStatus.PENDING;

    @OneToOne
    @JoinColumn(name = "booking_id")
    private Booking booking;
}
