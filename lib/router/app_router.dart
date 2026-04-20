import 'package:go_router/go_router.dart';
import '../pages/role_selection_page.dart';
import '../pages/login_page.dart';
import '../pages/customer_browse_page.dart';
import '../pages/clinic_profile_page.dart';
import '../pages/booking_page.dart';
import '../pages/company_dashboard_page.dart';
import '../pages/not_found_page.dart';
import '../pages/clinic_management_page.dart';
import '../pages/company_profile_page.dart';
import '../pages/customer_register_page.dart';
import '../pages/clinic_register_page.dart';
import '../pages/onboarding_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/role',
      builder: (context, state) => const RoleSelectionPage(),
    ),
    GoRoute(
      path: '/login/:role',
      builder: (context, state) {
        final role = state.pathParameters['role']!;
        return LoginPage(role: role);
      },
    ),
    GoRoute(
      path: '/customer',
      builder: (context, state) => const CustomerBrowsePage(),
    ),
    GoRoute(
      path: '/register/customer',
      builder: (context, state) => const CustomerRegisterPage(),
    ),
    GoRoute(
      path: '/register/clinic',
      builder: (context, state) => const ClinicRegisterPage(),
    ),
    GoRoute(
      path: '/clinic/:id',
      builder: (context, state) {
        final clinicId = state.pathParameters['id']!;
        return ClinicProfilePage(clinicId: clinicId);
      },
    ),
    GoRoute(
      path: '/book/:clinicId/:serviceId',
      builder: (context, state) {
        final clinicId = state.pathParameters['clinicId']!;
        final serviceId = state.pathParameters['serviceId']!;
        return BookingPage(
          clinicId: clinicId,
          serviceId: serviceId,
        );
      },
    ),
    GoRoute(
      path: '/company',
      builder: (context, state) => const CompanyDashboardPage(),
      routes: [
        GoRoute(
          path: 'profile',
          builder: (context, state) => const CompanyProfilePage(),
        ),
      ],
    ),
    GoRoute(
      path: '/clinic/:id/manage',
      builder: (context, state) {
        final clinicId = state.pathParameters['id']!;
        return ClinicManagementPage(clinicId: clinicId);
      },
    ),
  ],
  errorBuilder: (context, state) => const NotFoundPage(),
);
