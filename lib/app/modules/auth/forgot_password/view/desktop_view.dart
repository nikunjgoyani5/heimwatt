import 'package:heimwatt/app/modules/auth/forgot_password/forgot_password_controller.dart';

import '../../../../utils/exports.dart';

class ForgotPasswordDesktopView extends StatelessWidget {
  const ForgotPasswordDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.whiteF5F5F5,
      body: GetBuilder<ForgotPasswordController>(
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
                    key: controller.forgotPasswordKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Gap(50),
                          Image.asset(Assets.images.logo.path, scale: 3),
                          Gap(50),
                          AppText(
                            AppStrings.forgotPassword,
                            style: AppTextStyle.extraBold42(),
                            textAlign: TextAlign.center,
                          ),
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
                                width: 300,

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
                            onTap: () {
                              if (controller.forgotPasswordKey.currentState?.validate() ?? false) {
                                context.go(AppRoutes.otpVerification);
                              }
                            },

                            text: AppStrings.sendOtp,
                          ),
                          Gap(20),
                          TextButton(onPressed: () {
                            context.go(AppRoutes.login);
                          }, child: Text('Back To login', style: AppTextStyle.semiBold16(),))

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
