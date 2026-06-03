
import '../../utils/exports.dart';
import 'splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      init: SplashController(),
      builder: (controller) {
        return Scaffold(
          // backgroundColor: Colors.red,
          body: Center(

                     ),
        );
      },
    );
  }
}
