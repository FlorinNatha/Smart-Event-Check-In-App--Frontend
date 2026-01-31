import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/attendee/screens/attendee_home_screen.dart';
import '../../features/staff/screens/staff_home_screen.dart';
import '../../features/admin/screens/admin_home_screen.dart';
import '../../features/attendee/screens/events_list_screen.dart';
import '../../features/attendee/screens/event_details_screen.dart';
import '../../features/attendee/screens/my_tickets_screen.dart';
import '../../features/attendee/screens/ticket_details_screen.dart';
import '../../features/attendee/screens/profile_screen.dart';
import '../../features/staff/screens/qr_scanner_screen.dart';
import '../../features/staff/screens/scan_history_screen.dart';

import '../../features/admin/screens/manage_events_screen.dart';
import '../../features/admin/screens/create_edit_event_screen.dart';
import '../../features/admin/screens/event_analytics_screen.dart';

/// App router configuration
class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Attendee Routes
      GoRoute(
        path: '/attendee/home',
        builder: (context, state) => const AttendeeHomeScreen(),
      ),
      GoRoute(
        path: '/attendee/events',
        builder: (context, state) => const EventsListScreen(),
      ),
      GoRoute(
        path: '/attendee/events/:id',
        builder: (context, state) => EventDetailsScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/attendee/tickets',
        builder: (context, state) => const MyTicketsScreen(),
      ),
      GoRoute(
        path: '/attendee/tickets/:id',
        builder: (context, state) => TicketDetailsScreen(ticketId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/attendee/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Staff Routes
      GoRoute(
        path: '/staff/home',
        builder: (context, state) => const StaffHomeScreen(),
      ),
      GoRoute(
        path: '/staff/scanner',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: '/staff/history',
        builder: (context, state) => const ScanHistoryScreen(),
      ),

      // Admin Routes
      GoRoute(
        path: '/admin/home',
        builder: (context, state) => const AdminHomeScreen(),
      ),
      GoRoute(
        path: '/admin/events',
        builder: (context, state) => const ManageEventsScreen(),
      ),
      GoRoute(
        path: '/admin/events/create',
        builder: (context, state) => const CreateEditEventScreen(),
      ),
      GoRoute(
        path: '/admin/events/edit/:id',
        builder: (context, state) => CreateEditEventScreen(eventId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/admin/events/analytics/:id',
        builder: (context, state) => EventAnalyticsScreen(eventId: state.pathParameters['id']!),
      ),
    ],
  );
}
