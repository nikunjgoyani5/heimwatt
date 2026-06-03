import '../../../../utils/exports.dart';
import '../../installation_steps_controller.dart';

class StepTypeDesktop extends StatefulWidget {
  const StepTypeDesktop({super.key});

  @override
  State<StepTypeDesktop> createState() => _StepTypeDesktopState();
}

class _StepTypeDesktopState extends State<StepTypeDesktop> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InstallationStepsController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: screenHeight * 0.6,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: screenHeight * 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Section: Step-by-Step Installation Form
          Expanded(
            child: _buildSection(
              icon: Assets.icons.icScanner,
              title: 'Step-by-Step Installation Form',
              description:
                  'Follow clear instructions, check reference images and capture photos step by step. Upload as you go',
              buttonText: 'Start Guide',
              onButtonTap: () {
                controller.navigateToInstallationForm();
              },
            ),
          ),

          // Divider
          Container(width: 1, margin: const EdgeInsets.symmetric(horizontal: 40), color: AppColors.greyADB9BD),

          // Right Section: Upload and Organize from Library
          Expanded(
            child: _buildSection(
              icon: Assets.icons.icGallerySvg,
              title: 'Upload and Organize from Library',
              description:
                  'Upload all your photos at once into your media library. Then, simply drag and drop the right images into the form fields to complete submission',
              buttonText: 'Add to Media Library',
              onButtonTap: () {
                controller.navigateToMediaLibrary();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required SvgGenImage icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onButtonTap,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          icon.svg(),

          Gap(screenHeight * 0.035),

          // Title
          SizedBox(
            width: 350,
            child: AppText(title, style: AppTextStyle.extraBold30(color: AppColors.black002432)),
          ),

          Gap(screenHeight * 0.018),

          // Description
          AppText(description, maxLines: 3, style: AppTextStyle.regular16(color: AppColors.black002432)),

          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03),
            child: Container(height: 1, color: AppColors.greyADB9BD),
          ),
          CommonButton(
            text: buttonText,
            onTap: onButtonTap,
            color: AppColors.primaryColor,
            textColor: AppColors.black002432,
            width: 270,
            height: 56,
            padding: const EdgeInsets.only(left: 25),
            icon: Icons.arrow_forward_ios,
            showArrow: false,
          ),
        ],
      ),
    );
  }
}
