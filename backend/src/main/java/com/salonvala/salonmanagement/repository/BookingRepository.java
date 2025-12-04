package com.salonvala.salonmanagement.repository;

import com.salonvala.salonmanagement.entity.Booking;
import com.salonvala.salonmanagement.entity.Salon;
import com.salonvala.salonmanagement.entity.User;
import com.salonvala.salonmanagement.enums.BookingStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface BookingRepository extends JpaRepository<Booking, Long> {

    List<Booking> findByUser(User user);

    List<Booking> findBySalon(Salon salon);

    List<Booking> findBySalonAndStatus(Salon salon, BookingStatus status);

    int countBySalonAndStatus(Salon salon, BookingStatus status);

    List<Booking> findByScheduledAtBetween(LocalDateTime start, LocalDateTime end);
    
    // Find bookings for a salon on a specific date (using custom query to ensure correct filtering)
    @Query("SELECT b FROM Booking b WHERE b.salon = :salon AND b.scheduledAt >= :startOfDay AND b.scheduledAt <= :endOfDay")
    List<Booking> findBookingsBySalonAndDate(
        @Param("salon") Salon salon,
        @Param("startOfDay") LocalDateTime startOfDay,
        @Param("endOfDay") LocalDateTime endOfDay
    );
}
