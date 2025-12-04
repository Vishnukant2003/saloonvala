import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../services/api_service.dart';

class BookingProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserBookings(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await _api.getUserBookings(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load bookings: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
}

