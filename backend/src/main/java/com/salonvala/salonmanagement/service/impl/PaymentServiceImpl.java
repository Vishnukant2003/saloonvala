package com.salonvala.salonmanagement.service.impl;

import com.salonvala.salonmanagement.entity.Invoice;
import com.salonvala.salonmanagement.entity.PaymentTransaction;
import com.salonvala.salonmanagement.enums.PaymentMethod;
import com.salonvala.salonmanagement.enums.PaymentStatus;
import com.salonvala.salonmanagement.repository.InvoiceRepository;
import com.salonvala.salonmanagement.repository.PaymentTransactionRepository;
import com.salonvala.salonmanagement.service.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PaymentServiceImpl implements PaymentService {

    private final PaymentTransactionRepository paymentTransactionRepository;
    private final InvoiceRepository invoiceRepository;

    @Autowired
    public PaymentServiceImpl(PaymentTransactionRepository paymentTransactionRepository,
                              InvoiceRepository invoiceRepository) {
        this.paymentTransactionRepository = paymentTransactionRepository;
        this.invoiceRepository = invoiceRepository;
    }

    @Override
    @Transactional
    public PaymentTransaction createTransaction(Long invoiceId, String provider, String txnId, double amount) {
        Invoice invoice = invoiceRepository.findById(invoiceId)
                .orElseThrow(() -> new IllegalArgumentException("Invoice not found"));

        PaymentTransaction tx = new PaymentTransaction();
        tx.setInvoice(invoice);
        tx.setProvider(provider);
        tx.setTransactionId(txnId);
        tx.setAmount(amount);
        tx.setStatus(PaymentStatus.PAID); // or PENDING based on verification
        tx.setMethod(PaymentMethod.RAZORPAY); // adjust if needed

        paymentTransactionRepository.save(tx);

        // update invoice
        invoice.setPaymentStatus(com.salonvala.salonmanagement.enums.PaymentStatus.PAID);
        invoiceRepository.save(invoice);

        return tx;
    }
}
