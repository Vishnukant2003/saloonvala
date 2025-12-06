package com.salonvala.salonmanagement.controller;

import com.salonvala.salonmanagement.dto.common.ApiResponse;
import com.salonvala.salonmanagement.entity.Salon;
import com.salonvala.salonmanagement.enums.Role;
import com.salonvala.salonmanagement.enums.BookingStatus;
import com.salonvala.salonmanagement.enums.SalonApprovalStatus;
import com.salonvala.salonmanagement.repository.SalonRepository;
import com.salonvala.salonmanagement.repository.UserRepository;
import com.salonvala.salonmanagement.service.AdminService;
import com.salonvala.salonmanagement.service.SalonService;
import com.salonvala.salonmanagement.service.UserService;
import com.salonvala.salonmanagement.service.BookingService;
import com.salonvala.salonmanagement.repository.InvoiceRepository;
import com.salonvala.salonmanagement.repository.StaffRepository;
import com.salonvala.salonmanagement.utils.DtoMapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin
public class AdminController {

    @Autowired
    private SalonService salonService;

    @Autowired
    private AdminService adminService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SalonRepository salonRepository;

    @Autowired
    private UserService userService;

    @Autowired
    private BookingService bookingService;

    @Autowired
    private InvoiceRepository invoiceRepository;

    @Autowired
    private StaffRepository staffRepository;

    // -------------------------------------------
    // 1️⃣ List Salons by Status
    // -------------------------------------------
    @GetMapping("/salons")
    public ResponseEntity<?> listByStatus(@RequestParam(required = false) String status) {

        List<Salon> salons;

        if (status == null) {
            salons = salonRepository.findAll();
        } else {
            SalonApprovalStatus st = SalonApprovalStatus.valueOf(status.toUpperCase());
            salons = salonRepository.findByApprovalStatus(st);
        }

        List<?> list = salons.stream()
                .map(DtoMapper::toSalonResponse)
                .collect(Collectors.toList());

        return ResponseEntity.ok(new ApiResponse("Salon List", list));
    }

    // -------------------------------------------
    // 2️⃣ Approve Salon
    // -------------------------------------------
    @PostMapping("/salon/approve/{id}")
    public ResponseEntity<?> approve(@PathVariable Long id, @RequestParam Long adminId) {

        Salon s = salonService.approveSalon(id);

        adminService.logAction(adminId, "APPROVE_SALON", "SALON", id);

        return ResponseEntity.ok(new ApiResponse("Salon approved", DtoMapper.toSalonResponse(s)));
    }

    // -------------------------------------------
    // 3️⃣ Reject Salon
    // -------------------------------------------
    @PostMapping("/salon/reject/{id}")
    public ResponseEntity<?> reject(
            @PathVariable Long id,
            @RequestParam Long adminId,
            @RequestParam(required = false) String reason) {

        Salon s = salonService.rejectSalon(id, reason == null ? "" : reason);

        adminService.logAction(adminId, "REJECT_SALON", "SALON", id);

        return ResponseEntity.ok(new ApiResponse("Salon rejected", DtoMapper.toSalonResponse(s)));
    }

    // -------------------------------------------
    // 4️⃣ Dashboard Stats
    // -------------------------------------------
    @GetMapping("/dashboard/stats")
    public ResponseEntity<?> getDashboardStats() {

        Map<String, Object> stats = new HashMap<>();

        stats.put("totalUsers", userRepository.count());
        stats.put("totalCustomers", userRepository.countByRole(Role.USER));
        stats.put("totalOwners", userRepository.countByRole(Role.OWNER));
        stats.put("totalSalons", salonRepository.count());
        stats.put("pendingApprovals", salonRepository.countByApprovalStatus(SalonApprovalStatus.PENDING));

        return ResponseEntity.ok(new ApiResponse("Dashboard Stats", stats));
    }

    // -------------------------------------------
    // 5️⃣ User Management (Block / Unblock / Delete)
    // -------------------------------------------

    @PostMapping("/user/block/{userId}")
    public ResponseEntity<?> blockUser(@PathVariable Long userId, @RequestParam Long adminId) {

        userService.blockUser(userId);
        adminService.logAction(adminId, "BLOCK_USER", "USER", userId);

        return ResponseEntity.ok(new ApiResponse("User blocked successfully", null));
    }

    @PostMapping("/user/unblock/{userId}")
    public ResponseEntity<?> unblockUser(@PathVariable Long userId, @RequestParam Long adminId) {

        userService.unblockUser(userId);
        adminService.logAction(adminId, "UNBLOCK_USER", "USER", userId);

        return ResponseEntity.ok(new ApiResponse("User unblocked successfully", null));
    }

    @DeleteMapping("/user/{userId}")
    public ResponseEntity<?> deleteUser(@PathVariable Long userId, @RequestParam Long adminId) {

        // Hard delete can fail due to foreign key constraints (bookings, invoices, etc.)
        // For admin panel we treat "delete" as a safe soft delete by blocking the user.
        userService.blockUser(userId);
        adminService.logAction(adminId, "BLOCK_USER", "USER", userId);

        return ResponseEntity.ok(new ApiResponse("User blocked (soft deleted) successfully", null));
    }

    // -------------------------------------------
    // 6️⃣ Get All Users (Admin)
    // -------------------------------------------
    @GetMapping("/users")
    public ResponseEntity<?> getAllUsers() {
        var users = userRepository.findAll();
        
        List<Map<String, Object>> list = users.stream()
                .map(u -> {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", u.getId());
                    m.put("name", u.getName());
                    m.put("email", u.getEmail());
                    m.put("mobile", u.getMobile());
                    m.put("role", u.getRole().name());
                    m.put("isActive", u.getIsActive());
                    m.put("gender", u.getGender());
                    m.put("address", u.getAddress());
                    m.put("city", u.getCity());
                    m.put("state", u.getState());
                    m.put("createdAt", u.getCreatedAt());
                    return m;
                })
                .collect(Collectors.toList());
        
        return ResponseEntity.ok(list);
    }

    // -------------------------------------------
    // 7️⃣ Admin - Bookings
    // -------------------------------------------

    @GetMapping("/bookings")
    public ResponseEntity<?> listBookings(@RequestParam(required = false) String status) {

        BookingStatus bookingStatus = null;
        if (status != null && !status.isBlank()) {
            bookingStatus = BookingStatus.valueOf(status.toUpperCase());
        }

        var list = bookingService.listAllBookings(bookingStatus)
                .stream()
                .map(b -> {
                    var map = new java.util.HashMap<String, Object>();
                    map.put("id", b.getId());
                    map.put("status", b.getStatus().name());
                    map.put("queueNumber", b.getQueueNumber());
                    map.put("bookingTime", b.getBookingTime());
                    map.put("scheduledAt", b.getScheduledAt());
                    if (b.getSalon() != null) {
                        map.put("salonName", b.getSalon().getSalonName());
                    }
                    if (b.getService() != null) {
                        map.put("serviceName", b.getService().getServiceName());
                        map.put("servicePrice", b.getService().getPrice());
                    }
                    if (b.getUser() != null) {
                        map.put("userName", b.getUser().getName());
                        map.put("userMobile", b.getUser().getMobile());
                    }
                    map.put("rejectionReason", b.getRejectionReason());
                    return map;
                })
                .collect(java.util.stream.Collectors.toList());

        return ResponseEntity.ok(new ApiResponse("Bookings list", list));
    }

    @PostMapping("/booking/cancel/{bookingId}")
    public ResponseEntity<?> cancelBookingByAdmin(
            @PathVariable Long bookingId,
            @RequestParam Long adminId,
            @RequestParam(required = false) String reason) {

        var booking = bookingService.cancelBookingByAdmin(bookingId, adminId, reason);
        adminService.logAction(adminId, "CANCEL_BOOKING", "BOOKING", bookingId);
        return ResponseEntity.ok(new ApiResponse("Booking cancelled", null));
    }

    // -------------------------------------------
    // 7️⃣ Admin - Salon Overview (analytics)
    // -------------------------------------------

    @GetMapping("/salon/overview/{salonId}")
    public ResponseEntity<?> getSalonOverview(@PathVariable Long salonId) {

        Salon salon = salonRepository.findById(salonId)
                .orElseThrow(() -> new IllegalArgumentException("Salon not found"));

        // Basic salon info
        Map<String, Object> salonMap = new HashMap<>();
        salonMap.put("id", salon.getId());
        salonMap.put("salonName", salon.getSalonName());
        salonMap.put("city", salon.getCity());
        salonMap.put("address", salon.getAddress());
        salonMap.put("category", salon.getCategory());
        salonMap.put("openTime", salon.getOpenTime());
        salonMap.put("closeTime", salon.getCloseTime());
        salonMap.put("approvalStatus", salon.getApprovalStatus() != null ? salon.getApprovalStatus().name() : null);
        salonMap.put("isLive", salon.getIsLive());
        if (salon.getOwner() != null) {
            salonMap.put("ownerName", salon.getOwner().getName());
            salonMap.put("ownerMobile", salon.getOwner().getMobile());
        }

        // Booking stats
        var allBookings = bookingService.listBookingsBySalonAndStatus(salonId, null);
        long total = allBookings.size();
        long completed = allBookings.stream().filter(b -> b.getStatus() == BookingStatus.COMPLETED).count();
        long requested = allBookings.stream().filter(b -> b.getStatus() == BookingStatus.REQUESTED).count();
        long accepted = allBookings.stream().filter(b -> b.getStatus() == BookingStatus.ACCEPTED).count();
        long inService = allBookings.stream().filter(b -> b.getStatus() == BookingStatus.IN_SERVICE).count();
        long rejected = allBookings.stream().filter(b -> b.getStatus() == BookingStatus.REJECTED).count();
        long cancelled = allBookings.stream().filter(b -> b.getStatus() == BookingStatus.CANCELLED).count();

        // Date ranges
        java.time.LocalDate todayDate = java.time.LocalDate.now();
        java.time.LocalDateTime startOfToday = todayDate.atStartOfDay();
        java.time.LocalDateTime endOfToday = todayDate.atTime(23, 59, 59);

        java.time.LocalDate startOfWeekDate = todayDate.minusDays(6);
        java.time.LocalDateTime startOfWeek = startOfWeekDate.atStartOfDay();

        java.time.LocalDate firstOfMonth = todayDate.withDayOfMonth(1);
        java.time.LocalDateTime startOfMonth = firstOfMonth.atStartOfDay();

        long todayBookings = allBookings.stream()
                .filter(b -> b.getScheduledAt() != null &&
                        !b.getScheduledAt().isBefore(startOfToday) &&
                        !b.getScheduledAt().isAfter(endOfToday))
                .count();

        long weekBookings = allBookings.stream()
                .filter(b -> b.getScheduledAt() != null &&
                        !b.getScheduledAt().isBefore(startOfWeek))
                .count();

        long monthBookings = allBookings.stream()
                .filter(b -> b.getScheduledAt() != null &&
                        !b.getScheduledAt().isBefore(startOfMonth))
                .count();

        Map<String, Object> bookingsMap = new HashMap<>();
        bookingsMap.put("total", total);
        bookingsMap.put("completed", completed);
        bookingsMap.put("requested", requested);
        bookingsMap.put("accepted", accepted);
        bookingsMap.put("inService", inService);
        bookingsMap.put("rejected", rejected);
        bookingsMap.put("cancelled", cancelled);
        bookingsMap.put("today", todayBookings);
        bookingsMap.put("thisWeek", weekBookings);
        bookingsMap.put("thisMonth", monthBookings);

        // Revenue stats via invoices
        var invoices = invoiceRepository.findByBookingSalonId(salonId);
        double totalRevenue = invoices.stream()
                .mapToDouble(inv -> inv.getTotalAmount() != null ? inv.getTotalAmount() : 0.0)
                .sum();

        double todayRevenue = invoices.stream()
                .filter(inv -> inv.getBooking() != null && inv.getBooking().getScheduledAt() != null &&
                        !inv.getBooking().getScheduledAt().isBefore(startOfToday) &&
                        !inv.getBooking().getScheduledAt().isAfter(endOfToday))
                .mapToDouble(inv -> inv.getTotalAmount() != null ? inv.getTotalAmount() : 0.0)
                .sum();

        double weekRevenue = invoices.stream()
                .filter(inv -> inv.getBooking() != null && inv.getBooking().getScheduledAt() != null &&
                        !inv.getBooking().getScheduledAt().isBefore(startOfWeek))
                .mapToDouble(inv -> inv.getTotalAmount() != null ? inv.getTotalAmount() : 0.0)
                .sum();

        double monthRevenue = invoices.stream()
                .filter(inv -> inv.getBooking() != null && inv.getBooking().getScheduledAt() != null &&
                        !inv.getBooking().getScheduledAt().isBefore(startOfMonth))
                .mapToDouble(inv -> inv.getTotalAmount() != null ? inv.getTotalAmount() : 0.0)
                .sum();

        Map<String, Object> revenueMap = new HashMap<>();
        revenueMap.put("total", totalRevenue);
        revenueMap.put("today", todayRevenue);
        revenueMap.put("thisWeek", weekRevenue);
        revenueMap.put("thisMonth", monthRevenue);

        // Staff stats
        var staffList = staffRepository.findBySalon(salon);
        java.util.List<Map<String, Object>> staffDtos = new java.util.ArrayList<>();
        for (var st : staffList) {
            Map<String, Object> sm = new HashMap<>();
            sm.put("id", st.getId());
            sm.put("name", st.getName());
            sm.put("role", st.getRole());
            sm.put("isAvailable", st.getIsOnline());

            long staffBookings = allBookings.stream()
                    .filter(b -> b.getStaff() != null && b.getStaff().getId().equals(st.getId()))
                    .count();

            double staffRevenue = invoices.stream()
                    .filter(inv -> inv.getBooking() != null &&
                            inv.getBooking().getStaff() != null &&
                            inv.getBooking().getStaff().getId().equals(st.getId()))
                    .mapToDouble(inv -> inv.getTotalAmount() != null ? inv.getTotalAmount() : 0.0)
                    .sum();

            sm.put("totalBookings", staffBookings);
            sm.put("totalRevenue", staffRevenue);
            staffDtos.add(sm);
        }

        Map<String, Object> payload = new HashMap<>();
        payload.put("salon", salonMap);
        payload.put("bookings", bookingsMap);
        payload.put("revenue", revenueMap);
        payload.put("staff", staffDtos);

        return ResponseEntity.ok(new ApiResponse("Salon overview", payload));
    }

}
