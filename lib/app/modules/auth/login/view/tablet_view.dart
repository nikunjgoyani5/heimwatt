import 'package:heimwatt/app/modules/auth/login/login_controller.dart';

import '../../../../utils/exports.dart';

class LoginTabletView extends StatelessWidget {
  const LoginTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.whiteF5F5F5,
      body: GetBuilder<LoginController>(
        builder: (controller) {
          return Form(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: controller.loginKey,
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
                    AppText(
                      AppStrings.loginToDashboard,
                      style: AppTextStyle.extraBold30(),
                      textAlign: TextAlign.center,
                    ),

                    AppText(AppStrings.enterYourDetails, style: AppTextStyle.regular16(), textAlign: TextAlign.center),
                    Gap(30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(AppStrings.emailAddress, style: AppTextStyle.semiBold16()),
                        Gap(10),
                        SizedBox(
                          width: width * 0.6,

                          child: CommonTextField(
                            onSubmitted: (val) {
                              if (controller.loginKey.currentState?.validate() ?? false) {
                                controller.login(context);
                              }
                            },
                            textInputAction: TextInputAction.next,

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
                    Gap(25),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(AppStrings.password, style: AppTextStyle.semiBold16()),
                        Gap(10),
                        SizedBox(
                          width: width * 0.6,

                          child: CommonTextField(
                            onSubmitted: (val) {
                              if (controller.loginKey.currentState?.validate() ?? false) {
                                controller.login(context);
                              }
                            },

                            obscureText: !controller.isEyeOpen.value,
                            hintText: AppStrings.passwordHint,
                            controller: controller.passwordController,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                controller.passwordController.clear();
                                return AppStrings.pleaseEnterPass;
                              }
                              return null;
                            },
                            suffixIcon: Obx(() {
                              return InkWell(
                                onTap: () {
                                  controller.isEyeOpen.value = !controller.isEyeOpen.value;
                                  controller.update();
                                },
                                child: controller.isEyeOpen.value
                                    ? Image.asset(Assets.icons.icOpenEye.path, width: 30, fit: BoxFit.fill)
                                    : Image.asset(Assets.icons.icCloseEye.path, width: 20, fit: BoxFit.fill),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                    Gap(10),
                    SizedBox(
                      width: width * 0.6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              context.go(AppRoutes.forgotPassword);
                            },
                            child: Text(AppStrings.forgotPasswordQuestion, style: AppTextStyle.regular12()),
                          ),
                        ],
                      ),
                    ),
                    Gap(40),
                    Obx(() {
                      return CommonButton(
                        width: width * 0.6,
                        onTap: controller.isLoading.value
                            ? () {}
                            : () {
                                controller.login(context);
                              },
                        text: controller.isLoading.value ? '' : AppStrings.continuee,
                        child: controller.isLoading.value
                            ? const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.black002432),
                                  ),
                                ),
                              )
                            : null,
                      );
                    }),
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
