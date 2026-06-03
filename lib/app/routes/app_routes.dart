import 'package:heimwatt/app/modules/auth/authentication/authentication_screen.dart';
import 'package:heimwatt/app/modules/auth/forgot_password/forgot_password_controller.dart';
import 'package:heimwatt/app/modules/auth/forgot_password/forgot_password_screen.dart';
import 'package:heimwatt/app/modules/auth/login/login_controller.dart';
import 'package:heimwatt/app/modules/auth/login/login_screen.dart';
import 'package:heimwatt/app/modules/auth/otp_verification/otp_verification_controller.dart';
import 'package:heimwatt/app/modules/auth/otp_verification/otp_verification_screen.dart';
import 'package:heimwatt/app/modules/auth/reset_password/reset_password_controller.dart';
import 'package:heimwatt/app/modules/auth/reset_password/reset_password_screen.dart';
import 'package:heimwatt/app/modules/deal_selection/deal_screen.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_steps_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:heimwatt/app/modules/installation_steps/media_library_form_screen/Views/image_preview_screen.dart';
import 'package:heimwatt/app/utils/pref_service.dart';

import '../utils/exports.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String auth = '/auth';
  static const String login = '/login';
  static const String forgotPassword = '/forgotPassword';
  static const String otpVerification = '/otpVerification';
  static const String resetPassword = '/resetPassword';
  static const String installationSteps = '/installationSteps';
  static const String imagePreview = '/imagePreview';
  static const String dealSelection = '/dealSelection';

  static bool _isAuthenticated() {
    final user = FirebaseAuth.instance.currentUser;
    final userId = PrefService.getString(PrefService.userId);
    return user != null && userId.isNotEmpty;
  }

  static String? _redirect(BuildContext context, GoRouterState state) {
    final isAuthenticated = _isAuthenticated();
    final location = state.matchedLocation;

    if (location.startsWith('/login')) return null;

    final publicRoutes = [auth, forgotPassword, otpVerification, resetPassword];

    if (location == '/') {
      return isAuthenticated ? installationSteps : auth;
    }

    if (isAuthenticated && publicRoutes.contains(location)) {
      return installationSteps;
    }

    if (!isAuthenticated && !publicRoutes.contains(location)) {
      return auth;
    }

    return null;
  }

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.auth,
    redirect: _redirect,
    routes: [
      /// AUTH SCREEN
      GoRoute(
        path: auth,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        onExit: (context, state) {
          Get.delete<LoginController>();
          return true;
        },
      ),

      GoRoute(
        path: '/login/:token',
        builder: (context, state) => const AuthenticationScreen(),
      ),

      /// FORGOT PASSWORD
      GoRoute(
        path: forgotPassword,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: ForgotPasswordScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        onExit: (context, state) {
          Get.delete<ForgotPasswordController>();
          return true;
        },
      ),

      /// OTP
      GoRoute(
        path: otpVerification,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: OtpVerificationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        onExit: (context, state) {
          Get.delete<OtpVerificationController>();
          return true;
        },
      ),

      /// RESET PASSWORD
      GoRoute(
        path: resetPassword,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: ResetPasswordScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        onExit: (context, state) {
          Get.delete<ResetPasswordController>();
          return true;
        },
      ),

      /// INSTALLATION STEPS
      GoRoute(
        path: installationSteps,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: InstallationStepsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      /// IMAGE PREVIEW
      GoRoute(
        path: imagePreview,
        pageBuilder: (context, state) {
          final data = state.extra as Map<String, dynamic>;

          return CustomTransitionPage(
            child: ImagePreviewScreen(
              isNetwork: data['isNetwork'],
              image: data['image'],
              imageByte: data['imageByte'],
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),

      /// DEAL SELECTION
      GoRoute(
        path: dealSelection,
        pageBuilder: (context, state) => CustomTransitionPage(
          child: DealScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
    ],
  );
}
