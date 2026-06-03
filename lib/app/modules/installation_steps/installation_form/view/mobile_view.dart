import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_form/models/installation_step_model.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_form/view/pdf_preview_view_mobile.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_form/view/upload_images_view_mobile.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_steps_controller.dart';
import 'package:heimwatt/app/utils/pref_service.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../utils/exports.dart';

class InstallationFormMobileView extends StatelessWidget {
  const InstallationFormMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return GetBuilder<InstallationStepsController>(
      builder: (controller) {
        if (controller.ispdf) {
          return const PdfPreviewViewMobile();
        }
        // Show upload view if isUpload is true
        if (controller.isUpload) {
          return const UploadImagesViewMobile();
        }

        // Otherwise show the cards list with Firebase data
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                final userRole = controller.userRole.value;
                final isCustomer = userRole.toLowerCase() == 'customer';

                // For customers, show "Show PDF" button if PDF exists
                // if (isCustomer) {
                //   return CommonButton(
                //     textColor: AppColors.greyADB9BD,
                //     hoverColor: AppColors.lightThemeColor,
                //     color: AppColors.lightThemeColor,
                //     width: double.infinity,
                //     onTap: () {
                //       // controller.showPdfForCustomer(context: context);
                //     },
                //     text: "",
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
                        textColor: AppColors.greyADB9BD,
                        // color: AppColors.lightThemeColor,
                        width: double.infinity,
                        onTap: () {
                          // controller.setPdfView(true)
                          controller.generateAndUploadPdf(context: context);
                        },
                        text: "",
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(AppStrings.generatePdf, style: AppTextStyle.semiBold16(color: AppColors.black002432)),
                            const Gap(12),
                            Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.black002432),
                          ],
                        ),
                      );
              }),
              SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  if (controller.showInstallationFormScreen) {
                    controller.showInstallationFormScreen = false;
                    controller.showMediaLibraryScreen = true;
                    controller.update();
                  } else {
                    controller.showInstallationFormScreen = true;
                    controller.showMediaLibraryScreen = false;
                    controller.update();
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.greyADB9BD),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(Assets.icons.icGalleryPng.path, scale: 3),
                      const Gap(6),
                      Text(AppStrings.switchToBulkUpload, style: AppTextStyle.medium14()),
                    ],
                  ),
                ),
              ),
              const Gap(25),

              Row(
                children: [
                  // InkWell(
                  //   onTap: () {
                  //     context.pop();
                  //   },
                  //   child: Container(
                  //     width: 40,
                  //     height: 40,
                  //     decoration: BoxDecoration(
                  //       color: AppColors.whiteColor,
                  //       shape: BoxShape.circle,
                  //       border: Border.all(color: AppColors.greyADB9BD),
                  //     ),
                  //     child: Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.black002432),
                  //   ),
                  // ),
                  // const Gap(12),
                  Expanded(child: AppText(AppStrings.installationForm, style: AppTextStyle.extraBold28())),
                ],
              ),
              const Gap(16),

              if (controller.showInstallationFormScreen || controller.showMediaLibraryScreen)
                FutureBuilder<StepStatusResult>(
                  future: controller.fetchStepStatuses(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox();
                    }

                    if (snapshot.hasError) {
                      return SizedBox();
                    }

                    final data = snapshot.data;
                    final stepCount = data?.stepCount ?? 0;
                    final statuses = data?.statuses ?? const <StepStatus>[];

                    return _buildStepProgress(stepCount: stepCount, statuses: statuses);
                  },
                ),
              const Gap(24),
              // Cards List with StreamBuilder
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection(PrefService.getString(PrefService.dealName)).limit(1).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show shimmer loading cards
                    return Column(
                      children: List.generate(6, (index) {
                        return Padding(padding: const EdgeInsets.only(bottom: 16), child: _buildShimmerCard(width));
                      }),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AppText(
                          'Error loading data: ${snapshot.error}',
                          style: AppTextStyle.medium16(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AppText('No data found!!!', style: AppTextStyle.medium16(color: AppColors.black002432)),
                      ),
                    );
                  }

                  // Get the first document
                  final doc = snapshot.data!.docs.first;
                  final data = doc.data() as Map<String, dynamic>;

                  // Extract steps array
                  final steps = data['steps'] as List<dynamic>?;

                  if (steps == null || steps.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AppText('No data found!!!', style: AppTextStyle.medium16(color: AppColors.black002432)),
                      ),
                    );
                  }

                  // Convert steps to card data
                  final cards = _convertStepsToCardData(steps);

                  return Column(
                    children: cards.map((cardData) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildCard(cardData, controller, width, context),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepProgress({required int stepCount, required List<StepStatus> statuses}) {
    if (stepCount <= 0) {
      return const SizedBox();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(stepCount, (index) {
          final status = index < statuses.length ? statuses[index] : StepStatus.empty;
          Color stepColor;
          switch (status) {
            case StepStatus.complete:
              stepColor = AppColors.primaryColor;
              break;
            case StepStatus.partial:
              stepColor = Colors.red;
              break;
            case StepStatus.empty:
            default:
              stepColor = AppColors.greyADB9BD;
          }

          return [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: stepColor, shape: BoxShape.circle),
              child: Center(
                child: AppText('${index + 1}', style: AppTextStyle.semiBold16(color: AppColors.whiteColor)),
              ),
            ),
            if (index < stepCount - 1) const Gap(8),
          ];
        }).expand((widgets) => widgets),
      ],
    );
  }

  Widget _buildCard(
    Map<String, dynamic> cardData,
    InstallationStepsController controller,
    double width,
    BuildContext context,
      ) {
    int cardIndex = cardData['index'] as int;
    int progress = controller.cardProgress[cardIndex] ?? 0;
    String? videoUrl = cardData['infoVideo'] as String?;

    return InkWell(

      onTap: () {
        final stepIndex = (cardData['index'] as int? ?? 1) - 1; // Convert to 0-based index
        controller.setUploadView(true, cardTitle: cardData['title'] as String? ?? '', stepIndex: stepIndex);
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.whiteColor, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            InkWell(
              onTap: () => InstructionVideoDialog.show(context, videoUrl: videoUrl),
              child: Icon(Icons.info_outline, size: 20, color: AppColors.black002432),
            ),

            const Gap(12),
            // Title
            Expanded(child: Text(cardData['title'] as String? ?? 'No Title', style: AppTextStyle.extraBold18())),
            const Gap(12),
            // Progress Indicator with Dashed Circle
            // _buildProgressIndicator(progress, controller.totalItemsPerCard),
            // const Gap(12),
            // Navigation Arrow Button
            InkWell(
              onTap: () {
                final stepIndex = (cardData['index'] as int? ?? 1) - 1; // Convert to 0-based index
                controller.setUploadView(true, cardTitle: cardData['title'] as String? ?? '', stepIndex: stepIndex);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
                child: Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.black002432),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int progress, int total) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Segmented Circle
          CustomPaint(
            size: const Size(50, 50),
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

  Widget _buildShimmerCard(double width) {
    return Shimmer.fromColors(
      baseColor: AppColors.greyADB9BD.withOpacity(0.3),
      highlightColor: AppColors.greyADB9BD.withOpacity(0.1),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.whiteColor, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(color: AppColors.greyADB9BD, shape: BoxShape.circle),
            ),
            const Gap(12),
            Expanded(
              child: Container(
                height: 20,
                decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const Gap(12),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: AppColors.greyADB9BD, shape: BoxShape.circle),
            ),
            const Gap(12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.greyADB9BD, shape: BoxShape.circle),
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
        width: double.infinity,
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
    final totalAngle = 2 * 3.14159;
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
