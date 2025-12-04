package com.salonvala.salonmanagement.service.impl;

import com.salonvala.salonmanagement.entity.*;
import com.salonvala.salonmanagement.enums.BookingStatus;
import com.salonvala.salonmanagement.repository.*;
import com.salonvala.salonmanagement.service.BookingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;

@Service
public class BookingServiceImpl implements BookingService {

    private final BookingRepository bookingRepository;
    private final SalonRepository salonRepository;
    private final ServiceRepository serviceRepository;
    private final UserRepository userRepository;
    private final StaffRepository staffRepository;
    private final QueueStateRepository queueStateRepository;
    private final InvoiceRepository invoiceRepository;

    @Autowired
    public BookingServiceImpl(BookingRepository bookingRepository,
                              SalonRepository salonRepository,
                              ServiceRepository serviceRepository,
                              UserRepository userRepository,
                              StaffRepository staffRepository,
                              QueueStateRepository queueStateRepository,
                              InvoiceRepository invoiceRepository) {
        this.bookingRepository = bookingRepository;
        this.salonRepository = salonRepository;
        this.serviceRepository = serviceRepository;
        this.userRepository = userRepository;
        this.staffRepository = staffRepository;
        this.queueStateRepository = queueStateRepository;
        this.invoiceRepository = invoiceRepository;
    }

    private int nextQueueNumberForSalon(Salon salon, LocalDateTime scheduledAt) {
        // Calculate queue number based on the scheduled date's active bookings only
        LocalDateTime startOfDay = scheduledAt.toLocalDate().atStartOfDay();
        LocalDateTime endOfDay = scheduledAt.toLocalDate().atTime(23, 59, 59, 999999999);
        
        // Get all bookings for the scheduled date (not all bookings, only for this specific day)
        List<Booking> dayBookings = bookingRepository.findBookingsBySalonAndDate(salon, startOfDay, endOfDay);
        
        // Count only active bookings (REQUESTED, ACCEPTED, IN_SERVICE) for this specific day
        long activeBookingsCount = dayBookings.stream()
                .filter(b -> {
                    BookingStatus status = b.getStatus();
                    return status == BookingStatus.REQUESTED || 
                           status == BookingStatus.ACCEPTED || 
                           status == BookingStatus.IN_SERVICE;
                })
                .count();
        
        // Queue number is the count of active bookings for this day + 1
        // This gives the actual position in the queue for this specific day
        return (int) activeBookingsCount + 1;
    }

    @Override
    @Transactional
    public Booking createBooking(Long salonId, Long serviceId, Long userId, LocalDateTime scheduledAt, Long staffId) {
        Salon salon = salonRepository.findById(salonId)
                .orElseThrow(() -> new IllegalArgumentException("Salon not found"));
        ServiceEntity service = serviceRepository.findById(serviceId)
                .orElseThrow(() -> new IllegalArgumentException("Service not found"));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        Booking booking = new Booking();
        booking.setSalon(salon);
        booking.setService(service);
        booking.setUser(user);
        booking.setScheduledAt(scheduledAt);
        booking.setBookingTime(LocalDateTime.now());
        booking.setStatus(BookingStatus.REQUESTED);
        booking.setQueueNumber(nextQueueNumberForSalon(salon, scheduledAt));
        
        // Set staff if provided
        if (staffId != null) {
            Staff staff = staffRepository.findById(staffId)
                    .orElseThrow(() -> new IllegalArgumentException("Staff not found"));
            booking.setStaff(staff);
        }

        Booking saved = bookingRepository.save(booking);

        // update queue state
        QueueState qs = queueStateRepository.findBySalon(salon).orElseGet(() -> {
            QueueState ns = new QueueState();
            ns.setSalon(salon);
            ns.setCurrentServingNumber(0);
            ns.setTotalWaiting(0);
            return ns;
        });
        qs.setTotalWaiting((qs.getTotalWaiting() == null ? 0 : qs.getTotalWaiting()) + 1);
        queueStateRepository.save(qs);

        return saved;
    }

    @Override
    @Transactional
    public Booking acceptBooking(Long bookingId, Long ownerId) {
        Booking b = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));
        // optional: validate ownerId matches salon.owner.id
        b.setStatus(BookingStatus.ACCEPTED);
        return bookingRepository.save(b);
    }

    @Override
    @Transactional
    public Booking rejectBooking(Long bookingId, Long ownerId, String reason) {
        Booking b = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));
        b.setStatus(BookingStatus.REJECTED);
        b.setRejectionReason(reason != null ? reason : "");
        // decrement waiting if it was REQUESTED before
        Salon salon = b.getSalon();
        QueueState qs = queueStateRepository.findBySalon(salon).orElse(null);
        if (qs != null && qs.getTotalWaiting() != null && qs.getTotalWaiting() > 0) {
            qs.setTotalWaiting(qs.getTotalWaiting() - 1);
            queueStateRepository.save(qs);
        }
        return bookingRepository.save(b);
    }

    @Override
    @Transactional
    public Booking startService(Long bookingId, Long ownerId) {
        Booking b = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));

        b.setStatus(BookingStatus.IN_SERVICE);

        // increment currentServingNumber and decrement waiting
        Salon salon = b.getSalon();
        QueueState qs = queueStateRepository.findBySalon(salon).orElseGet(() -> {
            QueueState ns = new QueueState();
            ns.setSalon(salon);
            ns.setCurrentServingNumber(0);
            ns.setTotalWaiting(0);
            return ns;
        });
        qs.setCurrentServingNumber((qs.getCurrentServingNumber() == null ? 0 : qs.getCurrentServingNumber()) + 1);
        if (qs.getTotalWaiting() != null && qs.getTotalWaiting() > 0) {
            qs.setTotalWaiting(qs.getTotalWaiting() - 1);
        }
        queueStateRepository.save(qs);

        return bookingRepository.save(b);
    }

    @Override
    @Transactional
    public Booking completeService(Long bookingId, Long ownerId) {
        Booking b = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));

        b.setStatus(BookingStatus.COMPLETED);
        Booking saved = bookingRepository.save(b);

        // generate invoice (simple)
        Invoice invoice = new Invoice();
        invoice.setBooking(saved);
        double amount = (saved.getService() != null && saved.getService().getPrice() != null)
                ? saved.getService().getPrice() : 0.0;
        double tax = amount * 0.18; // 18% GST default
        invoice.setAmount(amount);
        invoice.setTax(tax);
        invoice.setDiscount(0.0);
        invoice.setTotalAmount(amount + tax);
        invoice.setPaymentStatus(com.salonvala.salonmanagement.enums.PaymentStatus.PENDING);
        invoiceRepository.save(invoice);

        return saved;
    }

    @Override
    public List<Booking> listBookingsBySalonAndStatus(Long salonId, BookingStatus status) {
        Salon salon = salonRepository.findById(salonId)
                .orElseThrow(() -> new IllegalArgumentException("Salon not found"));
        
        // If status is null, return all bookings for the salon
        if (status == null) {
            return bookingRepository.findBySalon(salon);
        }
        
        return bookingRepository.findBySalonAndStatus(salon, status);
    }

    @Override
    public List<Booking> listBookingsByUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        return bookingRepository.findByUser(user);
    }

    // -------------------------------------
    // Admin helpers
    // -------------------------------------

    @Override
    public List<Booking> listAllBookings(BookingStatus status) {
        if (status == null) {
            return bookingRepository.findAll();
        }
        return bookingRepository.findAll()
                .stream()
                .filter(b -> b.getStatus() == status)
                .toList();
    }

    @Override
    @Transactional
    public Booking cancelBookingByAdmin(Long bookingId, Long adminId, String reason) {
        Booking b = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new IllegalArgumentException("Booking not found"));

        // Only cancel active bookings
        if (b.getStatus() == BookingStatus.COMPLETED || b.getStatus() == BookingStatus.CANCELLED) {
            return b;
        }

        b.setStatus(BookingStatus.CANCELLED);
        if (reason != null && !reason.isEmpty()) {
            b.setRejectionReason(reason);
        }

        // Update queue state similar to rejection
        Salon salon = b.getSalon();
        QueueState qs = queueStateRepository.findBySalon(salon).orElse(null);
        if (qs != null && qs.getTotalWaiting() != null && qs.getTotalWaiting() > 0) {
            qs.setTotalWaiting(qs.getTotalWaiting() - 1);
            queueStateRepository.save(qs);
        }

        return bookingRepository.save(b);
    }
}
