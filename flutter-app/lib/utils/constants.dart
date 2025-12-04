class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'https://admin.saloonvala.in/';
  // Or use: 'https://saloonvala-main-production.up.railway.app/'
  
  // Storage Keys
  static const String keyToken = 'auth_token';
  static const String keyRole = 'user_role';
  static const String keyName = 'user_name';
  static const String keyUserId = 'user_id';
  
  // Prefs name
  static const String prefsName = 'salon_pref';
  static const String keyPhone = 'user_phone';
  static const String keyEmail = 'user_email';
  static const String keyShopLive = 'shop_live_status';
  
  // API Endpoints
  static const String apiAuthLogin = 'api/auth/login';
  static const String apiAuthRegister = 'api/auth/register';
  static const String apiSalonAll = 'api/salon/all';
  static const String apiBookingUser = 'api/booking/user';
  static const String apiSalonServices = 'api/salon';
  
  // Other Constants
  static const double maxNearbyDistanceKm = 5.0;
}

