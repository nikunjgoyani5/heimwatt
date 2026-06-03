import 'package:image_network/image_network.dart';

import '../../utils/exports.dart';

class ReferenceImageInstructionsDialog extends StatelessWidget {
  const ReferenceImageInstructionsDialog({super.key, required this.image});

  final String image;

  static void show(BuildContext context, String refImage) {
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
          child: ReferenceImageInstructionsDialog(image: refImage),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing
    final isMobile = screenWidth < 600;
    final dialogWidth = isMobile ? screenWidth - 32 : (screenWidth * 0.48).clamp(600.0, 1200.0);
    final maxDialogHeight = isMobile ? screenHeight * 0.9 : screenHeight * 0.8;

    return Container(
      width: dialogWidth,
      constraints: BoxConstraints(maxHeight: maxDialogHeight),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [

          // Header with close button and title
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Row(
              children: [
                // Close button
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      width: isMobile ? 32 : 40,
                      height: isMobile ? 32 : 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.whiteColor,
                        border: Border.all(color: AppColors.greyADB9BD, width: 1.5),
                      ),
                      child: Icon(Icons.close, size: isMobile ? 18 : 20, color: AppColors.black002432),
                    ),
                  ),
                ),
                const Gap(16),
                // Title
                Expanded(child: AppText('Reference Image', style: AppTextStyle.extraBold28())),
              ],
            ),
          ),

          ///reference
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: AppColors.greenFAFFE9, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(Assets.icons.icForm.path, scale: 3),
                            const Gap(12),
                            AppText('Instruction', style: AppTextStyle.extraBold16()),

                            const Gap(12),
                            if (isMobile == false)
                              Expanded(
                                child: AppText(
                                  "We'll start with your floor plans. Take clear floor plans (all floors) with dimensions.",
                                  style: AppTextStyle.regular16(),
                                ),
                              ),
                          ],
                        ),
                        if (isMobile) ...[
                          Gap(10),
                          AppText(
                            "We'll start with your floor plans. Take clear floor plans (all floors) with dimensions.",
                            style: AppTextStyle.regular14(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Gap(15),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,

                      // height: isMobile ? 250 : 400,
                      decoration: BoxDecoration(color: AppColors.greenFAFFE9, borderRadius: BorderRadius.circular(16)),

                      child: Wrap(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: ImageNetwork(
                              image: image,
                              // height: isMobile ? 210 : 360,
                              height: maxDialogHeight - 300,
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Gap(15),
          /// Instructions content
          // Flexible(
          //   child: SingleChildScrollView(
          //     padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 0, isMobile ? 16 : 24, isMobile ? 24 : 32),
          //     child: ListView.separated(
          //       separatorBuilder: (context, index) {
          //         return Container(
          //           color: AppColors.greyADB9BD,
          //           margin: EdgeInsets.symmetric(vertical: 35),
          //           height: 1,
          //           width: double.infinity,
          //         );
          //       },
          //       shrinkWrap: true,
          //       itemCount: 3,
          //       itemBuilder: (context, index) {
          //         return Column(
          //           children: [
          //             Container(
          //               padding: const EdgeInsets.all(15),
          //               decoration: BoxDecoration(color: AppColors.greenFAFFE9, borderRadius: BorderRadius.circular(8)),
          //               child: Column(
          //                 children: [
          //                   Row(
          //                     crossAxisAlignment: CrossAxisAlignment.start,
          //                     children: [
          //                       Image.asset(Assets.icons.icForm.path, scale: 3),
          //                       const Gap(12),
          //                       AppText('Instruction', style: AppTextStyle.extraBold16()),
          //
          //                       const Gap(12),
          //                       if (isMobile == false)
          //                         Expanded(
          //                           child: AppText(
          //                             "We'll start with your floor plans. Take clear floor plans (all floors) with dimensions.",
          //                             style: AppTextStyle.regular16(),
          //                           ),
          //                         ),
          //                     ],
          //                   ),
          //                   if (isMobile) ...[
          //                     Gap(10),
          //                     AppText(
          //                       "We'll start with your floor plans. Take clear floor plans (all floors) with dimensions.",
          //                       style: AppTextStyle.regular14(),
          //                     ),
          //                   ],
          //                 ],
          //               ),
          //             ),
          //             Gap(15),
          //             Container(
          //               padding: EdgeInsets.all(20),
          //               alignment: Alignment.center,
          //               width: MediaQuery.of(context).size.width,
          //               height: isMobile ? 250 : 400,
          //               decoration: BoxDecoration(
          //                 color: AppColors.greenFAFFE9,
          //                 borderRadius: BorderRadius.circular(16),
          //               ),
          //
          //               child: Wrap(
          //                 children: [
          //                   ClipRRect(
          //                     borderRadius: BorderRadius.circular(16),
          //                     child: Image.asset(
          //                       Assets.images.referenceImage.path,
          //                       fit: BoxFit.cover,
          //                       height: isMobile ? 210 : 360,
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           ],
          //         );
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
