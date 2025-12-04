package com.salonvala.salonmanagement.service;

import com.salonvala.salonmanagement.entity.Booking;
import com.salonvala.salonmanagement.entity.Salon;
import com.salonvala.salonmanagement.entity.User;
import com.salonvala.salonmanagement.enums.BookingStatus;

import java.time.LocalDateTime;
import java.util.List;

public interface BookingService {
    Booking createBooking(Long salonId, Long serviceId, Long userId, LocalDateTime scheduledAt, Long staffId);
    Booking acceptBooking(Long bookingId, Long ownerId);
    Booking rejectBooking(Long bookingId, Long ownerId, String reason);
    Booking startService(Long bookingId, Long ownerId);
    Booking completeService(Long bookingId, Long ownerId);
    List<Booking> listBookingsBySalonAndStatus(Long salonId, BookingStatus status);
    List<Booking> listBookingsByUser(Long userId);

    // Admin: list all bookings (optionally by status)
    List<Booking> listAllBookings(BookingStatus status);

    // Admin: force cancel a booking
    Booking cancelBookingByAdmin(Long bookingId, Long adminId, String reason);
}
