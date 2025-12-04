import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/salon.dart';
import '../services/api_service.dart';

class SalonProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<Salon> _salons = [];
  List<Salon> _filteredSalons = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCategory;
  String? _selectedLocation;

  List<Salon> get salons => _filteredSalons;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAllSalons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _salons = await _api.getAllSalons();
      _filteredSalons = _salons;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load salons: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void filterByLocation(String? location) {
    _selectedLocation = location;
    _applyFilters();
  }

  void clearFilters() {
    _selectedCategory = null;
    _selectedLocation = null;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredSalons = _salons.where((salon) {
      // Filter by category
      if (_selectedCategory != null) {
        final salonCategory = salon.category?.toLowerCase() ?? '';
        final selectedCat = _selectedCategory!.toLowerCase();
        if (!salonCategory.contains(selectedCat)) {
          return false;
        }
      }

      // Filter by approval and live status
      if (salon.approvalStatus != 'APPROVED' || salon.isLive != true) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  List<Salon> getNearbySalons(double? latitude, double? longitude, double maxDistanceKm) {
    if (latitude == null || longitude == null) {
      return _filteredSalons;
    }

    return _filteredSalons.where((salon) {
      if (salon.latitude == null || salon.longitude == null) {
        return false;
      }

      final distance = _calculateDistance(
        latitude,
        longitude,
        salon.latitude!,
        salon.longitude!,
      );

      return distance <= maxDistanceKm;
    }).toList();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = (dLat / 2) * (dLat / 2) +
        _degreesToRadians(lat1).abs() * _degreesToRadians(lat2).abs() *
            (dLon / 2) * (dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}

