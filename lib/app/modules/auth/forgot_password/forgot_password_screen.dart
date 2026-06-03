import 'package:heimwatt/app/modules/auth/forgot_password/forgot_password_controller.dart';
import 'package:heimwatt/app/modules/auth/forgot_password/view/desktop_view.dart';
import 'package:heimwatt/app/modules/auth/forgot_password/view/mobile_view.dart';
import 'package:heimwatt/app/modules/auth/forgot_password/view/tablet_view.dart';
import 'package:responsive_builder/responsive_builder.dart';


import '../../../utils/exports.dart';

class ForgotPasswordScreen extends StatelessWidget {
   ForgotPasswordScreen({super.key});
final ForgotPasswordController forgotPasswordController = Get.put(ForgotPasswordController());
  @override
  Widget build(BuildContext context) {
    return  ScreenTypeLayout.builder(
      mobile: (context) => ForgotPasswordMobileView(),
      tablet: (context) => ForgotPasswordTabletView(),
      desktop: (context) => ForgotPasswordDesktopView(),
    );
  }
}
