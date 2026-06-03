import '../../../../utils/exports.dart';
import '../../installation_steps_controller.dart';

class StepTypeMobile extends StatefulWidget {
  const StepTypeMobile({super.key});

  @override
  State<StepTypeMobile> createState() => _StepTypeMobileState();
}

class _StepTypeMobileState extends State<StepTypeMobile> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InstallationStepsController>();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button
          /*InkWell(
            onTap: () {
              // Handle back action
            },
            child: ClipOval(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.greyADB9BD),
                ),
                child: const Icon(Icons.arrow_back_ios_new_outlined, color: AppColors.black002432, size: 15),
              ),
            ),
          ),
          const Gap(30),*/

          // First Section: Step-by-Step Installation Form
          _buildSection(
            icon: Assets.icons.icScanner,
            title: 'Step-by-Step Installation Form',
            description:
                'Follow clear instructions, check reference images and capture photos step by step. Upload as you go',
            buttonText: 'Start Guide',
            onButtonTap: () {
              controller.navigateToInstallationForm();
            },
          ),

          const Gap(30),

          // Separator with "or"
          Row(
            children: [
              Expanded(
                child: CustomPaint(painter: DashedLinePainter(), size: const Size(double.infinity, 1)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppText('or', style: AppTextStyle.regular16(color: AppColors.black002432)),
              ),
              Expanded(
                child: CustomPaint(painter: DashedLinePainter(), size: const Size(double.infinity, 1)),
              ),
            ],
          ),

          const Gap(30),

          // Second Section: Upload and Organize from Library
          _buildSection(
            icon: Assets.icons.icGallerySvg,
            title: 'Upload and Organize from Library',
            description:
                'Upload all your photos at once into your media library. Then, simply drag and drop the right images into the form fields to complete submission',
            buttonText: 'Add to Media Library',
            onButtonTap: () {
              controller.navigateToMediaLibrary();
            },
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        icon.svg(),

        const Gap(30),

        // Title
        AppText(title, style: AppTextStyle.extraBold30(color: AppColors.black002432)),

        const Gap(16),

        // Description
        AppText(description, style: AppTextStyle.regular16(color: AppColors.black002432)),

        const Gap(25),

        // Button
        CommonButton(
          text: buttonText,
          onTap: onButtonTap,
          color: AppColors.primaryColor,
          textColor: AppColors.black002432,
          width: double.infinity,
          height: 56,
          padding: const EdgeInsets.only(left: 25),
          icon: Icons.arrow_forward_ios,
          showArrow: false,
        ),
      ],
    );
  }
}

// Custom painter for dashed line
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.greyADB9BD
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
