import 'package:heimwatt/app/modules/auth/otp_verification/otp_verification_controller.dart';
import 'package:pinput/pinput.dart';

import '../../../../utils/exports.dart';

class OtpVerificationDesktopView extends StatelessWidget {
  const OtpVerificationDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.whiteF5F5F5,
      body: GetBuilder<OtpVerificationController>(
        builder: (controller) {
          final defaultPinTheme = PinTheme(
            width: 50,
            height: 50,
            textStyle: AppTextStyle.semiBold20(),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
          );

          final focusedPinTheme = defaultPinTheme.copyWith(
            decoration: defaultPinTheme.decoration?.copyWith(border: Border.all(color: Colors.blue)),
          );

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
                    key: controller.otpVerificationKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Gap(50),
                          Image.asset(Assets.images.logo.path, scale: 3),
                          Gap(50),
                          AppText(
                            AppStrings.otpVerification,
                            style: AppTextStyle.extraBold42(),
                            textAlign: TextAlign.center,
                          ),
                          Gap(10),
                          AppText(
                            AppStrings.otpVerificationDescription,
                            style: AppTextStyle.regular16(),
                            textAlign: TextAlign.center,
                          ),
                          Gap(30),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 300,
                                child: Pinput(
                                  length: 6,
                                  keyboardType: TextInputType.number,
                                  controller: controller.otpController,
                                  defaultPinTheme: defaultPinTheme,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  focusedPinTheme: focusedPinTheme,
                                  onChanged: controller.onOtpChanged,
                                  onCompleted: controller.onOtpCompleted,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppStrings.pleaseEnterOtp;
                                    } else if (value.length != 6) {
                                      return AppStrings.pleaseEnterValidOtp;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Gap(20),
                          SizedBox(
                            width: 300,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    // Handle resend OTP
                                  },
                                  child: Text(AppStrings.resendOtp, style: AppTextStyle.regular12()),
                                ),
                              ],
                            ),
                          ),
                          Gap(40),
                          CommonButton(
                            onTap: () {
                              if (controller.otpVerificationKey.currentState?.validate() ?? false) {
                                context.go(AppRoutes.resetPassword);
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
