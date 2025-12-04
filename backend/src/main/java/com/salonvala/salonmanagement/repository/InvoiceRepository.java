package com.salonvala.salonmanagement.repository;

import com.salonvala.salonmanagement.entity.Booking;
import com.salonvala.salonmanagement.entity.Invoice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface InvoiceRepository extends JpaRepository<Invoice, Long> {

    Optional<Invoice> findByBookingId(Long bookingId);

    List<Invoice> findByBookingUserId(Long userId);

    List<Invoice> findByBookingSalonId(Long salonId);
}
