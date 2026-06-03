// import '../utils/exports.dart';
//
// class RouteGuardService extends GetxService {
//   static RouteGuardService get to => Get.find();
//
//   final RxBool isAuthenticated = false.obs;
//   final RxBool isInitialized = false.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _checkAuthenticationStatus();
//   }
//
//   void _checkAuthenticationStatus() {
//     final token = PrefService.getString(PrefService.token);
//     isAuthenticated.value = token.isNotEmpty;
//     isInitialized.value = true;
//   }
//
//   void updateAuthenticationStatus() {
//     _checkAuthenticationStatus();
//   }
//
//   bool canAccessRoute(String route) {
//     // Public routes that don't require authentication
//     final publicRoutes = ['/login', '/signup', '/forgotPassword', '/verifyOtp', '/loading', '/resetPassword'];
//
//     if (publicRoutes.contains(route)) {
//       return true;
//     }
//
//     // For protected routes, use basic token check
//     return isAuthenticated.value;
//   }
//
//   void logout() {
//     isAuthenticated.value = false;
//   }
//
//   void login() {
//     isAuthenticated.value = true;
//   }
// }