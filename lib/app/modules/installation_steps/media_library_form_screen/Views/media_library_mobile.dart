import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:heimwatt/app/data/common_widget/edit_image_dialog.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_steps_controller.dart';
import 'package:heimwatt/app/modules/installation_steps/media_library_form_screen/Views/checklist_drawer.dart';
import 'package:heimwatt/app/utils/pref_service.dart';
import 'package:heimwatt/app/utils/app_functions.dart';
import 'package:image_network/image_network.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';

import '../../../../utils/exports.dart';

class MediaLibraryMobile extends StatefulWidget {
  const MediaLibraryMobile({super.key});

  @override
  State<MediaLibraryMobile> createState() => _MediaLibraryMobileState();
}

class _MediaLibraryMobileState extends State<MediaLibraryMobile> {
  DropzoneViewController? _dropzoneController;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InstallationStepsController>(
      builder: (controller) {
        final mediaLibraryImages = controller.mediaLibraryImages;
        final hasImages = mediaLibraryImages.isNotEmpty;

        return CommonScrollable(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(controller),
              const Gap(24),

              // Image for mobile
              // _buildMobileImage(),
              // const Gap(24),

              // Upload Zone
              _buildUploadZone(controller),
              const Gap(24),

              // Images List or Empty State
              _buildImagesList(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(InstallationStepsController controller) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.greyADB9BD),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(Assets.icons.icGalleryPng.path, scale: 4),
                  const Gap(8),
                  Text(
                    controller.showInstallationFormScreen
                        ? AppStrings.switchToBulkUpload
                        : "Switch to Step-by-Step Upload",
                    style: AppTextStyle.medium12(),
                  ),
                ],
              ),
            ),
          ),
        ),
        Row(
          children: [
            // MouseRegion(
            //   cursor: SystemMouseCursors.click,
            //
            //   child: InkWell(
            //     onTap: () {
            //       controller.navigateToInstallationForm();
            //     },
            //     child: ClipOval(
            //       child: Container(
            //         padding: const EdgeInsets.all(8),
            //         decoration: BoxDecoration(
            //           color: AppColors.whiteColor,
            //           shape: BoxShape.circle,
            //           border: Border.all(color: AppColors.greyADB9BD),
            //         ),
            //         child: const Icon(Icons.arrow_back_ios_new_outlined, color: AppColors.black002432, size: 12),
            //       ),
            //     ),
            //   ),
            // ),
            // const Gap(10),

            Expanded(
              child: AppText('Media Library', style: AppTextStyle.extraBold28(color: AppColors.black002432)),
            ),
          ],
        ),
        Gap(10),
        Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,

              child: InkWell(
                onTap: () {
                  InstructionVideoDialog.show(context, videoUrl: controller.instructionVideo);
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.greyADB9BD),
                  ),
                  child: Icon(CupertinoIcons.play_arrow, color: AppColors.black002432, size: 16),
                ),
              ),
            ),
            const Gap(8),
            CommonButton(
              text: 'Checklist',
              onTap: () {
                ChecklistDrawer.showAsDialog(context);
              },
              color: AppColors.primaryColor,
              textColor: AppColors.black002432,
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.greyADB9BD),
              showArrow: false,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.black002432),
                    ),
                    child: const Icon(Icons.check, color: AppColors.black002432, size: 10),
                  ),
                  const Gap(4),
                  Text('Checklist', style: AppTextStyle.semiBold12(color: AppColors.black002432)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadZone(InstallationStepsController controller) {
    final imageCount = controller.mediaLibraryImages.length;
    final maxImages = 25;
    final isDisabled = imageCount >= maxImages;

    // Use DropzoneView for web, InkWell for mobile
    if (kIsWeb) {
      DropzoneViewController? dragController;

      return DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: const Radius.circular(16),
          dashPattern: const [8, 8],
          color: isDisabled ? AppColors.greyADB9BD : AppColors.purpleColor,
        ),
        child: Container(
          width: double.infinity,
          height: 200,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
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
                        AppFunctions.showToast(message: 'No valid images found', toastType: ToastificationType.error);
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Purple circle with plus icon
                      DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          radius: const Radius.circular(60),
                          dashPattern: const [8, 8],
                          color: isDisabled ? AppColors.greyADB9BD : AppColors.purpleColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDisabled ? AppColors.greyADB9BD : AppColors.purpleColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: AppColors.whiteColor, size: 24),
                          ),
                        ),
                      ),
                      const Gap(12),
                      AppText(
                        AppStrings.dragAndDropOrSelectFile,
                        style: AppTextStyle.extraBold12(
                          color: isDisabled ? AppColors.greyADB9BD : AppColors.black002432,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (isDisabled) ...[
                        const Gap(8),
                        AppText(
                          'You reached max 25 image limit',
                          style: AppTextStyle.regular12(color: AppColors.grey78797A),
                          textAlign: TextAlign.center,
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
                  child: IgnorePointer(child: Container()),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Mobile: Use InkWell with file picker
      return InkWell(
        onTap: isDisabled
            ? null
            : () async {
                await controller.pickMediaLibraryImages(context: context);
              },
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            radius: const Radius.circular(16),
            dashPattern: const [8, 8],
            color: isDisabled ? AppColors.greyADB9BD : AppColors.purpleColor,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Purple circle with plus icon
                    DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        radius: const Radius.circular(60),
                        dashPattern: const [8, 8],
                        color: isDisabled ? AppColors.greyADB9BD : AppColors.purpleColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDisabled ? AppColors.greyADB9BD : AppColors.purpleColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: AppColors.whiteColor, size: 24),
                        ),
                      ),
                    ),
                    const Gap(12),
                    AppText(
                      AppStrings.dragAndDropOrSelectFile,
                      style: AppTextStyle.extraBold12(color: isDisabled ? AppColors.greyADB9BD : AppColors.black002432),
                      textAlign: TextAlign.center,
                    ),
                    if (isDisabled) ...[
                      const Gap(8),
                      AppText(
                        'You reached max 25 image limit',
                        style: AppTextStyle.regular12(color: AppColors.grey78797A),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildImagesList(InstallationStepsController controller) {
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
          return _buildShimmerList();
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

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bulkImportList.length,
          itemBuilder: (context, index) {
            final item = bulkImportList[index];

            return Padding(padding: const EdgeInsets.only(bottom: 16), child: _buildBulkImportCard(item, index));
          },
        );
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(padding: const EdgeInsets.only(bottom: 16), child: _buildShimmerCard());
      },
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.greyADB9BD.withOpacity(0.3),
      highlightColor: AppColors.greyADB9BD.withOpacity(0.1),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon, filename, timestamp
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Purple circle placeholder
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: AppColors.greyADB9BD, shape: BoxShape.circle),
                  ),
                  const Gap(8),
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
              padding: const EdgeInsets.only(left: 12),
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
            const Gap(12),
            // Image thumbnail placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const Gap(12),
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

    return GetBuilder<InstallationStepsController>(
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon, filename, timestamp
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Purple circle with person icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(color: AppColors.purpleColor, shape: BoxShape.circle),
                      child: Assets.images.staticProfile.image(),
                    ),
                    const Gap(8),
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
                    InkWell(
                      onTap: () {
                        controller.editMediaLibraryImage(
                          context: context,
                          imageUrl: imageUrl,
                          imageName: imageName,
                          index: index,
                        );
                      },
                      child: Container(padding: const EdgeInsets.all(4), child: Assets.icons.icEdit.svg()),
                    ),
                    const Gap(4),
                    // Delete button
                    InkWell(
                      onTap: () {
                        _showDeleteConfirmationDialog(context, controller, imageUrl, index);
                      },
                      child: Container(padding: const EdgeInsets.all(4), child: Assets.icons.icDeleteSvg.svg()),
                    ),
                  ],
                ),
              ),

              // Status message
              // Padding(
              //   padding: const EdgeInsets.only(left: 12),
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
              const Gap(12),

              // Image thumbnail
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Builder(
                    builder: (context) {
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
                            width: MediaQuery.of(context).size.width,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        );
                      }
                      
                      // Otherwise show network image using CachedNetworkImage to prevent shimmer
                      // when temporary image is removed and network image loads
                      return imageUrl.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                context.push(AppRoutes.imagePreview, extra: {'isNetwork': true, 'image': imageUrl});
                              },
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: MediaQuery.of(context).size.width,
                                height: 200,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.greyADB9BD.withOpacity(0.3),
                                  width: MediaQuery.of(context).size.width,
                                  height: 200,
                                  child: const Icon(Icons.image_not_supported, color: AppColors.greyADB9BD),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.greyADB9BD.withOpacity(0.3),
                                  width: MediaQuery.of(context).size.width,
                                  height: 200,
                                  child: const Icon(Icons.image_not_supported, color: AppColors.greyADB9BD),
                                ),
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              height: 200,
                              color: AppColors.greyADB9BD.withOpacity(0.3),
                              child: const Icon(Icons.image_not_supported, color: AppColors.greyADB9BD),
                            );
                    },
                  ),
                ),
              ),

              const Gap(12),
            ],
          ),
        );
      },
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
          const Gap(14),
          AppText("It's Empty Here", style: AppTextStyle.extraBold22(color: AppColors.greyADB9BD)),
          const Gap(8),
          AppText(
            'Upload images and manage them all in one place.',
            style: AppTextStyle.regular12(color: AppColors.greyADB9BD),
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
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
            padding: const EdgeInsets.all(32),
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
                  style: AppTextStyle.regular16(color: AppColors.greyADB9BD),
                  textAlign: TextAlign.center,
                ),
                const Gap(40),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.greyADB9BD, width: 1.5),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTextStyle.semiBold16(color: AppColors.black002432),
                          textAlign: TextAlign.center,
                        ),
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
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: double.infinity,
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
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.whiteColor),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.delete_rounded, size: 18, color: AppColors.whiteColor),
                                    const Gap(8),
                                    Text('Delete', style: AppTextStyle.semiBold16(color: AppColors.whiteColor)),
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
