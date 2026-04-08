import 'package:go_router/go_router.dart';
import '../pages/role_selection_page.dart';
import '../pages/customer_browse_page.dart';
import '../pages/clinic_profile_page.dart';
import '../pages/booking_page.dart';
import '../pages/company_dashboard_page.dart';
import '../pages/not_found_page.dart';
import '../pages/clinic_management_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const RoleSelectionPage(),
    ),
    GoRoute(
      path: '/customer',
      builder: (context, state) => const CustomerBrowsePage(),
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
