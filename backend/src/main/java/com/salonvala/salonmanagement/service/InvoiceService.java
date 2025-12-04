package com.salonvala.salonmanagement.service;

import com.salonvala.salonmanagement.entity.Invoice;

import java.util.List;

public interface InvoiceService {

    Invoice getInvoiceById(Long id);

    Invoice getInvoiceByBooking(Long bookingId);

    List<Invoice> listInvoicesByUser(Long userId);

    List<Invoice> listInvoicesBySalon(Long salonId);

    Invoice markPaid(Long invoiceId, String providerTxnId);
}
