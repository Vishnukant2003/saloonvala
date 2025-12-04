package com.salonvala.salonmanagement.repository;

import com.salonvala.salonmanagement.entity.Invoice;
import com.salonvala.salonmanagement.entity.PaymentTransaction;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PaymentTransactionRepository extends JpaRepository<PaymentTransaction, Long> {

    List<PaymentTransaction> findByInvoice(Invoice invoice);
}
