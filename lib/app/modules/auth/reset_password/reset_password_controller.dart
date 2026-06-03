
import '../../../utils/exports.dart';

class ResetPasswordController extends GetxController {
  RxBool isNewPasswordEyeOpen = false.obs;
  RxBool isConfirmPasswordEyeOpen = false.obs;
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  GlobalKey<FormState> resetPasswordKey = GlobalKey<FormState>();

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

