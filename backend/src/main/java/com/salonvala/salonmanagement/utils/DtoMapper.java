package com.salonvala.salonmanagement.utils;

import com.salonvala.salonmanagement.dto.booking.BookingResponse;
import com.salonvala.salonmanagement.dto.booking.QueueStatusResponse;
import com.salonvala.salonmanagement.dto.payment.InvoiceResponse;
import com.salonvala.salonmanagement.dto.payment.PaymentResponse;
import com.salonvala.salonmanagement.dto.salon.SalonResponse;
import com.salonvala.salonmanagement.dto.service.ServiceResponse;
import com.salonvala.salonmanagement.entity.*;

import java.time.format.DateTimeFormatter;

public class DtoMapper {

    private static final DateTimeFormatter ISO = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    // Salon -> SalonResponse
    public static SalonResponse toSalonResponse(Salon s) {
        if (s == null) return null;
        SalonResponse r = new SalonResponse();
        r.setId(s.getId());
        r.setSalonName(s.getSalonName());
        r.setAddress(s.getAddress());
        r.setCity(s.getCity());
        r.setState(s.getState());
        r.setPincode(s.getPincode());
        r.setContactNumber(s.getContactNumber());
        r.setImageUrl(s.getImageUrl());
        r.setApprovalStatus(s.getApprovalStatus() != null ? s.getApprovalStatus().name() : null);
        r.setOpenTime(s.getOpenTime());
        r.setCloseTime(s.getCloseTime());
        r.setOwnerId(s.getOwner() != null ? s.getOwner().getId() : null);
        r.setIsLive(s.getIsLive() != null ? s.getIsLive() : false);
        r.setLatitude(s.getLatitude());
        r.setLongitude(s.getLongitude());
        r.setCategory(s.getCategory());
        r.setEstablishedYear(s.getEstablishedYear());
        r.setDescription(s.getDescription());
        r.setNumberOfStaff(s.getNumberOfStaff());
        r.setSpecialities(s.getSpecialities());
        r.setLanguages(s.getLanguages());
        r.setServiceArea(s.getServiceArea());
        return r;
    }

    // ServiceEntity -> ServiceResponse
    public static ServiceResponse toServiceResponse(ServiceEntity s) {
        if (s == null) return null;
        ServiceResponse r = new ServiceResponse();
        r.setId(s.getId());
        r.setServiceName(s.getServiceName());
        r.setPrice(s.getPrice());
        r.setDurationMinutes(s.getDurationMinutes());
        r.setDescription(s.getDescription());
        r.setCategory(s.getCategory());
        r.setSubCategory(s.getSubCategory());
        return r;
    }

    // Booking -> BookingResponse
    public static BookingResponse toBookingResponse(Booking b) {
        if (b == null) return null;
        BookingResponse r = new BookingResponse();
        r.setBookingId(b.getId());
        r.setQueueNumber(b.getQueueNumber());
        r.setStatus(b.getStatus() != null ? b.getStatus().name() : null);
        r.setSalonName(b.getSalon() != null ? b.getSalon().getSalonName() : null);
        r.setServiceName(b.getService() != null ? b.getService().getServiceName() : null);
        r.setScheduledAt(b.getScheduledAt() != null ? b.getScheduledAt().format(ISO) : null);
        return r;
    }

    // QueueState -> QueueStatusResponse
    public static QueueStatusResponse toQueueStatusResponse(QueueState qs, Integer userQueueNumber, Integer estMinutes) {
        QueueStatusResponse r = new QueueStatusResponse();
        if (qs != null) {
            r.setCurrentServing(qs.getCurrentServingNumber());
            r.setTotalWaiting(qs.getTotalWaiting());
        } else {
            r.setCurrentServing(0);
            r.setTotalWaiting(0);
        }
        r.setUserQueueNumber(userQueueNumber);
        r.setEstimatedMinutes(estMinutes);
        return r;
    }

    // Invoice -> InvoiceResponse
    public static InvoiceResponse toInvoiceResponse(Invoice inv) {
        if (inv == null) return null;
        InvoiceResponse r = new InvoiceResponse();
        r.setInvoiceId(inv.getId());
        r.setAmount(inv.getAmount());
        r.setTax(inv.getTax());
        r.setDiscount(inv.getDiscount());
        r.setTotalAmount(inv.getTotalAmount());
        r.setPaymentStatus(inv.getPaymentStatus() != null ? inv.getPaymentStatus().name() : null);
        r.setBookingId(inv.getBooking() != null ? inv.getBooking().getId() : null);
        return r;
    }

    // PaymentTransaction -> PaymentResponse
    public static PaymentResponse toPaymentResponse(PaymentTransaction tx) {
        if (tx == null) return null;
        PaymentResponse r = new PaymentResponse();
        r.setId(tx.getId());
        r.setProvider(tx.getProvider());
        r.setTransactionId(tx.getTransactionId());
        r.setAmount(tx.getAmount());
        r.setStatus(tx.getStatus() != null ? tx.getStatus().name() : null);
        r.setMethod(tx.getMethod() != null ? tx.getMethod().name() : null);
        return r;
    }
}
