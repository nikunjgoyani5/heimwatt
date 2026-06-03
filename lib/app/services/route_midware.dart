// import 'package:go_router/go_router.dart';
// import 'package:heimwatt/app/services/route_service.dart';
//
// import '../utils/exports.dart';
//
// class RouteMiddleware {
//   static String? handleRoute(BuildContext context, GoRouterState state) {
//     // Initialize route guard service if not already done
//     if (!Get.isRegistered<RouteGuardService>()) {
//       Get.put(RouteGuardService());
//     }
//
//     final routeGuard = Get.find<RouteGuardService>();
//
//     // Wait for initialization
//     if (!routeGuard.isInitialized.value) {
//       return null; // Don't redirect while initializing
//     }
//
//     final isAuthenticated = routeGuard.isAuthenticated.value;
//     final currentRoute = state.matchedLocation;
//
//     // ✅ Public routes that don't require authentication
//     final publicRoutes = [
//       '/login',
//       '/signup',
//       '/forgotPassword',
//       '/verifyOtp',
//       '/loading',
//       '/resetPassword',
//       '/onBoard',
//     ];
//
//     if (isAuthenticated &&
//         PrefService.getBool(PrefService.isOnBoard) == false) {
//       if (currentRoute != '/onBoard') {
//         log('Redirecting to /onBoard - onboarding not completed');
//         return '/onBoard';
//       }
//     }
//
//     // ✅ 2. Special case: allow onboarding only if from signup
//     if (currentRoute == '/onBoard') {
//       final from = state.extra is Map<String, dynamic>
//           ? (state.extra as Map<String, dynamic>)['from']
//           : null;
//       if (from != 'signup' &&
//           PrefService.getBool(PrefService.isOnBoard) == true) {
//         // If already onboarded → send to dashboard if logged in, else login
//         return isAuthenticated ? '/dashboard' : '/login';
//       }
//     }
//
//     // ✅ 3. If user is not authenticated and trying to access protected route
//     if (!isAuthenticated && !publicRoutes.contains(currentRoute)) {
//       log('Redirecting to /login - unauthenticated');
//       return '/login';
//     }
//
//     // ✅ 4. If user is authenticated and trying to access public auth routes (except onboarding)
//     if (isAuthenticated &&
//         publicRoutes.contains(currentRoute) &&
//         currentRoute != '/onBoard') {
//       log('Redirecting to /dashboard - already logged in');
//       return '/dashboard';
//     }
//
//     return null; // No redirect
//   }
//
//   static void clearNavigationHistory(BuildContext context) {
//     // This will be handled by GoRouter's context.go() method
//   }
//
//   static void logoutAndClearHistory(BuildContext context) {
//     // Cleanup captcha state if controller exists
//     if (Get.isRegistered<LoginController>()) {
//       try {
//         Get.find<LoginController>().cleanupCaptcha();
//       } catch (e) {
//         log('Error cleaning up captcha during logout: $e');
//       }
//     }
//
//     // Logout from route guard service
//     if (Get.isRegistered<RouteGuardService>()) {
//       Get.find<RouteGuardService>().logout();
//     }
//
//     // Navigate to login
//     context.go('/login');
//   }
// }