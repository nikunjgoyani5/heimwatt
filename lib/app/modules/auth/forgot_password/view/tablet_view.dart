import 'package:heimwatt/app/modules/auth/forgot_password/forgot_password_controller.dart';

import '../../../../utils/exports.dart';

class ForgotPasswordTabletView extends StatelessWidget {
  const ForgotPasswordTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.whiteF5F5F5,
      body: GetBuilder<ForgotPasswordController>(
        builder: (controller) {
          return Form(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),

              child: Form(
                key: controller.forgotPasswordKey,
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
                    AppText(AppStrings.forgotPassword, style: AppTextStyle.extraBold30(), textAlign: TextAlign.center),
                    Gap(10),
                    AppText(
                      AppStrings.forgotPasswordDescription,
                      style: AppTextStyle.regular16(),
                      textAlign: TextAlign.center,
                    ),
                    Gap(30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(AppStrings.emailAddress, style: AppTextStyle.semiBold16()),
                        Gap(10),
                        SizedBox(
                          width: width * 0.6,

                          child: CommonTextField(
                            hintText: AppStrings.emailHint,
                            controller: controller.emailController,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                controller.emailController.clear();
                                return AppStrings.pleaseEnterEmail;
                              }
                              if (val.trim().isEmail == false) {
                                return AppStrings.pleaseEnterValidEmail;
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    Gap(40),
                    CommonButton(
                      width: width * 0.6,
                      onTap: () {
                        if (controller.forgotPasswordKey.currentState?.validate() ?? false) {
                          context.go(AppRoutes.otpVerification);
                        }
                      },

                      text: AppStrings.sendOtp,
                    ),
                    Gap(20),
                    CommonButton(
                      text: "Back To login",
                      onTap: () {
                        context.go(AppRoutes.login);
                      },
                      color: Colors.transparent,
                      textColor: AppColors.greyADB9BD,
                      height: 40,
                      showArrow: false,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
