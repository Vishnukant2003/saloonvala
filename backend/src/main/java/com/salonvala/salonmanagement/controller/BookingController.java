package com.salonvala.salonmanagement.controller;

import com.salonvala.salonmanagement.dto.booking.BookingRequest;
import com.salonvala.salonmanagement.dto.booking.BookingResponse;
import com.salonvala.salonmanagement.dto.booking.QueueStatusResponse;
import com.salonvala.salonmanagement.dto.common.ApiResponse;
import com.salonvala.salonmanagement.entity.Booking;
import com.salonvala.salonmanagement.entity.QueueState;
import com.salonvala.salonmanagement.entity.Salon;
import com.salonvala.salonmanagement.enums.BookingStatus;
import com.salonvala.salonmanagement.repository.QueueStateRepository;
import com.salonvala.salonmanagement.service.BookingService;
import com.salonvala.salonmanagement.service.SalonService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/booking")
@CrossOrigin
public class BookingController {

    @Autowired
    private BookingService bookingService;

    @Autowired
    private SalonService salonService;

    @Autowired
    private QueueStateRepository queueStateRepository;

    // Convert Entity -> DTO
    private BookingResponse toDto(Booking b) {
        BookingResponse r = new BookingResponse();
        r.setBookingId(b.getId());
        r.setQueueNumber(b.getQueueNumber());
        r.setStatus(b.getStatus().name());
        r.setSalonName(b.getSalon().getSalonName());
        r.setServiceName(b.getService().getServiceName());
        r.setScheduledAt(b.getScheduledAt() != null ? b.getScheduledAt().toString() : null);
        
        // Add service price and duration
        if (b.getService() != null) {
            r.setServicePrice(b.getService().getPrice());
            r.setServiceDurationMinutes(b.getService().getDurationMinutes());
        }
        
        // Add user information
        if (b.getUser() != null) {
            r.setUserId(b.getUser().getId());
            r.setUserName(b.getUser().getName());
            r.setUserMobile(b.getUser().getMobile());
        }
        
        // Add staff information
        if (b.getStaff() != null) {
            r.setStaffId(b.getStaff().getId());
            r.setStaffName(b.getStaff().getName());
        }
        
        // Add rejection reason if booking is rejected
        r.setRejectionReason(b.getRejectionReason());
        
        return r;
    }

    // -----------------------------------------
    // 1️⃣ Create Booking (User App)
    // -----------------------------------------
    @PostMapping("/create")
    public ResponseEntity<?> createBooking(@RequestBody BookingRequest req) {

        LocalDateTime scheduledTime =
                (req.getScheduledAt() == null || req.getScheduledAt().isEmpty())
                        ? LocalDateTime.now()
                        : LocalDateTime.parse(req.getScheduledAt());

        Booking booking = bookingService.createBooking(
                req.getSalonId(),
                req.getServiceId(),
                req.getUserId(),
                scheduledTime,
                req.getStaffId()  // Pass staffId if provided
        );

        return ResponseEntity.ok(
                new ApiResponse("Booking created successfully", toDto(booking))
        );
    }

    // -----------------------------------------
    // 2️⃣ Owner Accept Booking
    // -----------------------------------------
    @PostMapping("/accept/{bookingId}")
    public ResponseEntity<?> acceptBooking(
            @PathVariable Long bookingId,
            @RequestParam Long ownerId) {

        Booking booking = bookingService.acceptBooking(bookingId, ownerId);

        return ResponseEntity.ok(
                new ApiResponse("Booking accepted", toDto(booking))
        );
    }

    // -----------------------------------------
    // 3️⃣ Owner Reject Booking
    // -----------------------------------------
    @PostMapping("/reject/{bookingId}")
    public ResponseEntity<?> rejectBooking(
            @PathVariable Long bookingId,
            @RequestParam Long ownerId,
            @RequestParam(required = false) String reason) {

        Booking booking = bookingService.rejectBooking(bookingId, ownerId, reason);

        return ResponseEntity.ok(
                new ApiResponse("Booking rejected", toDto(booking))
        );
    }

    // -----------------------------------------
    // 4️⃣ Owner Starts Service
    // -----------------------------------------
    @PostMapping("/start/{bookingId}")
    public ResponseEntity<?> startService(
            @PathVariable Long bookingId,
            @RequestParam Long ownerId) {

        Booking booking = bookingService.startService(bookingId, ownerId);

        return ResponseEntity.ok(
                new ApiResponse("Service started", toDto(booking))
        );
    }

    // -----------------------------------------
    // 5️⃣ Owner Completes Service
    // (Automates invoice creation)
    // -----------------------------------------
    @PostMapping("/complete/{bookingId}")
    public ResponseEntity<?> completeService(
            @PathVariable Long bookingId,
            @RequestParam Long ownerId) {

        Booking booking = bookingService.completeService(bookingId, ownerId);

        return ResponseEntity.ok(
                new ApiResponse("Service completed", toDto(booking))
        );
    }

    // -----------------------------------------
    // 6️⃣ List Bookings of a User
    // -----------------------------------------
    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getBookingsByUser(@PathVariable Long userId) {

        List<BookingResponse> list = bookingService.listBookingsByUser(userId)
                .stream()
                .map(this::toDto)
                .collect(Collectors.toList());

        return ResponseEntity.ok(list);
    }

    // -----------------------------------------
    // 7️⃣ List Bookings of a Salon by Status
    // Owner App dashboard
    // -----------------------------------------
    @GetMapping("/salon/{salonId}")
    public ResponseEntity<?> getBookingsBySalon(
            @PathVariable Long salonId,
            @RequestParam(required = false) String status) {

        BookingStatus bookingStatus = null;

        if (status != null) {
            bookingStatus = BookingStatus.valueOf(status.toUpperCase());
        }

        List<Booking> bookings =
                bookingService.listBookingsBySalonAndStatus(salonId, bookingStatus);

        List<BookingResponse> list = bookings.stream()
                .map(this::toDto)
                .collect(Collectors.toList());

        return ResponseEntity.ok(list);
    }

    // -----------------------------------------
    // 8️⃣ Queue / Waiting Status (User App)
    // -----------------------------------------
    @GetMapping("/queue-status/{salonId}/{userId}")
    public ResponseEntity<?> getQueueStatus(
            @PathVariable Long salonId,
            @PathVariable Long userId) {

        Salon salon = salonService.getSalonById(salonId);

        QueueState queueState = queueStateRepository.findBySalon(salon).orElse(null);

        // User's queue number
        int userQueueNumber = bookingService.listBookingsByUser(userId).stream()
                .filter(b -> b.getSalon().getId().equals(salonId) &&
                        (b.getStatus() == BookingStatus.REQUESTED ||
                                b.getStatus() == BookingStatus.ACCEPTED ||
                                b.getStatus() == BookingStatus.IN_SERVICE))
                .map(Booking::getQueueNumber)
                .min(Integer::compareTo)
                .orElse(0);

        // Estimate time: each service takes approx 30 MIN
        int estimatedMin = 0;
        if (queueState != null && userQueueNumber > 0) {
            int waitingAhead = userQueueNumber - queueState.getCurrentServingNumber();
            estimatedMin = Math.max(0, waitingAhead * 30);
        }

        QueueStatusResponse response =
                new QueueStatusResponse();

        if (queueState != null) {
            response.setCurrentServing(queueState.getCurrentServingNumber());
            response.setTotalWaiting(queueState.getTotalWaiting());
        } else {
            response.setCurrentServing(0);
            response.setTotalWaiting(0);
        }

        response.setUserQueueNumber(userQueueNumber);
        response.setEstimatedMinutes(estimatedMin);

        return ResponseEntity.ok(response);
    }
}
