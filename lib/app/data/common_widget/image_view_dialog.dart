import '../../utils/exports.dart';

class ChecklistItem {
  final String title;
  final bool isCompleted;

  ChecklistItem({required this.title, required this.isCompleted});
}

class ImageViewDialog extends StatelessWidget {
  final String sectionTitle;
  final String imageTitle;
  final String imagePath;
  final bool isCompleted;
  final List<ChecklistItem>? otherItems;

  const ImageViewDialog({
    super.key,
    required this.sectionTitle,
    required this.imageTitle,
    required this.imagePath,
    required this.isCompleted,
    this.otherItems,
  });

  static void show(
    BuildContext context, {
    required String sectionTitle,
    required String imageTitle,
    required String imagePath,
    required bool isCompleted,
    List<ChecklistItem>? otherItems,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: isMobile ? 8 : 40),
          child: ImageViewDialog(
            sectionTitle: sectionTitle,
            imageTitle: imageTitle,
            imagePath: imagePath,
            isCompleted: isCompleted,
            otherItems: otherItems,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;

    // Responsive sizing
    final dialogWidth = isMobile ? screenWidth - 32 : screenWidth * 0.7;
    final dialogHeight = isMobile
        ? (screenHeight * 0.9).clamp(500.0, 800.0)
        : (screenHeight * 0.85).clamp(600.0, 900.0);

    return Container(
      width: dialogWidth,
      height: dialogHeight,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
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
                      width: isMobile ? 40 : 50,
                      height: isMobile ? 40 : 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.whiteColor,
                        border: Border.all(color: AppColors.greyADB9BD, width: 1.5),
                      ),
                      child: Icon(Icons.close, size: isMobile ? 20 : 25, color: AppColors.black002432),
                    ),
                  ),
                ),
                const Gap(16),
                // Section title with chevron
                Expanded(
                  child: Row(
                    children: [
                      AppText(
                        sectionTitle,
                        style: isMobile
                            ? AppTextStyle.extraBold24(color: AppColors.black002432)
                            : AppTextStyle.extraBold44(color: AppColors.black002432),
                      ),
                      const Gap(8),
                      Icon(Icons.keyboard_arrow_down, color: AppColors.black002432, size: isMobile ? 20 : 24),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main image area
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
              child: Column(
                children: [
                  // Large main image
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                      child: Image.asset(
                        imagePath,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const Gap(16),
                  // Image title with status indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(
                        imageTitle,
                        style: isMobile
                            ? AppTextStyle.regular16(color: AppColors.black002432)
                            : AppTextStyle.regular20(color: AppColors.black002432),
                      ),
                      const Gap(8),
                      isCompleted
                          ? Assets.icons.icCheckCircle.svg(width: isMobile ? 20 : 24, height: isMobile ? 20 : 24)
                          : Assets.icons.icCloseCircle.svg(width: isMobile ? 20 : 24, height: isMobile ? 20 : 24),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Other view options (if available)
          if (otherItems != null && otherItems!.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 0, isMobile ? 16 : 24, isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [const Gap(16), ...otherItems!.map((item) => _buildOtherViewOption(context, item, isMobile))],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOtherViewOption(BuildContext context, ChecklistItem item, bool isMobile) {
    // Reconstruct the full list: current item + other items, then exclude the clicked item
    final allItems = [ChecklistItem(title: imageTitle, isCompleted: isCompleted), ...(otherItems ?? [])];
    final updatedOtherItems = allItems
        .where((i) => i.title != item.title)
        .map((i) => ChecklistItem(title: i.title, isCompleted: i.isCompleted))
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Thumbnail
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              ImageViewDialog.show(
                context,
                sectionTitle: sectionTitle,
                imageTitle: item.title,
                imagePath: imagePath,
                // Using same image for now, can be customized
                isCompleted: item.isCompleted,
                otherItems: updatedOtherItems,
              );
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: isMobile ? 60 : 80,
                height: isMobile ? 60 : 80,
                decoration: BoxDecoration(
                  color: AppColors.greyADB9BD.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.black002432, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          const Gap(12),
          // Item title
          Expanded(
            child: AppText(
              item.title,
              style: isMobile
                  ? AppTextStyle.regular14(color: AppColors.black002432)
                  : AppTextStyle.regular16(color: AppColors.black002432),
            ),
          ),
          // Status indicator
          item.isCompleted
              ? Assets.icons.icCheckCircle.svg(width: isMobile ? 20 : 24, height: isMobile ? 20 : 24)
              : Assets.icons.icCloseCircle.svg(width: isMobile ? 20 : 24, height: isMobile ? 20 : 24),
        ],
      ),
    );
  }
}
