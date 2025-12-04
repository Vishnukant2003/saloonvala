package com.salonvala.salonmanagement.controller;

import com.salonvala.salonmanagement.dto.common.ApiResponse;
import com.salonvala.salonmanagement.dto.payment.InvoiceResponse;
import com.salonvala.salonmanagement.dto.payment.PayRequest;
import com.salonvala.salonmanagement.dto.payment.PaymentResponse;
import com.salonvala.salonmanagement.entity.Invoice;
import com.salonvala.salonmanagement.entity.PaymentTransaction;
import com.salonvala.salonmanagement.service.InvoiceService;
import com.salonvala.salonmanagement.service.PaymentService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/payment")
@CrossOrigin
public class PaymentController {

    @Autowired
    private InvoiceService invoiceService;

    @Autowired
    private PaymentService paymentService;

    // ----------------------------
    // 📌 1) GET INVOICE INFO
    // ----------------------------
    @GetMapping("/invoice/{invoiceId}")
    public ResponseEntity<?> getInvoice(@PathVariable Long invoiceId) {

        Invoice invoice = invoiceService.getInvoiceById(invoiceId);

        InvoiceResponse response = new InvoiceResponse();
        response.setInvoiceId(invoice.getId());
        response.setAmount(invoice.getAmount());
        response.setTax(invoice.getTax());
        response.setDiscount(invoice.getDiscount());
        response.setTotalAmount(invoice.getTotalAmount());
        response.setPaymentStatus(invoice.getPaymentStatus().name());
        response.setBookingId(invoice.getBooking().getId());

        return ResponseEntity.ok(response);
    }

    // ----------------------------
    // 📌 2) MARK INVOICE AS PAID
    // ----------------------------
    @PostMapping("/mark-paid")
    public ResponseEntity<?> markInvoicePaid(@RequestBody PayRequest payRequest) {

        Invoice updated = invoiceService.markPaid(
                payRequest.getInvoiceId(),
                payRequest.getTransactionId()
        );

        return ResponseEntity.ok(
                new ApiResponse("Payment marked as PAID", updated)
        );
    }

    // ----------------------------
    // 📌 3) CREATE A PAYMENT TRANSACTION
    // ----------------------------
    @PostMapping("/create-transaction")
    public ResponseEntity<?> createPayment(@RequestBody PayRequest payRequest) {

        PaymentTransaction tx = paymentService.createTransaction(
                payRequest.getInvoiceId(),
                payRequest.getProvider(),
                payRequest.getTransactionId(),
                payRequest.getAmount()
        );

        PaymentResponse response = new PaymentResponse();
        response.setId(tx.getId());
        response.setProvider(tx.getProvider());
        response.setTransactionId(tx.getTransactionId());
        response.setAmount(tx.getAmount());
        response.setStatus(tx.getStatus().name());
        response.setMethod(tx.getMethod().name());

        return ResponseEntity.ok(
                new ApiResponse("Payment transaction created", response)
        );
    }
}
