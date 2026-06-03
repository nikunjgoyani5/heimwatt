import 'package:heimwatt/app/modules/auth/reset_password/reset_password_controller.dart';

import '../../../../utils/exports.dart';

class ResetPasswordTabletView extends StatelessWidget {
  const ResetPasswordTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.whiteF5F5F5,
      body: GetBuilder<ResetPasswordController>(
        builder: (controller) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: controller.resetPasswordKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(Assets.images.logo.path, height: 30, fit: BoxFit.fill),
                      Spacer(),
                      Image.asset(Assets.images.staticProfile.path, scale: 3),
                    ],
                  ),
                  Gap(32),
                  ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(24),
                    child: Image.asset(
                      Assets.images.loginImage.path,
                      width: width * 0.7,
                      height: height * 0.25,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Gap(40),
                  AppText(AppStrings.resetPassword, style: AppTextStyle.extraBold30(), textAlign: TextAlign.center),
                  Gap(10),
                  AppText(
                    AppStrings.resetPasswordDescription,
                    style: AppTextStyle.regular16(),
                    textAlign: TextAlign.center,
                  ),
                  Gap(30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(AppStrings.newPassword, style: AppTextStyle.semiBold16()),
                      Gap(10),
                      SizedBox(
                        width: width * 0.6,
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
                        width: width * 0.6,
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
                    width: width * 0.6,
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
          );
        },
      ),
    );
  }
}
