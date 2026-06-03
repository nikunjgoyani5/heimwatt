import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:heimwatt/app/utils/app_functions.dart';
import 'package:heimwatt/app/utils/pref_service.dart';
import 'package:heimwatt/repository/main_repository.dart';
import 'package:toastification/toastification.dart';

import 'app/appController/zoom_controller.dart';
import 'app/utils/exports.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PrefService.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exceptionAsString().contains("LegacyJavaScriptObject")) {
      return; // ignore noisy inspector errors
    }
    FlutterError.dumpErrorToConsole(details);
  };
  // handleLoginWithToken(context);

  runApp(const Heimwatt());
}

class Heimwatt extends StatelessWidget {
  const Heimwatt({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp.router(
        title: "HeimWatt",
        scrollBehavior: ScrollBehavior().copyWith(scrollbars: false),
        defaultTransition: Transition.fade,
        debugShowCheckedModeBanner: false,
        routerDelegate: AppRoutes.router.routerDelegate,
        routeInformationParser: AppRoutes.router.routeInformationParser,
        routeInformationProvider: AppRoutes.router.routeInformationProvider,

        builder: (context, child) {
          Get.put(GlobalZoomService());
          if (child == null) return const SizedBox();
          return child;
        },
      ),
    );
  }
}



