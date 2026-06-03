import 'package:heimwatt/app/modules/auth/login/login_controller.dart';
import 'package:heimwatt/app/modules/auth/login/view/desktop_view.dart';
import 'package:heimwatt/app/modules/auth/login/view/mobile_view.dart';
import 'package:heimwatt/app/modules/auth/login/view/tablet_view.dart';
import 'package:responsive_builder/responsive_builder.dart';


import '../../../utils/exports.dart';

class LoginScreen extends StatelessWidget {
   LoginScreen({super.key});
final LoginController loginController = Get.put(LoginController());
  @override
  Widget build(BuildContext context) {
    return  ScreenTypeLayout.builder(
      mobile: (context) => LoginMobileView(),
      tablet: (context) => LoginTabletView(),
      desktop: (context) => LoginDesktopView(),
    );
  }
}
