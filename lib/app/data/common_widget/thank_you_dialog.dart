import 'package:heimwatt/app/modules/installation_steps/installation_steps_controller.dart';

import '../../utils/exports.dart';

class ThankYouDialog extends StatelessWidget {
  const ThankYouDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width < 600 ? 16 : 40,
            vertical: MediaQuery.of(context).size.height < 600 ? 16 : 40,
          ),
          child: const ThankYouDialog(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return GetBuilder<InstallationStepsController>(
      builder: (controller) {
        return Container(
          constraints: BoxConstraints(maxWidth: isMobile ? screenWidth - 32 : 600),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button in top right
              (isMobile == false)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.whiteColor,
                                border: Border.all(color: AppColors.greyADB9BD, width: 1.5),
                              ),
                              child: const Icon(Icons.close, size: 20, color: AppColors.black002432),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.whiteColor,
                                border: Border.all(color: AppColors.greyADB9BD, width: 1.5),
                              ),
                              child: const Icon(Icons.close, size: 20, color: AppColors.black002432),
                            ),
                          ),
                        ),
                        AppText(
                          AppStrings.thankYou,
                          style: AppTextStyle.extraBold28(color: AppColors.black002432),
                          textAlign: TextAlign.center,
                        ),

                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.transparent),
                          child: const Icon(Icons.close, size: 20, color: Colors.transparent),
                        ),
                      ],
                    ),
              const Gap(32),
              // Green checkmark circle
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 56, color: AppColors.whiteColor),
              ),
              const Gap(24),
              // "Thank you!" heading
              if (isMobile == false) ...[
                AppText(
                  AppStrings.thankYou,
                  style: AppTextStyle.extraBold28(color: AppColors.black002432),
                  textAlign: TextAlign.center,
                ),
                const Gap(12),
              ],
              // Confirmation message
              AppText(
                AppStrings.reportDownloadedSuccessfully,
                style: AppTextStyle.regular16(color: AppColors.black002432),
                textAlign: TextAlign.center,
              ),
              const Gap(32),
              // "Back to Projects" button
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: () {
                    context.pop();
                    controller.ispdf = false;
                    controller.showTutorialScreen = false;
                    controller.isTutorialSection = false;
                    controller.showAddressSelectionScreen = false;
                    controller.showStepTypeScreen = false;
                    controller.showMediaLibraryScreen = false;
                    controller.showInstallationFormScreen = false;
                    controller.showProjectScreen = true;
                    // After 2 seconds, show tutorial screen
                    Future.delayed(const Duration(seconds: 2), () {
                      controller.showProjectScreen = false;
                      controller.showTutorialScreen = true;
                      controller.isTutorialSection = true;
                      controller.update();
                    });
                    controller.update();
                  },
                  child: Container(
                    width: isMobile ? double.infinity : 250,
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(Assets.icons.icProjects.path, width: 20, height: 20),
                        const Gap(24),
                        Text(AppStrings.backToProjects, style: AppTextStyle.semiBold16(color: AppColors.black002432)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
