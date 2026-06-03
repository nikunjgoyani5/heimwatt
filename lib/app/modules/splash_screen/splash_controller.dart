import '../../utils/exports.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    navigate();
  }

  void navigate() async {


    await Future.delayed(Duration(seconds: 3));


  }



}
