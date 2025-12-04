package com.salonvala.salonmanagement.controller;

import com.salonvala.salonmanagement.dto.common.ApiResponse;
import com.salonvala.salonmanagement.dto.payment.InvoiceResponse;
import com.salonvala.salonmanagement.entity.Invoice;
import com.salonvala.salonmanagement.service.InvoiceService;
import com.salonvala.salonmanagement.service.SalonService;
import com.salonvala.salonmanagement.service.BookingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/invoice")
@CrossOrigin
public class InvoiceController {

    @Autowired
    private InvoiceService invoiceService;

    @Autowired
    private BookingService bookingService;

    @Autowired
    private SalonService salonService;

    // Convert to DTO
    private InvoiceResponse toDto(Invoice inv) {
        InvoiceResponse r = new InvoiceResponse();
        r.setInvoiceId(inv.getId());
        r.setAmount(inv.getAmount());
        r.setTax(inv.getTax());
        r.setDiscount(inv.getDiscount());
        r.setTotalAmount(inv.getTotalAmount());
        r.setPaymentStatus(inv.getPaymentStatus().name());
        r.setBookingId(inv.getBooking().getId());
        return r;
    }

    // ---------------------------------------------
    // 1️⃣ Get invoice by invoice ID
    // ---------------------------------------------
    @GetMapping("/{invoiceId}")
    public ResponseEntity<?> getInvoice(@PathVariable Long invoiceId) {
        Invoice inv = invoiceService.getInvoiceById(invoiceId);
        return ResponseEntity.ok(toDto(inv));
    }

    // ---------------------------------------------
    // 2️⃣ Get invoice by Booking ID
    // ---------------------------------------------
    @GetMapping("/booking/{bookingId}")
    public ResponseEntity<?> getInvoiceByBooking(@PathVariable Long bookingId) {
        Invoice inv = invoiceService.getInvoiceByBooking(bookingId);
        return ResponseEntity.ok(toDto(inv));
    }

    // ---------------------------------------------
    // 3️⃣ List invoices of a User (User App)
    // ---------------------------------------------
    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getUserInvoices(@PathVariable Long userId) {

        List<InvoiceResponse> list =
                invoiceService.listInvoicesByUser(userId)
                        .stream()
                        .map(this::toDto)
                        .collect(Collectors.toList());

        return ResponseEntity.ok(list);
    }

    // ---------------------------------------------
    // 4️⃣ List invoices for a Salon (Owner App)
    // ---------------------------------------------
    @GetMapping("/salon/{salonId}")
    public ResponseEntity<?> getSalonInvoices(@PathVariable Long salonId) {

        List<InvoiceResponse> list =
                invoiceService.listInvoicesBySalon(salonId)
                        .stream()
                        .map(this::toDto)
                        .collect(Collectors.toList());

        return ResponseEntity.ok(list);
    }
}
