import 'package:heimwatt/app/modules/auth/otp_verification/otp_verification_controller.dart';
import 'package:heimwatt/app/modules/auth/otp_verification/view/desktop_view.dart';
import 'package:heimwatt/app/modules/auth/otp_verification/view/mobile_view.dart';
import 'package:heimwatt/app/modules/auth/otp_verification/view/tablet_view.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../utils/exports.dart';

class OtpVerificationScreen extends StatelessWidget {
  OtpVerificationScreen({super.key});
  final OtpVerificationController otpVerificationController = Get.put(OtpVerificationController());
  
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => OtpVerificationMobileView(),
      tablet: (context) => OtpVerificationTabletView(),
      desktop: (context) => OtpVerificationDesktopView(),
    );
  }
}

