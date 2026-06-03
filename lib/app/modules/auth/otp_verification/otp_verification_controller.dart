
import '../../../utils/exports.dart';

class OtpVerificationController extends GetxController {
  TextEditingController otpController = TextEditingController();
  GlobalKey<FormState> otpVerificationKey = GlobalKey<FormState>();
  String otp = '';

  void onOtpChanged(String value) {
    otp = value;
    update();
  }

  void onOtpCompleted(String value) {
    otp = value;
    update();
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}

