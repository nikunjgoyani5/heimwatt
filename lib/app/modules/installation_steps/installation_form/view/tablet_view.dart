import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_form/models/installation_step_model.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_form/view/pdf_preview_view_tablet.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_form/view/upload_images_view_tablet.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_steps_controller.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../utils/exports.dart';
import '../../../../utils/pref_service.dart';

class InstallationFormTabletView extends StatelessWidget {
  const InstallationFormTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return GetBuilder<InstallationStepsController>(
      builder: (controller) {
        // Show PDF preview if ispdf is true
        if (controller.ispdf) {
          return const PdfPreviewViewTablet();
        }

        // Show upload view if isUpload is true
        if (controller.isUpload) {
          return const UploadImagesViewTablet();
        }

        // Otherwise show the grid view with Firebase data
        return SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.installationForm,
                      style: AppTextStyle.extraBold40(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  Obx(() {
                    final userRole = controller.userRole.value;
                    final isCustomer = userRole.toLowerCase() == 'customer';

                    // For customers, show "Show PDF" button if PDF exists
                    // if (isCustomer) {
                    //   return CommonButton(
                    //     color: AppColors.lightThemeColor,
                    //     hoverColor: AppColors.lightThemeColor,
                    //
                    //     width: 300,
                    //     onTap: () {
                    //       // controller.showPdfForCustomer(context: context);
                    //     },
                    //     text: '',
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         Text(AppStrings.showPdf, style: AppTextStyle.semiBold16(color: AppColors.greyADB9BD)),
                    //         const Gap(12),
                    //         Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.greyADB9BD),
                    //       ],
                    //     ),
                    //   );
                    // }

                    // For non-customers, show "Generate PDF" button
                    return controller.isGeneratingPdf.value
                        ? _buildHorizontalProgressBar(controller.pdfGenerationProgress.value)
                        : CommonButton(
                            borderRadius: BorderRadius.circular(32),
                            width: 300,
                            onTap: () {
                              controller.generateAndUploadPdf(context: context);
                            },
                            text: AppStrings.generatePdf,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppStrings.generatePdf,
                                  style: AppTextStyle.semiBold16(color: AppColors.black002432),
                                ),
                                const Gap(12),
                                Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.black002432),
                              ],
                            ),
                          );
                  }),
                ],
              ),
              const Gap(30),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection(PrefService.getString(PrefService.dealName)).limit(1).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show shimmer loading cards
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: _calculateAspectRatio(width),
                      ),
                      itemCount: 6,
                      // Show 6 shimmer cards
                      itemBuilder: (context, index) {
                        return _buildShimmerCard(width);
                      },
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: AppText(
                        'Error loading data: ${snapshot.error}',
                        style: AppTextStyle.medium16(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: AppText('No data found!!!', style: AppTextStyle.medium16(color: AppColors.black002432)),
                    );
                  }

                  // Get the first document
                  final doc = snapshot.data!.docs.first;
                  final data = doc.data() as Map<String, dynamic>;

                  // Extract steps array
                  final steps = data['steps'] as List<dynamic>?;

                  if (steps == null || steps.isEmpty) {
                    return Center(
                      child: AppText('No data found!!!', style: AppTextStyle.medium16(color: AppColors.black002432)),
                    );
                  }

                  // Convert steps to card data
                  final cards = _convertStepsToCardData(steps);

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: _calculateAspectRatio(width),
                    ),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      return buildCard(context, cards[index], controller, width);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCard(
    BuildContext context,
    Map<String, dynamic> cardData,
    InstallationStepsController controller,
    double screenWidth,
  ) {
    int cardIndex = cardData['index'] as int;
    int progress = controller.cardProgress[cardIndex] ?? 0;
    String? videoUrl = cardData['infoVideo'] as String?;

    // Calculate responsive sizes based on screen width
    double cardWidth = _calculateCardWidth(screenWidth);
    double iconSize = _calculateIconSize(cardWidth);
    double padding = _calculatePadding(cardWidth);
    double titleFontSize = _calculateTitleFontSize(cardWidth);
    double descriptionFontSize = _calculateDescriptionFontSize(cardWidth);
    double iconButtonSize = _calculateIconButtonSize(cardWidth);
    double buttonWidth = _calculateButtonWidth(cardWidth);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(color: AppColors.whiteColor, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use default icon if no icon provided from Firebase
              if (cardData['icon'] != null)
                Image.asset(cardData['icon'] as String, width: iconSize, height: iconSize, fit: BoxFit.contain)
              else
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: AppColors.greyADB9BD.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              // _buildProgressIndicator(progress, controller.totalItemsPerCard, iconSize * 0.8),
            ],
          ),
          Gap(10),

          Expanded(
            child: SizedBox(
              height: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    cardData['title'] as String? ?? 'No Title',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black002432,
                    ),
                  ),

                  AppText(
                    cardData['description'] as String? ?? '',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: descriptionFontSize,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black002432,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          Container(height: 1.5, color: AppColors.greyADB9BD, width: double.infinity),
          Gap(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => InstructionVideoDialog.show(context, videoUrl: videoUrl),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: iconButtonSize,
                    height: iconButtonSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.whiteColor,
                      border: Border.all(color: AppColors.greyADB9BD),
                    ),
                    child: Icon(Icons.info_outline, size: iconButtonSize * 0.6, color: AppColors.black002432),
                  ),
                ),
              ),
              CommonButton(
                text: AppStrings.upload,
                onTap: () {
                  final stepIndex = (cardData['index'] as int? ?? 1) - 1; // Convert to 0-based index
                  controller.setUploadView(true, cardTitle: cardData['title'] as String? ?? '', stepIndex: stepIndex);
                },
                color: AppColors.primaryColor,
                textColor: AppColors.black002432,
                width: buttonWidth,
                height: screenWidth < 1100 ? 40 : 56,
                padding: EdgeInsets.symmetric(horizontal: screenWidth < 1100 ? 10 : 18),
                icon: Icons.arrow_forward_ios,
                showArrow: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateAspectRatio(double screenWidth) {
    // Calculate available width for grid (screen width - padding on both sides)
    const double horizontalPadding = 20.0 * 2; // padding from SingleChildScrollView
    const int crossAxisCount = 2;
    const double crossAxisSpacing = 20.0;

    // Available width for the grid
    double availableWidth = screenWidth - horizontalPadding;

    // Calculate width of each card
    // Total spacing between columns = crossAxisSpacing * (crossAxisCount - 1)
    double totalSpacing = crossAxisSpacing * (crossAxisCount - 1);
    double cardWidth = (availableWidth - totalSpacing) / crossAxisCount;

    // Calculate aspect ratio based on card width
    // Adjust aspect ratio proportionally to width for responsive design
    // Base calculation: maintain proportional sizing, adjust for wider screens
    double baseAspectRatio = 1.2;

    // Scale aspect ratio based on card width
    // For wider cards (larger screens), slightly increase aspect ratio
    // For narrower cards (smaller screens), maintain base ratio
    double widthFactor = cardWidth / 300.0; // Normalize to a base width of 300
    double aspectRatio = baseAspectRatio * (0.9 + (widthFactor * 0.1));

    // Ensure aspect ratio stays within reasonable bounds
    return aspectRatio.clamp(1.1, 1.6);
  }

  double _calculateCardWidth(double screenWidth) {
    const double horizontalPadding = 20.0 * 2;
    const int crossAxisCount = 2;
    const double crossAxisSpacing = 20.0;
    double availableWidth = screenWidth - horizontalPadding;
    double totalSpacing = crossAxisSpacing * (crossAxisCount - 1);
    return (availableWidth - totalSpacing) / crossAxisCount;
  }

  double _calculateIconSize(double cardWidth) {
    // Icon size scales with card width (base: 50px for ~400px card width)
    double baseSize = 50.0;
    double baseCardWidth = 400.0;
    double iconSize = (cardWidth / baseCardWidth) * baseSize;
    return iconSize.clamp(35.0, 60.0);
  }

  double _calculatePadding(double cardWidth) {
    // Padding scales with card width (base: 20px for ~400px card width)
    double basePadding = 20.0;
    double baseCardWidth = 400.0;
    double padding = (cardWidth / baseCardWidth) * basePadding;
    return padding.clamp(15.0, 25.0);
  }

  double _calculateTitleFontSize(double cardWidth) {
    // Title font size scales with card width (base: 28px for ~400px card width)
    double baseFontSize = 28.0;
    double baseCardWidth = 400.0;
    double fontSize = (cardWidth / baseCardWidth) * baseFontSize;
    return fontSize.clamp(20.0, 32.0);
  }

  double _calculateDescriptionFontSize(double cardWidth) {
    // Description font size scales with card width (base: 18px for ~400px card width)
    double baseFontSize = 18.0;
    double baseCardWidth = 400.0;
    double fontSize = (cardWidth / baseCardWidth) * baseFontSize;
    return fontSize.clamp(14.0, 22.0);
  }

  double _calculateIconButtonSize(double cardWidth) {
    // Icon button size scales with card width (base: 46px for ~400px card width)
    double baseSize = 46.0;
    double baseCardWidth = 400.0;
    double buttonSize = (cardWidth / baseCardWidth) * baseSize;
    return buttonSize.clamp(35.0, 55.0);
  }

  double _calculateButtonWidth(double cardWidth) {
    // Button width scales with card width (base: 150px for ~400px card width)
    double baseWidth = 150.0;
    double baseCardWidth = 400.0;
    double buttonWidth = (cardWidth / baseCardWidth) * baseWidth;
    return buttonWidth.clamp(120.0, 180.0);
  }

  Widget _buildProgressIndicator(int progress, int total, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Segmented Circle
          CustomPaint(
            size: Size(size, size),
            painter: SegmentedCirclePainter(
              progress: progress,
              total: total,
              completedColor: AppColors.primaryColor,
              uncompletedColor: AppColors.greyADB9BD,
              strokeWidth: 5,
            ),
          ),
          // Progress Text
          AppText('$progress/$total', style: AppTextStyle.semiBold14(color: AppColors.black002432)),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _convertStepsToCardData(List<dynamic> steps) {
    // Default icons mapping (fallback if needed)
    final defaultIcons = [
      Assets.images.roof.path,
      Assets.images.roofConstruction.path,
      Assets.images.inverter.path,
      Assets.images.meterCabinet.path,
      Assets.images.earth.path,
      Assets.images.cable.path,
      Assets.images.other.path,
    ];

    return steps.asMap().entries.map((entry) {
      final index = entry.key;
      final stepValue = entry.value;
      if (stepValue is! Map<String, dynamic>) {
        // Skip invalid step data
        return {
          'index': index + 1,
          'title': 'Invalid Step',
          'description': '',
          'infoVideo': null,
          'icon': index < defaultIcons.length ? defaultIcons[index] : null,
        };
      }
      final stepData = stepValue as Map<String, dynamic>;
      final step = InstallationStep.fromMap(stepData);

      return {
        'index': index + 1,
        'title': step.title ?? 'No Title',
        'description': step.des ?? '',
        'infoVideo': step.infoVideo,
        'icon': index < defaultIcons.length ? defaultIcons[index] : null,
      };
    }).toList();
  }

  Widget _buildShimmerCard(double screenWidth) {
    double cardWidth = _calculateCardWidth(screenWidth);
    double padding = _calculatePadding(cardWidth);

    return Shimmer.fromColors(
      baseColor: AppColors.greyADB9BD.withOpacity(0.3),
      highlightColor: AppColors.greyADB9BD.withOpacity(0.1),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(color: AppColors.whiteColor, borderRadius: BorderRadius.circular(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(8)),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: AppColors.greyADB9BD, shape: BoxShape.circle),
                ),
              ],
            ),
            const Gap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 24,
                    decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(4)),
                  ),
                  const Gap(12),
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(4)),
                  ),
                  const Gap(8),
                  Container(
                    width: 150,
                    height: 16,
                    decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
            ),
            Container(height: 1.5, color: AppColors.greyADB9BD, width: double.infinity),
            const Gap(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: AppColors.greyADB9BD, shape: BoxShape.circle),
                ),
                Container(
                  width: 150,
                  height: 56,
                  decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildHorizontalProgressBar(double progress) {
  final progressPercent = (progress * 100).toInt();

  return LayoutBuilder(
    builder: (context, constraints) {
      return Container(
        width: 300,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Stack(
          children: [
            // Progress fill
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(22)),
                  ),
                ),
              ),
            ),
            // Percentage text
            Center(
              child: Text('$progressPercent%', style: AppTextStyle.semiBold14(color: AppColors.black002432)),
            ),
          ],
        ),
      );
    },
  );
}

// Custom Painter for Segmented Circle Progress Indicator
class SegmentedCirclePainter extends CustomPainter {
  final int progress;
  final int total;
  final Color completedColor;
  final Color uncompletedColor;
  final double strokeWidth;
  final double gapAngle;

  SegmentedCirclePainter({
    required this.progress,
    required this.total,
    required this.completedColor,
    required this.uncompletedColor,
    this.strokeWidth = 3.0,
    this.gapAngle = 0.5, // Gap between segments in radians
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Calculate angle for each segment
    final totalAngle = 2 * 3.14159; // Full circle
    final segmentAngle = (totalAngle - (total * gapAngle)) / total;

    // Start from top (12 o'clock position)
    double startAngle = -3.14159 / 2; // Start at top

    for (int i = 0; i < total; i++) {
      final isCompleted = i < progress;
      final color = isCompleted ? completedColor : uncompletedColor;

      final paint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Draw segment arc
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, segmentAngle, false, paint);

      // Move to next segment (add segment angle + gap)
      startAngle += segmentAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant SegmentedCirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.total != total ||
        oldDelegate.completedColor != completedColor ||
        oldDelegate.uncompletedColor != uncompletedColor;
  }
}
