import 'package:flutter/material.dart';
import '../screens/auth/main_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/user/dashboard_screen.dart';
import '../screens/user/profile_screen.dart';
import '../screens/user/my_bookings_screen.dart';
import '../screens/user/search_screen.dart';
import '../screens/user/categories_screen.dart';
import '../screens/user/all_salons_screen.dart';
import '../screens/shop/shop_details_screen.dart';
import '../screens/shop/dashboard_screen.dart';
import '../screens/shop/manage_services_screen.dart';
import '../screens/shop/appointments_screen.dart';
import '../screens/shop/staff_management_screen.dart';
import '../screens/shop/revenue_screen.dart';
import '../screens/shop/completed_appointments_screen.dart';
import '../screens/booking/booking_screen.dart';
import '../screens/user/edit_profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/shop/gallery_screen.dart';
import '../screens/shop/customer_list_screen.dart';
import '../screens/shop/staff_analytics_screen.dart';
import '../screens/admin/login_screen.dart';
import '../screens/admin/dashboard_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
        '/': (context) => const MainScreen(),
        '/login': (context) {
          final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'USER';
          return LoginScreen(role: role);
        },
        '/register': (context) {
          final role = ModalRoute.of(context)?.settings.arguments as String? ?? 'USER';
          return RegisterScreen(role: role);
        },
        '/welcome': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
          return WelcomeScreen(
            userName: args?['userName'] ?? 'User',
            userRole: args?['userRole'] ?? 'USER',
          );
        },
        '/user-dashboard': (context) => const UserDashboardScreen(),
        '/shop-dashboard': (context) => const ShopDashboardScreen(),
        '/profile': (context) => const UserProfileScreen(),
        '/bookings': (context) => const MyBookingsScreen(),
        '/search': (context) => const SearchScreen(),
        '/categories': (context) => const CategoriesScreen(),
        '/all-salons': (context) => const AllSalonsScreen(),
        '/manage-services': (context) => const ManageServicesScreen(),
        '/appointments': (context) {
          final showNext3Days = ModalRoute.of(context)?.settings.arguments as bool? ?? false;
          return AppointmentsScreen(showNext3Days: showNext3Days);
        },
        '/staff-management': (context) => const StaffManagementScreen(),
        '/revenue': (context) => const RevenueScreen(),
        '/completed-appointments': (context) => const CompletedAppointmentsScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/gallery': (context) => const GalleryScreen(),
        '/customer-list': (context) => const CustomerListScreen(),
        '/staff-analytics': (context) => const StaffAnalyticsScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
      };
}
