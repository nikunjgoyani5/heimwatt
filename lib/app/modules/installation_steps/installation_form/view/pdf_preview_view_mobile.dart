// Web-only imports  Molie view
import 'dart:html' as html show AnchorElement;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:heimwatt/app/modules/installation_steps/installation_steps_controller.dart';

import '../../../../data/common_widget/thank_you_dialog.dart';
import '../../../../utils/exports.dart';
import 'installation_pdf_viewer.dart';

class PdfPreviewViewMobile extends StatelessWidget {
  const PdfPreviewViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InstallationStepsController>(
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Row - Back button, Title, and Action Buttons
            Row(
              children: [
                // Back Button
                InkWell(
                  onTap: () => {controller.setPdfView(false)},

                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ClipOval(
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.greyADB9BD),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_outlined, color: AppColors.black002432, size: 15),
                      ),
                    ),
                  ),
                ),
                const Gap(20),
                // PDF Preview Title
                AppText(AppStrings.pdfPreview, style: AppTextStyle.extraBold28()),
                const Spacer(),

                // Upload to HubSpot Button
              ],
            ),

            const Gap(24),
            // PDF Preview Container
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(AppStrings.installationReport, style: AppTextStyle.semiBold16(color: AppColors.black002432)),
                  AppText('${controller.totalPdfPage} ${AppStrings.pages}', style: AppTextStyle.medium14(color: AppColors.greyADB9BD)),
                ],
              ),
            ),
            // PDF Viewer
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(color: AppColors.whiteColor),
                child: InstallationPdfViewer(
                  networkUrl: controller.pdfNetworkUrl!,
                  memoryBytes: controller.pdfBytes,
                  onDocumentLoaded: (details) {
                    final totalPages = details.document.pages.count;
                    debugPrint('Total pages: $totalPages');
                    controller.totalPdfPage = totalPages;
                    controller.update();
                  },
                ),
               /* FutureBuilder<Uint8List>(
                  future: loadPdfBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                      return Center(
                        child: AppText('Error loading PDF', style: AppTextStyle.medium14(color: AppColors.black002432)),
                      );
                    }
                    return
                    // AppText(
                    //   ' PDF DONE',
                    //   style: AppTextStyle.medium14(color: AppColors.black002432),
                    // );
                    SfPdfViewer.memory(snapshot.data!, key: pdfViewerKey);
                  },
                ),*/
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 24,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
              ),
            ),
            const Gap(16),
            Obx(() {
              if (controller.isUploadingToHubSpot.value) {
                return _buildHorizontalProgressBar(controller.hubSpotUploadProgress.value);
              }
              return InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () async {
                  await controller.uploadToHubSpot(context: context);
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.greyADB9BD),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(Assets.icons.icHubspot.path, scale: 3),
                        const Gap(16),
                        Text(AppStrings.uploadToHubSpot,
                            style: AppTextStyle.semiBold16(color: AppColors.black002432)),
                      ],
                    ),
                  ),
                ),
              );
            }),
            // Download PDF Button - Only show for non-customers
            Obx(() {
              final userRole = controller.userRole.value;
              final isCustomer = userRole.toLowerCase() == 'customer';
              
              if (isCustomer) {
                return const SizedBox.shrink();
              }
              
              return Column(
                children: [
                  const Gap(16),
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      // Handle download PDF
                      ThankYouDialog.show(context);
                      _downloadPdf(controller.pdfNetworkUrl);
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(24)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(Assets.icons.icDownload.path, scale: 3),
                            const Gap(16),
                            Text(AppStrings.downloadPdf, style: AppTextStyle.semiBold16(color: AppColors.black002432)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        );
      },
    );
  }

  void _downloadPdf(String? pdfUrl) {
    if (kIsWeb && pdfUrl != null && pdfUrl.isNotEmpty) {
      html.AnchorElement(href: pdfUrl)
        ..download = 'Installation Report.pdf'
        ..click();
    }
  }
}

Widget _buildHorizontalProgressBar(double progress) {
  final clamped = progress.clamp(0.0, 1.0);
  final progressPercent = (clamped * 100).round();

  return LayoutBuilder(
    builder: (context, constraints) {
      final maxWidth = constraints.maxWidth == double.infinity ? MediaQuery.of(context).size.width : constraints.maxWidth;

      return Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: maxWidth * clamped,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            ),
            Center(
              child: Text('$progressPercent%', style: AppTextStyle.semiBold14(color: AppColors.black002432)),
            ),
          ],
        ),
      );
    },
  );
}
