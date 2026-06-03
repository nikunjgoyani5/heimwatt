import 'package:heimwatt/app/modules/installation_steps/installation_steps_controller.dart';
import 'package:heimwatt/app/modules/installation_steps/view/desktop_view.dart';
import 'package:heimwatt/app/modules/installation_steps/view/mobile_view.dart';
import 'package:heimwatt/app/modules/installation_steps/view/tablet_view.dart';
import 'package:heimwatt/app/utils/pref_service.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/exports.dart';

class InstallationStepsScreen extends StatefulWidget {
  InstallationStepsScreen({super.key});

  @override
  State<InstallationStepsScreen> createState() => _InstallationStepsScreenState();
}

class _InstallationStepsScreenState extends State<InstallationStepsScreen> {
  final InstallationStepsController installationStepsController =
      Get.put(InstallationStepsController());

  // Check if user is authenticated
  bool _isAuthenticated() {
    final user = FirebaseAuth.instance.currentUser;
    final userId = PrefService.getString(PrefService.userId);
    return user != null && userId.isNotEmpty;
  }
  @override
  void initState() {
    super.initState();
    // Call handleLoginWithToken after the first frame is built
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Future.delayed(Duration( seconds: 3));
    //   handleLoginWithToken(context);
    // });
  }

  @override
  Widget build(BuildContext context) {

    return PopScope(


      canPop: false, // Prevent back navigation
      onPopInvoked: (didPop) {
        // If user tries to go back and is still authenticated, prevent it
        if (_isAuthenticated() && !didPop) {
          // Optionally show a message or do nothing
          // The navigation is already prevented by canPop: false
        }
      },
      child: ScreenTypeLayout.builder(
        mobile: (context) => InstallationStepsMobileView(),
        tablet: (context) => InstallationStepsTabletView(),
        desktop: (context) => InstallationStepsDesktopView(),
      ),
    );
  }

  @override
  void dispose() {
    // Delete here (after route widgets are removed) to avoid "Controller not found"
    // during transitional rebuilds while GoRouter is switching routes.
    if (Get.isRegistered<InstallationStepsController>()) {
      Get.delete<InstallationStepsController>();
    }
    super.dispose();
  }
}

