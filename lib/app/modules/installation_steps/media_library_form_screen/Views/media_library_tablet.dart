import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:heimwatt/app/data/common_widget/edit_image_dialog.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_steps_controller.dart';
import 'package:heimwatt/app/utils/pref_service.dart';
import 'package:heimwatt/app/utils/app_functions.dart';
import 'package:image_network/image_network.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';

import '../../../../utils/exports.dart';

class MediaLibraryTablet extends StatefulWidget {
  const MediaLibraryTablet({super.key});

  @override
  State<MediaLibraryTablet> createState() => _MediaLibraryTabletState();
}

class _MediaLibraryTabletState extends State<MediaLibraryTablet> {
  DropzoneViewController? _dropzoneController;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InstallationStepsController>(
      builder: (controller) {
        final mediaLibraryImages = controller.mediaLibraryImages;
        final hasImages = mediaLibraryImages.isNotEmpty;

        return CommonScrollable(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(controller),
              const Gap(32),

              // Upload Zone
              _buildUploadZone(controller),
              const Gap(32),

              // Images Grid or Empty State
              _buildImagesGrid(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(InstallationStepsController controller) {
    return Row(
      children: [
        // Back Button
        InkWell(
          onTap: () {
            controller.navigateToInstallationForm();
          },
          mouseCursor: SystemMouseCursors.click,
          child: ClipOval(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.greyADB9BD),
              ),
              child: const Icon(Icons.arrow_back_ios_new_outlined, color: AppColors.black002432, size: 14),
            ),
          ),
        ),
        const Gap(12),

        // Title
        AppText('Media Library', style: AppTextStyle.extraBold40(color: AppColors.black002432)),

        const Spacer(),

        // Play Icon Button
        InkWell(
          onTap: () {
            InstructionVideoDialog.show(context, videoUrl: controller.instructionVideo);
          },
          mouseCursor: SystemMouseCursors.click,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.greyADB9BD),
            ),
            child: Icon(CupertinoIcons.play_arrow, color: AppColors.black002432, size: 18),
          ),
        ),
        const Gap(10),

        CommonButton(
          text: 'Checklist',
          onTap: () {
            controller.toggleChecklistDrawer();
          },
          color: AppColors.primaryColor,
          textColor: AppColors.black002432,
          height: 44,
          width: 130,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.greyADB9BD),
          showArrow: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.black002432),
                ),
                child: const Icon(Icons.check, color: AppColors.black002432, size: 12),
              ),
              const Gap(6),
              Text('Checklist', style: AppTextStyle.semiBold14(color: AppColors.black002432)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadZone(InstallationStepsController controller) {
    final imageCount = controller.mediaLibraryImages.length;
    final maxImages = 25;
    final isDisabled = imageCount >= maxImages;

    // Use DropzoneView for web, InkWell for mobile/tablet
    if (kIsWeb) {
      DropzoneViewController? dragController;

      return DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: const Radius.circular(20),
          dashPattern: const [10, 10],
          color: isDisabled ? AppColors.greyADB9BD : AppColors.purpleColor,
        ),
        child: Container(
          width: double.infinity,
          height: 300,
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: Stack(
            children: [
              // Dropzone overlay
              DropzoneView(
                operation: DragOperation.copy,
                cursor: CursorType.grab,
                onCreated: (DropzoneViewController ctrl) {
                  dragController = ctrl;
                },
                onDropFiles: (files) async {
                  if (isDisabled || files == null || files.isEmpty || dragController == null) return;

                  try {
                    // Get existing bulk_import count from Firebase
                    final userId = PrefService.getString(PrefService.userId);
                    if (userId.isEmpty) {
                      if (context.mounted) {
                        AppFunctions.showToast(message: 'User ID not found', toastType: ToastificationType.error);
                      }
                      return;
                    }

                    final projectRef = await FirebaseFirestore.instance
                        .collection('project')
                        .where('user_id', isEqualTo: userId)
                        .limit(1)
                        .get();

                    int existingCount = 0;
                    if (projectRef.docs.isNotEmpty) {
                      final projectData = projectRef.docs.first.data();
                      final bulkImport = projectData['bulk_import'];
                      if (bulkImport != null) {
                        if (bulkImport is List) {
                          existingCount = bulkImport.length;
                        } else if (bulkImport is Map) {
                          existingCount = bulkImport.length;
                        }
                      }
                    }

                    final remainingSlots = maxImages - existingCount;
                    if (remainingSlots <= 0) {
                      if (context.mounted) {
                        AppFunctions.showToast(
                          message: 'Maximum image limit ($maxImages) reached',
                          toastType: ToastificationType.error,
                        );
                      }
                      return;
                    }

                    // Process dropped files
                    final List<UploadedImage> filesToAdd = [];
                    for (final file in files.take(remainingSlots)) {
                      try {
                        final name = await dragController!.getFilename(file);
                        final bytes = await dragController!.getFileData(file);
                        
                        // Check if it's a valid image format
                        final extension = name.split('.').last.toLowerCase();
                        if (['png', 'jpg', 'jpeg'].contains(extension)) {
                          filesToAdd.add(UploadedImage(name: name, bytes: bytes));
                        }
                      } catch (e) {
                        debugPrint('Error processing dropped file: $e');
                      }
                    }

                    if (filesToAdd.isEmpty) {
                      if (context.mounted) {
                        AppFunctions.showToast(
                          message: 'No valid images found',
                          toastType: ToastificationType.error,
                        );
                      }
                      return;
                    }

                    await controller.submitMediaLibraryImages(context: context, images: filesToAdd);
                  } catch (e) {
                    debugPrint('Error handling dropped files: $e');
                    if (context.mounted) {
                      AppFunctions.showToast(
                        message: 'Error processing dropped files: $e',
                        toastType: ToastificationType.error,
                      );
                    }
                  }
                },
              ),
              // Content overlay
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Purple circle with plus icon
                      DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          radius: const Radius.circular(70),
                          dashPattern: const [10, 10],
                          color: isDisabled ? AppColors.greyADB9BD : AppColors.purpleColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: isDisabled ? AppColors.greyADB9BD : AppColors.purpleColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: AppColors.whiteColor, size: 28),
                          ),
                        ),
                      ),
                      const Gap(14),
                      AppText(
                        AppStrings.dragAndDropOrSelectFile,
                        style: AppTextStyle.extraBold14(color: isDisabled ? AppColors.greyADB9BD : AppColors.black002432),
                      ),
                      if (isDisabled) ...[
                        const Gap(8),
                        AppText(
                          'You reached max 25 image limit',
                          style: AppTextStyle.regular14(color: AppColors.grey78797A),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              // Clickable area for file picker
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: isDisabled
                      ? null
                      : () async {
                          await controller.pickMediaLibraryImages(context: context);
                        },
                  child: IgnorePointer(
                    child: Container(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Mobile/Tablet: Use InkWell with file picker
      return InkWell(
        onTap: isDisabled
            ? null
            : () async {
                await controller.pickMediaLibraryImages(context: context);
              },
        mouseCursor: isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            radius: const Radius.circular(20),
            dashPattern: const [10, 10],
            color: isDisabled ? AppColors.greyADB9BD : AppColors.purpleColor,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Purple circle with plus icon
                DottedBorder(
                  options: RoundedRectDottedBorderOptions(
                    radius: const Radius.circular(70),
                    dashPattern: const [10, 10],
                    color: isDisabled ? AppColors.greyADB9BD : AppColors.purpleColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: isDisabled ? AppColors.greyADB9BD : AppColors.purpleColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: AppColors.whiteColor, size: 28),
                    ),
                  ),
                ),
                const Gap(14),
                AppText(
                  AppStrings.dragAndDropOrSelectFile,
                  style: AppTextStyle.extraBold14(color: isDisabled ? AppColors.greyADB9BD : AppColors.black002432),
                ),
                if (isDisabled) ...[
                  const Gap(8),
                  AppText('You reached max 25 image limit', style: AppTextStyle.regular14(color: AppColors.grey78797A)),
                ],
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildImagesGrid(InstallationStepsController controller) {
    final userId = PrefService.getString(PrefService.userId);
    if (userId.isEmpty) {
      return _buildEmptyState();
    }

    // Initialize future if not already set
    if (controller.mediaLibraryFuture == null) {
      controller.mediaLibraryFuture = controller.loadMediaLibraryImages();
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: controller.mediaLibraryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show shimmer loading cards only on initial load
          return _buildShimmerGrid();
        }

        if (snapshot.hasError) {
          return Center(
            child: AppText('Error loading data: ${snapshot.error}', style: AppTextStyle.medium14(color: Colors.red)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final bulkImportList = snapshot.data!;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: bulkImportList.length,
          itemBuilder: (context, index) {
            final item = bulkImportList[index];

            return _buildBulkImportCard(item, index);
          },
        );
      },
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      // Show 6 shimmer cards
      itemBuilder: (context, index) {
        return _buildShimmerCard();
      },
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.greyADB9BD.withOpacity(0.3),
      highlightColor: AppColors.greyADB9BD.withOpacity(0.1),
      child: Container(
        decoration: BoxDecoration(color: AppColors.whiteColor, borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon, filename, timestamp
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // Purple circle placeholder
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: AppColors.greyADB9BD, shape: BoxShape.circle),
                  ),
                  const Gap(6),
                  // Filename and timestamp placeholders
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.greyADB9BD,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Gap(8),
                        Container(
                          width: 80,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.greyADB9BD,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Status message placeholder
            Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(color: AppColors.greyADB9BD, shape: BoxShape.circle),
                  ),
                  const Gap(6),
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
            ),
            const Gap(10),
            // Image thumbnail placeholder
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const Gap(10),
          ],
        ),
      ),
    );
  }

  Widget _buildBulkImportCard(Map<String, dynamic> item, int index) {
    // Extract data from bulk_import item
    final imageUrl = item['imageUrl'] as String? ?? '';
    final imageName = item['image_name'] as String? ?? 'Image ${index + 1}';
    final timeValue = item['time'];

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon, filename, timestamp
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Purple circle with person icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: AppColors.purpleColor, shape: BoxShape.circle),
                  child: Assets.images.staticProfile.image(),
                ),
                const Gap(6),
                // Filename and timestamp
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        imageName,
                        style: AppTextStyle.extraBold14(color: AppColors.black002432),
                        maxLines: 1,
                        isTextScroll: false,
                      ),
                      AppText(timeValue, style: AppTextStyle.regular14(color: AppColors.black002432)),
                    ],
                  ),
                ),
                // Edit button
                GetBuilder<InstallationStepsController>(
                  builder: (controller) {
                    return InkWell(
                      onTap: () {
                        controller.editMediaLibraryImage(
                          context: context,
                          imageUrl: imageUrl,
                          imageName: imageName,
                          index: index,
                        );
                      },
                      child: Container(padding: const EdgeInsets.all(3), child: Assets.icons.icEdit.svg()),
                    );
                  },
                ),
                const Gap(3),
                // Delete button
                GetBuilder<InstallationStepsController>(
                  builder: (controller) {
                    return InkWell(
                      onTap: () {
                        _showDeleteConfirmationDialog(context, controller, imageUrl, index);
                      },
                      child: Container(padding: const EdgeInsets.all(3), child: Assets.icons.icDeleteSvg.svg()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Status message
          // Padding(
          //   padding: const EdgeInsets.only(left: 18),
          //   child: Row(
          //     children: [
          //       Assets.icons.icCheckCircle.svg(),
          //       Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 6),
          //         child: AppText(
          //           'Upload complete',
          //           style: AppTextStyle.semiBold14(
          //             color: AppColors.primaryColor,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          const Gap(10),

          // Image thumbnail
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GetBuilder<InstallationStepsController>(
                  builder: (controller) {
                    // Check if there's a temporary edited image for this index
                    final temporaryImage = controller.temporaryEditedMediaLibraryImages[index];
                    
                    if (temporaryImage != null) {
                      // Show edited image immediately from memory (no shimmer)
                      return GestureDetector(
                        onTap: () {
                          context.push(AppRoutes.imagePreview, extra: {'isNetwork': false, 'imageByte': temporaryImage});
                        },
                        child: Image.memory(
                          temporaryImage,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                    
                    // Otherwise show network image using CachedNetworkImage to prevent shimmer
                    return imageUrl.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              context.push(AppRoutes.imagePreview, extra: {'isNetwork': true, 'image': imageUrl});
                            },
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.greyADB9BD.withOpacity(0.3),
                                width: double.infinity,
                                height: double.infinity,
                                child: const Icon(Icons.image_not_supported, color: AppColors.greyADB9BD),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.greyADB9BD.withOpacity(0.3),
                                width: double.infinity,
                                height: double.infinity,
                                child: const Icon(Icons.image_not_supported, color: AppColors.greyADB9BD),
                              ),
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: AppColors.greyADB9BD.withOpacity(0.3),
                            child: const Icon(Icons.image_not_supported, color: AppColors.greyADB9BD),
                          );
                  },
                ),
              ),
            ),
          ),

          const Gap(10),
        ],
      ),
    );
  }

  Widget _buildImageCard(InstallationStepsController controller, UploadedImage image, int index) {
    final timestamp = DateFormat('h:mm a').format(DateTime.now());

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon, filename, timestamp, and action buttons
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Purple circle with person icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: AppColors.purpleColor, shape: BoxShape.circle),
                  child: Assets.images.staticProfile.image(),
                ),
                const Gap(6),
                // Filename and timestamp
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        image.name,
                        style: AppTextStyle.extraBold14(color: AppColors.black002432),
                        maxLines: 1,
                        isTextScroll: false,
                      ),
                      AppText(timestamp, style: AppTextStyle.regular14(color: AppColors.black002432)),
                    ],
                  ),
                ),
                // Edit button
                InkWell(
                  onTap: () {
                    EditImageDialog.show(
                      context,
                      image: image,
                      onSave: (editedBytes) {
                        controller.updateMediaLibraryImage(index, editedBytes);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                  child: Container(padding: const EdgeInsets.all(3), child: Assets.icons.icEdit.svg()),
                ),
                const Gap(3),
                // Delete button
                InkWell(
                  onTap: () => _showDeleteConfirmationDialog(context, controller, '', index),
                  child: Container(padding: const EdgeInsets.all(3), child: Assets.icons.icDeleteSvg.svg()),
                ),
              ],
            ),
          ),

          // Status message
          Row(
            children: [
              Gap(18),
              image.isUploadFailed ? Assets.icons.icWarring.svg() : Assets.icons.icCheckCircle.svg(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: AppText(
                  image.isUploadFailed ? 'Upload failed' : 'Upload complete',
                  style: AppTextStyle.semiBold14(
                    color: image.isUploadFailed ? AppColors.orangeFF9500 : AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),

          const Gap(10),

          // Image thumbnail
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(image.bytes, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
              ),
            ),
          ),

          const Gap(10),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Landscape icon
          Assets.icons.icGallerySvg.svg(colorFilter: ColorFilter.mode(AppColors.greyADB9BD, BlendMode.srcIn)),
          const Gap(16),
          AppText("It's Empty Here", style: AppTextStyle.extraBold26(color: AppColors.greyADB9BD)),
          const Gap(10),
          AppText(
            'Upload images and manage them all in one place.',
            style: AppTextStyle.regular14(color: AppColors.greyADB9BD),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    InstallationStepsController controller,
    String imageUrl,
    int index,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.45),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(color: AppColors.redColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(Icons.delete_rounded, size: 56, color: AppColors.redColor),
                ),
                const Gap(24),
                AppText(
                  'Delete Image?',
                  style: AppTextStyle.semiBold24(color: AppColors.black002432),
                  textAlign: TextAlign.center,
                ),
                const Gap(16),
                AppText(
                  'Are you sure you want to delete this image? This action cannot be undone.',
                  style: AppTextStyle.regular16(color: AppColors.grey78797A),
                  textAlign: TextAlign.center,
                ),
                const Gap(40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      mouseCursor: SystemMouseCursors.click,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.greyADB9BD, width: 1.5),
                        ),
                        child: Text('Cancel', style: AppTextStyle.medium14(color: AppColors.black002432)),
                      ),
                    ),
                    const Gap(16),
                    Obx(() {
                      final isLoading = controller.deleteImageLoader.value;
                      return InkWell(
                        onTap: isLoading
                            ? null
                            : () async {
                                controller.deleteImageLoader.value = true;
                                final success = await controller.deleteMediaLibraryImage(
                                  context: context,

                                  index: index,
                                );
                                controller.deleteImageLoader.value = false;

                                if (success) {
                                  Navigator.of(dialogContext).pop();

                                  AppFunctions.showToast(
                                    message: 'Image deleted successfully!',
                                    toastType: ToastificationType.success,
                                  );
                                }
                              },
                        mouseCursor: isLoading ? SystemMouseCursors.basic : SystemMouseCursors.click,
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          decoration: BoxDecoration(
                            color: isLoading ? AppColors.greyADB9BD : AppColors.redColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: (isLoading ? AppColors.greyADB9BD : AppColors.redColor).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.whiteColor),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.delete_rounded, size: 18, color: AppColors.whiteColor),
                                    const Gap(8),
                                    Text('Delete', style: AppTextStyle.medium14(color: AppColors.whiteColor)),
                                  ],
                                ),
                        ),
                      );
                    }),
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
