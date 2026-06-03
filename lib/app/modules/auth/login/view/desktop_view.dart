import 'package:heimwatt/app/modules/auth/login/login_controller.dart';

import '../../../../utils/exports.dart';

class LoginDesktopView extends StatelessWidget {
  const LoginDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.whiteF5F5F5,
      body: GetBuilder<LoginController>(
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
                    key: controller.loginKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Gap(50),
                          Image.asset(Assets.images.logo.path, scale: 3),
                          Gap(50),
                          AppText(
                            AppStrings.loginToDashboard,
                            style: AppTextStyle.extraBold42(),
                            textAlign: TextAlign.center,
                          ),

                          AppText(AppStrings.enterYourDetails, style: AppTextStyle.regular16()),
                          Gap(30),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(AppStrings.emailAddress, style: AppTextStyle.semiBold16()),
                              Gap(10),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.25,
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
                                  onSubmitted: (val) {
                                    if (controller.loginKey.currentState?.validate() ?? false) {
                                      controller.login(context);
                                    }
                                  },
                                  textInputAction: TextInputAction.next,
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
                                width: MediaQuery.of(context).size.width * 0.25,
                                child: CommonTextField(
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
                                  onSubmitted: (val) {
                                    if (controller.loginKey.currentState?.validate() ?? false) {
                                      controller.login(context);
                                    }
                                  },
                                  suffixIcon: Obx(() {
                                    return InkWell(
                                      onTap: () {
                                        controller.isEyeOpen.value = !controller.isEyeOpen.value;
                                        controller.update();
                                      },
                                      child: controller.isEyeOpen.value
                                          ? Padding(
                                        padding: const EdgeInsets.only(right: 12.0),
                                            child: Image.asset(Assets.icons.icOpenEye.path, width: 40, fit: BoxFit.fill),
                                          )
                                          : Padding(
                                        padding: const EdgeInsets.only(right: 12.0),
                                            child: Image.asset(Assets.icons.icCloseEye.path, width: 20, fit: BoxFit.fill),
                                          ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                          Gap(10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child:  Row(
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
                              width: MediaQuery.of(context).size.width * 0.25,
                              onTap: controller.isLoading.value ? () {} : () {
                                controller.login(context);
                              },
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
                              text: controller.isLoading.value ? '' : AppStrings.continuee,
                            );
                          }),
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
