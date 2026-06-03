import 'package:heimwatt/app/modules/auth/otp_verification/otp_verification_controller.dart';
import 'package:pinput/pinput.dart';

import '../../../../utils/exports.dart';

class OtpVerificationTabletView extends StatelessWidget {
  const OtpVerificationTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: controller.otpVerificationKey,
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
                  AppText(AppStrings.otpVerification, style: AppTextStyle.extraBold30(), textAlign: TextAlign.center),
                  Gap(10),
                  AppText(
                    AppStrings.otpVerificationDescription,
                    style: AppTextStyle.regular16(),
                    textAlign: TextAlign.center,
                  ),
                  Gap(30),
                  SizedBox(
                    width: width * 0.6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [
                        Pinput(
                          length: 6,
                          controller: controller.otpController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          defaultPinTheme: defaultPinTheme,
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
                      ],
                    ),
                  ),
                  Gap(20),
                  SizedBox(
                    width: width * 0.6,
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
                    width: width * 0.6,
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
          );
        },
      ),
    );
  }
}
