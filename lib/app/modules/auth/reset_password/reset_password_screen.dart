import 'package:heimwatt/app/modules/auth/reset_password/reset_password_controller.dart';
import 'package:heimwatt/app/modules/auth/reset_password/view/desktop_view.dart';
import 'package:heimwatt/app/modules/auth/reset_password/view/mobile_view.dart';
import 'package:heimwatt/app/modules/auth/reset_password/view/tablet_view.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../utils/exports.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({super.key});
  final ResetPasswordController resetPasswordController = Get.put(ResetPasswordController());
  
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => ResetPasswordMobileView(),
      tablet: (context) => ResetPasswordTabletView(),
      desktop: (context) => ResetPasswordDesktopView(),
    );
  }
}

