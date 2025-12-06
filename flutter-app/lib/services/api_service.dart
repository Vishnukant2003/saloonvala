import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/api_response.dart';
import '../models/salon.dart';
import '../models/booking.dart';
import '../models/service.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class ApiService {
  late final Dio _dio;
  final StorageService _storage = StorageService();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 120),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token to headers (except for public endpoints)
        final isPublicAuthEndpoint = 
            options.path.contains('/api/auth/login') ||
            options.path.contains('/api/auth/register');
        
        if (!isPublicAuthEndpoint) {
          final token = _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Handle errors globally if needed
        return handler.next(error);
      },
    ));

    // Add logging interceptor (optional - for debugging)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // Authentication
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String mobile,
    required String name,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.apiAuthLogin,
        data: {
          'mobile': mobile,
          'name': name,
          'role': role,
        },
      );
      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<dynamic>> register({
    required String mobile,
    required String name,
    required String role,
    String? email,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.apiAuthRegister,
        data: {
          'mobile': mobile,
          'name': name,
          'role': role,
          if (email != null && email.isNotEmpty) 'email': email,
        },
      );
      return ApiResponse.fromJson(response.data, (data) => data);
    } catch (e) {
      rethrow;
    }
  }

  // Salons
  Future<List<Salon>> getAllSalons() async {
    try {
      final response = await _dio.get(AppConstants.apiSalonAll);
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Salon.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Salon> getSalonById(int salonId) async {
    try {
      final response = await _dio.get('${AppConstants.apiSalonServices}/$salonId');
      return Salon.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Bookings
  Future<List<Booking>> getUserBookings(int userId) async {
    try {
      final response = await _dio.get('${AppConstants.apiBookingUser}/$userId');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Booking.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // Services
  Future<List<Service>> getSalonServices(int salonId) async {
    try {
      final response = await _dio.get('${AppConstants.apiSalonServices}/$salonId/services');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Service.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // Create booking
  Future<ApiResponse<Booking>> createBooking({
    required int salonId,
    required int serviceId,
    required int userId,
    String? scheduledAt,
    int? staffId,
  }) async {
    try {
      final response = await _dio.post(
        'api/booking/create',
        data: {
          'salonId': salonId,
          'serviceId': serviceId,
          'userId': userId,
          'scheduledAt': scheduledAt,
          'staffId': staffId,
        },
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => Booking.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get owner's salons (for shop dashboard)
  Future<List<Salon>> getOwnerSalons() async {
    try {
      final response = await _dio.get('api/owner/salons');
      // API returns { message: "...", data: [...] }
      if (response.data is Map && response.data['data'] != null) {
        final data = response.data['data'];
        if (data is List) {
          return data
              .map((json) => Salon.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // Get salon bookings (for owner dashboard stats)
  Future<List<Booking>> getSalonBookings(int salonId, {String? status}) async {
    try {
      String url = 'api/booking/salon/$salonId';
      if (status != null) {
        url += '?status=$status';
      }
      debugPrint('🔍 API Call: GET $url');
      final response = await _dio.get(url);
      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response data type: ${response.data.runtimeType}');
      
      if (response.data is List) {
        final bookings = (response.data as List)
            .map((json) => Booking.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('📊 Parsed ${bookings.length} bookings');
        return bookings;
      }
      debugPrint('⚠️ Response is not a list: ${response.data}');
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching bookings: $e');
      rethrow;
    }
  }

  // Get salon bookings by status - Alias method for backward compatibility
  Future<List<Booking>> getSalonBookingsByStatus(int salonId, String? status) async {
    return getSalonBookings(salonId, status: status);
  }

  // ==================== BOOKING MANAGEMENT APIs ====================

  // Accept booking
  Future<ApiResponse<Booking>> acceptBooking(int bookingId, int ownerId) async {
    try {
      final response = await _dio.post(
        'api/booking/accept/$bookingId',
        queryParameters: {'ownerId': ownerId},
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => Booking.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint('Error accepting booking: $e');
      rethrow;
    }
  }

  // Reject booking
  Future<ApiResponse<Booking>> rejectBooking(int bookingId, int ownerId, {String? reason}) async {
    try {
      final response = await _dio.post(
        'api/booking/reject/$bookingId',
        queryParameters: {
          'ownerId': ownerId,
          if (reason != null) 'reason': reason,
        },
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => Booking.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint('Error rejecting booking: $e');
      rethrow;
    }
  }

  // Start service
  Future<ApiResponse<Booking>> startService(int bookingId, int ownerId) async {
    try {
      final response = await _dio.post(
        'api/booking/start/$bookingId',
        queryParameters: {'ownerId': ownerId},
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => Booking.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint('Error starting service: $e');
      rethrow;
    }
  }

  // Complete service
  Future<ApiResponse<Booking>> completeService(int bookingId, int ownerId) async {
    try {
      final response = await _dio.post(
        'api/booking/complete/$bookingId',
        queryParameters: {'ownerId': ownerId},
      );
      return ApiResponse.fromJson(
        response.data,
        (data) => Booking.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint('Error completing service: $e');
      rethrow;
    }
  }

  // Update salon live status
  Future<bool> updateSalonLiveStatus(int salonId, bool isLive) async {
    try {
      final response = await _dio.put(
        'api/owner/salon',
        data: {
          'salonId': salonId,
          'isLive': isLive,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== USER LOCATION APIs ====================

  // Save user location
  Future<ApiResponse<dynamic>> saveUserLocation({
    required int userId,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String pincode,
    String? landmark,
    required String fullAddress,
    double? latitude,
    double? longitude,
  }) async {
    try {
      debugPrint('📍 Saving user location for userId: $userId');
      final response = await _dio.put(
        'api/user/$userId/location',
        data: {
          'addressLine1': addressLine1,
          'addressLine2': addressLine2,
          'city': city,
          'state': state,
          'pincode': pincode,
          'landmark': landmark,
          'fullAddress': fullAddress,
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      debugPrint('✅ Location saved successfully');
      return ApiResponse.fromJson(response.data, (data) => data);
    } catch (e) {
      debugPrint('❌ Error saving location: $e');
      rethrow;
    }
  }

  // Get user location
  Future<Map<String, dynamic>?> getUserLocation(int userId) async {
    try {
      final response = await _dio.get('api/user/$userId/location');
      if (response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user location: $e');
      return null;
    }
  }

  // Update user profile
  Future<ApiResponse<dynamic>> updateUserProfile({
    required int userId,
    required String name,
    String? email,
    String? gender,
    String? dateOfBirth,
  }) async {
    try {
      debugPrint('📝 Updating user profile for user: $userId');
      final response = await _dio.put(
        'api/user/$userId/profile',
        data: {
          'name': name,
          'email': email,
          'gender': gender,
          'dateOfBirth': dateOfBirth,
        },
      );
      debugPrint('✅ Profile updated successfully');
      return ApiResponse.fromJson(response.data, (data) => data);
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      rethrow;
    }
  }

  // Upload user profile image
  Future<String?> uploadProfileImage(int userId, File imageFile) async {
    try {
      debugPrint('📷 Uploading profile image for user: $userId');
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });
      
      final response = await _dio.post(
        'api/user/$userId/profile-image',
        data: formData,
      );
      
      debugPrint('✅ Profile image uploaded successfully');
      if (response.data != null && response.data['imageUrl'] != null) {
        return response.data['imageUrl'] as String;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error uploading profile image: $e');
      rethrow;
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(int userId) async {
    try {
      final response = await _dio.get('api/user/$userId/profile');
      if (response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  // ==================== ADMIN APIs ====================

  // Get admin ID from storage
  int _getAdminId() {
    final userId = _storage.getUserId();
    return userId ?? 1; // Default to 1 if not found
  }

  // Get admin dashboard stats
  Future<Map<String, dynamic>> getAdminDashboardStats() async {
    try {
      debugPrint('📊 Fetching admin dashboard stats...');
      final response = await _dio.get('api/admin/dashboard/stats');
      debugPrint('📊 Dashboard stats response: ${response.data}');
      
      // Handle ApiResponse format {message, data}
      if (response.data is Map && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Error fetching admin stats: $e');
      return {};
    }
  }

  // Get admin bookings
  Future<List<dynamic>> getAdminBookings() async {
    try {
      debugPrint('📅 Fetching admin bookings...');
      final response = await _dio.get('api/admin/bookings');
      debugPrint('📅 Bookings response type: ${response.data.runtimeType}');
      
      // Handle ApiResponse format {message, data}
      if (response.data is Map && response.data['data'] != null) {
        final data = response.data['data'];
        if (data is List) return data;
      }
      if (response.data is List) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching admin bookings: $e');
      return [];
    }
  }

  // Get admin salons
  Future<List<dynamic>> getAdminSalons() async {
    try {
      debugPrint('🏪 Fetching admin salons...');
      final response = await _dio.get('api/admin/salons');
      debugPrint('🏪 Salons response type: ${response.data.runtimeType}');
      
      // Handle ApiResponse format {message, data}
      if (response.data is Map && response.data['data'] != null) {
        final data = response.data['data'];
        debugPrint('🏪 Salons data count: ${data is List ? data.length : 'not a list'}');
        if (data is List) return data;
      }
      if (response.data is List) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching admin salons: $e');
      return [];
    }
  }

  // Approve salon
  Future<void> approveSalon(int salonId) async {
    try {
      final adminId = _getAdminId();
      debugPrint('✅ Approving salon $salonId by admin $adminId');
      await _dio.post(
        'api/admin/salon/approve/$salonId',
        queryParameters: {'adminId': adminId},
      );
      debugPrint('✅ Salon approved successfully');
    } catch (e) {
      debugPrint('❌ Error approving salon: $e');
      rethrow;
    }
  }

  // Reject salon
  Future<void> rejectSalon(int salonId, String reason) async {
    try {
      final adminId = _getAdminId();
      debugPrint('❌ Rejecting salon $salonId by admin $adminId with reason: $reason');
      await _dio.post(
        'api/admin/salon/reject/$salonId',
        queryParameters: {
          'adminId': adminId,
          'reason': reason,
        },
      );
      debugPrint('❌ Salon rejected successfully');
    } catch (e) {
      debugPrint('❌ Error rejecting salon: $e');
      rethrow;
    }
  }

  // Get salon details for review (using overview endpoint)
  Future<Map<String, dynamic>> getSalonDetailsForReview(int salonId) async {
    try {
      debugPrint('🔍 Fetching salon details for review: $salonId');
      final response = await _dio.get('api/admin/salon/overview/$salonId');
      debugPrint('🔍 Salon overview response: ${response.data}');
      
      // Handle ApiResponse format {message, data}
      if (response.data is Map && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Error fetching salon for review: $e');
      return {};
    }
  }

  // Submit salon review
  Future<void> submitSalonReview({
    required int salonId,
    required bool approved,
    String? rejectionReason,
    List<String>? rejectedFields,
  }) async {
    try {
      if (approved) {
        await approveSalon(salonId);
      } else {
        await rejectSalon(salonId, rejectionReason ?? 'Rejected by admin');
      }
    } catch (e) {
      debugPrint('❌ Error submitting salon review: $e');
      rethrow;
    }
  }

  // Get admin users
  Future<List<dynamic>> getAdminUsers() async {
    try {
      debugPrint('👥 Fetching admin users...');
      final response = await _dio.get('api/admin/users');
      debugPrint('👥 Users response type: ${response.data.runtimeType}');
      
      // Handle ApiResponse format {message, data}
      if (response.data is Map && response.data['data'] != null) {
        final data = response.data['data'];
        if (data is List) return data;
      }
      if (response.data is List) {
        debugPrint('👥 Users count: ${response.data.length}');
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching admin users: $e');
      return [];
    }
  }

  // Block user
  Future<void> blockUser(int userId) async {
    try {
      final adminId = _getAdminId();
      debugPrint('🚫 Blocking user $userId by admin $adminId');
      await _dio.post(
        'api/admin/user/block/$userId',
        queryParameters: {'adminId': adminId},
      );
      debugPrint('🚫 User blocked successfully');
    } catch (e) {
      debugPrint('❌ Error blocking user: $e');
      rethrow;
    }
  }

  // Unblock user
  Future<void> unblockUser(int userId) async {
    try {
      final adminId = _getAdminId();
      debugPrint('✅ Unblocking user $userId by admin $adminId');
      await _dio.post(
        'api/admin/user/unblock/$userId',
        queryParameters: {'adminId': adminId},
      );
      debugPrint('✅ User unblocked successfully');
    } catch (e) {
      debugPrint('❌ Error unblocking user: $e');
      rethrow;
    }
  }

  // Cancel booking by admin
  Future<void> cancelBookingByAdmin(int bookingId, {String? reason}) async {
    try {
      final adminId = _getAdminId();
      debugPrint('❌ Cancelling booking $bookingId by admin $adminId');
      await _dio.post(
        'api/admin/booking/cancel/$bookingId',
        queryParameters: {
          'adminId': adminId,
          if (reason != null) 'reason': reason,
        },
      );
      debugPrint('❌ Booking cancelled successfully');
    } catch (e) {
      debugPrint('❌ Error cancelling booking: $e');
      rethrow;
    }
  }

  // ==================== SALON REGISTRATION APIs ====================

  // Get salon registration status
  Future<ApiResponse<Map<String, dynamic>>> getSalonRegistrationStatus() async {
    try {
      final response = await _dio.get('api/owner/salon/status');
      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error fetching registration status: $e');
      return ApiResponse(message: 'Failed to fetch status', data: null);
    }
  }

  // Get rejected fields
  Future<ApiResponse<Map<String, dynamic>>> getRejectedFields() async {
    try {
      final response = await _dio.get('api/owner/salon/rejected-fields');
      return ApiResponse.fromJson(response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error fetching rejected fields: $e');
      return ApiResponse(message: 'Failed to fetch rejected fields', data: null);
    }
  }

  // Resubmit corrected fields
  Future<ApiResponse<dynamic>> resubmitCorrectedFields(Map<String, dynamic> corrections) async {
    try {
      final response = await _dio.post('api/owner/salon/resubmit', data: corrections);
      return ApiResponse.fromJson(response.data, (data) => data);
    } catch (e) {
      debugPrint('Error resubmitting corrections: $e');
      rethrow;
    }
  }

  // Register salon with full details
  Future<ApiResponse<dynamic>> registerSalon({
    // Owner Details
    required String ownerName,
    required String ownerPhone,
    String? ownerEmail,
    String? ownerAge,
    String? ownerGender,
    String? ownerProfileImageUrl,
    
    // Salon Basic Info
    required String salonName,
    required String category,
    String? description,
    String? establishedYear,
    String? specialities,
    
    // Location & Address
    required String address,
    String? landmark,
    required String city,
    required String state,
    required String pincode,
    double? latitude,
    double? longitude,
    
    // Business Hours & Staff
    String? openTime,
    String? closeTime,
    String? workingDays,
    int? numberOfStaff,
    String? languages,
    String? serviceArea,
    bool? homeServiceAvailable,
    
    // Documents
    required String aadhaarNumber,
    String? aadhaarFrontImageUrl,
    String? aadhaarBackImageUrl,
    required String panNumber,
    String? panCardImageUrl,
    String? shopLicenseNumber,
    String? shopLicenseImageUrl,
    String? gstNumber,
    String? gstCertificateImageUrl,
    
    // Photos
    String? liveSelfieImageUrl,
    String? shopFrontImageUrl,
    String? shopInsideImage1Url,
    String? shopInsideImage2Url,
  }) async {
    try {
      debugPrint('📝 Registering salon: $salonName');
      debugPrint('👤 Owner: $ownerName, $ownerPhone, $ownerEmail, Age: $ownerAge, Gender: $ownerGender');
      debugPrint('📄 Documents: Aadhaar: $aadhaarNumber, PAN: $panNumber');
      debugPrint('📍 Location: $city, $state, $pincode');
      debugPrint('🕐 Hours: $openTime - $closeTime, Days: $workingDays');
      
      final response = await _dio.post('api/owner/salon', data: {
        // Owner Details
        'ownerName': ownerName,
        'ownerPhone': ownerPhone,
        'ownerEmail': ownerEmail,
        'ownerAge': ownerAge,
        'ownerGender': ownerGender,
        'ownerProfileImageUrl': ownerProfileImageUrl,
        
        // Salon Basic Info
        'salonName': salonName,
        'category': category,
        'description': description,
        'establishedYear': establishedYear,
        'specialities': specialities,
        'contactNumber': ownerPhone, // Use owner phone as contact
        
        // Location & Address
        'address': address,
        'landmark': landmark,
        'city': city,
        'state': state,
        'pincode': pincode,
        'latitude': latitude,
        'longitude': longitude,
        
        // Business Hours & Staff
        'openTime': openTime,
        'closeTime': closeTime,
        'workingDays': workingDays,
        'numberOfStaff': numberOfStaff,
        'languages': languages,
        'serviceArea': serviceArea,
        'homeServiceAvailable': homeServiceAvailable,
        
        // Documents
        'aadhaarNumber': aadhaarNumber,
        'aadhaarFrontImageUrl': aadhaarFrontImageUrl,
        'aadhaarBackImageUrl': aadhaarBackImageUrl,
        'panNumber': panNumber,
        'panCardImageUrl': panCardImageUrl,
        'shopLicenseNumber': shopLicenseNumber,
        'shopLicenseImageUrl': shopLicenseImageUrl,
        'gstNumber': gstNumber,
        'gstCertificateImageUrl': gstCertificateImageUrl,
        
        // Photos
        'liveSelfieImageUrl': liveSelfieImageUrl,
        'shopFrontImageUrl': shopFrontImageUrl,
        'shopInsideImage1Url': shopInsideImage1Url,
        'shopInsideImage2Url': shopInsideImage2Url,
      });
      
      debugPrint('✅ Salon registered successfully');
      return ApiResponse.fromJson(response.data, (data) => data);
    } catch (e) {
      debugPrint('❌ Error registering salon: $e');
      rethrow;
    }
  }

  // ==================== STAFF APIs ====================

  // Get salon staff
  Future<List<dynamic>> getSalonStaff(int salonId) async {
    try {
      final response = await _dio.get('api/salon/$salonId/staff');
      if (response.data is List) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching staff: $e');
      return [];
    }
  }

  // Add staff
  Future<ApiResponse<dynamic>> addStaff(Map<String, dynamic> staffData) async {
    try {
      final response = await _dio.post('api/staff/add', data: staffData);
      return ApiResponse.fromJson(response.data, (data) => data);
    } catch (e) {
      debugPrint('Error adding staff: $e');
      rethrow;
    }
  }

  // Update staff
  Future<void> updateStaff(Map<String, dynamic> staffData) async {
    try {
      await _dio.put('api/staff/update', data: staffData);
    } catch (e) {
      debugPrint('Error updating staff: $e');
      rethrow;
    }
  }

  // Delete staff
  Future<void> deleteStaff(int staffId) async {
    try {
      await _dio.delete('api/staff/$staffId');
    } catch (e) {
      debugPrint('Error deleting staff: $e');
      rethrow;
    }
  }

  // Toggle staff online status
  Future<void> toggleStaffOnlineStatus(int staffId, bool isOnline) async {
    try {
      await _dio.put('api/staff/$staffId/status', data: {'isOnline': isOnline});
    } catch (e) {
      debugPrint('Error toggling staff status: $e');
      rethrow;
    }
  }

  // Get staff statistics
  Future<Map<String, dynamic>> getStaffStatistics({
    required int staffId,
    required int salonId,
  }) async {
    try {
      final response = await _dio.get('api/staff/$staffId/statistics', 
        queryParameters: {'salonId': salonId});
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error fetching staff statistics: $e');
      return {};
    }
  }

  // Calculate staff hours
  Future<Map<String, dynamic>> calculateStaffHours(int staffId) async {
    try {
      final response = await _dio.get('api/staff/$staffId/hours');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error calculating staff hours: $e');
      return {};
    }
  }

  // Upload staff photo
  Future<void> uploadStaffPhoto(int staffId, dynamic imageFile) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(imageFile.path),
      });
      await _dio.post('api/staff/$staffId/photo', data: formData);
    } catch (e) {
      debugPrint('Error uploading staff photo: $e');
      rethrow;
    }
  }

  // ==================== SERVICE APIs ====================

  // Create service
  Future<void> createService(Map<String, dynamic> serviceData) async {
    try {
      await _dio.post('api/service/create', data: serviceData);
    } catch (e) {
      debugPrint('Error creating service: $e');
      rethrow;
    }
  }

  // Update service
  Future<void> updateService(Map<String, dynamic> serviceData) async {
    try {
      await _dio.put('api/service/update', data: serviceData);
    } catch (e) {
      debugPrint('Error updating service: $e');
      rethrow;
    }
  }

  // Delete service
  Future<void> deleteService(int serviceId) async {
    try {
      await _dio.delete('api/service/$serviceId');
    } catch (e) {
      debugPrint('Error deleting service: $e');
      rethrow;
    }
  }
}
