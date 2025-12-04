package com.salonvala.salonmanagement.service;

import com.salonvala.salonmanagement.entity.PaymentTransaction;

public interface PaymentService {
    PaymentTransaction createTransaction(Long invoiceId, String provider, String txnId, double amount);
}
