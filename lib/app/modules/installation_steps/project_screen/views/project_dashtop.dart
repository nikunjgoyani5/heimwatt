import 'package:heimwatt/app/utils/pref_service.dart';

import '../../../../utils/exports.dart';
import '../../installation_steps_controller.dart';

class ProjectDashtop extends StatefulWidget {
  const ProjectDashtop({super.key});

  @override
  State<ProjectDashtop> createState() => _ProjectDashtopState();

  static void showDiscardChangesDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.warning_amber_rounded, color: AppColors.primaryColor, size: 24),
                    ),
                    const Gap(16),
                    Expanded(
                      child: AppText('Discard Changes?', style: AppTextStyle.semiBold20(color: AppColors.black002432)),
                    ),
                  ],
                ),
                const Gap(20),
                AppText(
                  'Are you sure you want to discard changes? This action cannot be undone.',
                  style: AppTextStyle.regular14(color: AppColors.greyADB9BD),
                ),
                const Gap(32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CommonButton(
                      text: 'Cancel',
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                      },
                      color: Colors.transparent,
                      textColor: AppColors.greyADB9BD,
                      height: 48,
                      showArrow: false,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    const Gap(12),
                    CommonButton(
                      text: 'Discard',
                      width: 150,
                      height: 48,
                      color: AppColors.primaryColor,
                      textColor: AppColors.whiteColor,
                      icon: Icons.delete_outline,
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        Get.find<InstallationStepsController>().navigateToTutorial();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProjectDashtopState extends State<ProjectDashtop> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Text(
            "Projects> ${PrefService.getString(PrefService.dealName)}",
            style: AppTextStyle.extraBold48(color: AppColors.black002432),
          ),
        ),
      ),
    );
  }
}
