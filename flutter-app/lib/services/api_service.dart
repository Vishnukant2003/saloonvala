import 'package:dio/dio.dart';
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
}

