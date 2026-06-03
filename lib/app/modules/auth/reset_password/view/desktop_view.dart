
import 'package:heimwatt/app/modules/auth/reset_password/reset_password_controller.dart';

import '../../../../utils/exports.dart';

class ResetPasswordDesktopView extends StatelessWidget {
  const ResetPasswordDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.whiteF5F5F5,
      body: GetBuilder<ResetPasswordController>(
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.asset(Assets.images.loginImage.path, width: width, height: height, fit: BoxFit.fill),
                ),
                Expanded(
                  child: Form(
                    key: controller.resetPasswordKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Gap(50),
                          Image.asset(Assets.images.logo.path, scale: 3),
                          Gap(50),
                          AppText(
                            AppStrings.resetPassword,
                            style: AppTextStyle.extraBold42(),
                            textAlign: TextAlign.center,
                          ),
                          Gap(10),
                          AppText(AppStrings.resetPasswordDescription, style: AppTextStyle.regular16(), textAlign: TextAlign.center),
                          Gap(30),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(AppStrings.newPassword, style: AppTextStyle.semiBold16()),
                              Gap(10),
                              SizedBox(
                                width: 300,
                                child: CommonTextField(
                                  obscureText: controller.isNewPasswordEyeOpen.value,
                                  hintText: AppStrings.passwordHint,
                                  controller: controller.newPasswordController,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      controller.newPasswordController.clear();
                                      return AppStrings.pleaseEnterNewPassword;
                                    }
                                    return null;
                                  },
                                  suffixIcon: Obx(() {
                                    return InkWell(
                                      onTap: () {
                                        controller.isNewPasswordEyeOpen.value = !controller.isNewPasswordEyeOpen.value;
                                        controller.update();
                                      },
                                      child: controller.isNewPasswordEyeOpen.value
                                          ? Image.asset(Assets.icons.icOpenEye.path, width: 30, fit: BoxFit.fill)
                                          : Image.asset(Assets.icons.icCloseEye.path, width: 20, fit: BoxFit.fill),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                          Gap(25),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(AppStrings.confirmPassword, style: AppTextStyle.semiBold16()),
                              Gap(10),
                              SizedBox(
                                width: 300,
                                child: CommonTextField(
                                  obscureText: controller.isConfirmPasswordEyeOpen.value,
                                  hintText: AppStrings.passwordHint,
                                  controller: controller.confirmPasswordController,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      controller.confirmPasswordController.clear();
                                      return AppStrings.pleaseEnterConfirmPassword;
                                    }
                                    if (val != controller.newPasswordController.text) {
                                      return AppStrings.passwordNotMatch;
                                    }
                                    return null;
                                  },
                                  suffixIcon: Obx(() {
                                    return InkWell(
                                      onTap: () {
                                        controller.isConfirmPasswordEyeOpen.value = !controller.isConfirmPasswordEyeOpen.value;
                                        controller.update();
                                      },
                                      child: controller.isConfirmPasswordEyeOpen.value
                                          ? Image.asset(Assets.icons.icOpenEye.path, width: 30, fit: BoxFit.fill)
                                          : Image.asset(Assets.icons.icCloseEye.path, width: 20, fit: BoxFit.fill),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                          Gap(40),
                          CommonButton(
                            onTap: () {
                              if (controller.resetPasswordKey.currentState?.validate() ?? false) {
                                // Handle reset password
                              }
                            },
                            text: AppStrings.continuee,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

