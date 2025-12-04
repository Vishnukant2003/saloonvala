package com.salonvala.salonmanagement.service.impl;

import com.salonvala.salonmanagement.entity.Invoice;
import com.salonvala.salonmanagement.entity.PaymentTransaction;
import com.salonvala.salonmanagement.enums.PaymentMethod;
import com.salonvala.salonmanagement.enums.PaymentStatus;
import com.salonvala.salonmanagement.repository.InvoiceRepository;
import com.salonvala.salonmanagement.repository.PaymentTransactionRepository;
import com.salonvala.salonmanagement.repository.BookingRepository;
import com.salonvala.salonmanagement.service.InvoiceService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class InvoiceServiceImpl implements InvoiceService {

    private final InvoiceRepository invoiceRepository;
    private final PaymentTransactionRepository paymentTransactionRepository;
    private final BookingRepository bookingRepository;

    @Autowired
    public InvoiceServiceImpl(InvoiceRepository invoiceRepository,
                              PaymentTransactionRepository paymentTransactionRepository,
                              BookingRepository bookingRepository) {

        this.invoiceRepository = invoiceRepository;
        this.paymentTransactionRepository = paymentTransactionRepository;
        this.bookingRepository = bookingRepository;
    }

    // ------------------------------------------------------------
    // 1️⃣ Get invoice by ID
    // ------------------------------------------------------------
    @Override
    public Invoice getInvoiceById(Long id) {
        return invoiceRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Invoice not found"));
    }

    // ------------------------------------------------------------
    // 2️⃣ Get invoice by Booking ID
    // ------------------------------------------------------------
    @Override
    public Invoice getInvoiceByBooking(Long bookingId) {
        return invoiceRepository.findByBookingId(bookingId)
                .orElseThrow(() -> new IllegalArgumentException("Invoice not found for bookingId: " + bookingId));
    }

    // ------------------------------------------------------------
    // 3️⃣ List invoices by User
    // ------------------------------------------------------------
    @Override
    public List<Invoice> listInvoicesByUser(Long userId) {
        return invoiceRepository.findByBookingUserId(userId);
    }

    // ------------------------------------------------------------
    // 4️⃣ List invoices by Salon (Owner App)
    // ------------------------------------------------------------
    @Override
    public List<Invoice> listInvoicesBySalon(Long salonId) {
        return invoiceRepository.findByBookingSalonId(salonId);
    }

    // ------------------------------------------------------------
    // 5️⃣ Mark Invoice as PAID + create transaction record
    // ------------------------------------------------------------
    @Override
    @Transactional
    public Invoice markPaid(Long invoiceId, String providerTxnId) {

        Invoice invoice = getInvoiceById(invoiceId);
        invoice.setPaymentStatus(PaymentStatus.PAID);

        Invoice saved = invoiceRepository.save(invoice);

        // Create payment transaction record
        PaymentTransaction tx = new PaymentTransaction();
        tx.setInvoice(saved);
        tx.setTransactionId(providerTxnId);
        tx.setAmount(saved.getTotalAmount());
        tx.setProvider("RAZORPAY");
        tx.setMethod(PaymentMethod.RAZORPAY);
        tx.setStatus(PaymentStatus.PAID);

        paymentTransactionRepository.save(tx);

        return saved;
    }
}
