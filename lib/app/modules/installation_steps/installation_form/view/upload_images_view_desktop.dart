import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:heimwatt/app/data/common_widget/edit_image_dialog.dart';
import 'package:heimwatt/app/data/common_widget/netwrok_image_edit_dialog.dart';
import 'package:heimwatt/app/data/common_widget/reference_image_instructions_dialog.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_form/models/installation_step_model.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_steps_controller.dart';
import 'package:heimwatt/app/utils/app_functions.dart';
import 'package:heimwatt/app/utils/pref_service.dart';
import 'package:image_network/image_network.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';

import '../../../../utils/exports.dart';

class UploadImagesViewDesktop extends StatefulWidget {
  const UploadImagesViewDesktop({super.key});

  @override
  State<UploadImagesViewDesktop> createState() => _UploadImagesViewDesktopState();
}

class _UploadImagesViewDesktopState extends State<UploadImagesViewDesktop> {
  // Track if initial load is complete for each section
  void _showDeleteFirebaseImageDialog(
    BuildContext context,
    InstallationStepsController controller,
    String sectionKey,
    String imageUrl,
    int stepIndex,
    int dataIndex,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.3),
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
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
                AppText('Delete Image', style: AppTextStyle.extraBold24()),
                const Gap(16),
                AppText(
                  'Are you sure you want to delete this image? This action cannot be undone.',
                  style: AppTextStyle.regular16(),
                  textAlign: TextAlign.center,
                ),
                const Gap(30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        onTap: () => Navigator.of(dialogContext).pop(),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
                    ),
                    const Gap(16),
                    InkWell(
                      onTap: () async {
                        Navigator.of(dialogContext).pop();

                        // Remove the image from Firebase images list immediately (instant update)
                        if (controller.firebaseImagesBySection.containsKey(sectionKey)) {
                          controller.firebaseImagesBySection[sectionKey] = controller
                              .firebaseImagesBySection[sectionKey]!
                              .where((item) => (item['image']?.toString() ?? '') != imageUrl)
                              .toList();
                        }
                        if (controller.cachedFirebaseImages.containsKey(sectionKey)) {
                          controller.cachedFirebaseImages[sectionKey] = controller.cachedFirebaseImages[sectionKey]!
                              .where((item) => (item['image']?.toString() ?? '') != imageUrl)
                              .toList();
                        }
                        controller.update(['firebase_images_$sectionKey']);

                        // Show success message immediately (optimistic update)
                        AppFunctions.showToast(
                          message: 'Image deleted successfully!',
                          toastType: ToastificationType.success,
                        );

                        // Remove from database (async operation) - happens in background silently
                        controller
                            .removeFirebaseImage(
                              sectionKey: sectionKey,
                              imageUrl: imageUrl,
                              stepIndex: stepIndex,
                              dataIndex: dataIndex,
                            )
                            .then((_) {})
                            .catchError((e) {
                              debugPrint('Error removing Firebase image: $e');
                              // On error, we could show a toast, but since UI already updated, we'll just log it
                            });
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Obx(() {
                        return Container(
                          width: 150,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(24)),
                          child: controller.deleteImageLoader.value
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator(color: AppColors.whiteColor),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Delete',
                                  style: AppTextStyle.semiBold16(color: AppColors.whiteColor),
                                  textAlign: TextAlign.center,
                                ),
                        );
                      }),
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

  void _showDeleteConfirmationDialog(
    BuildContext context,
    InstallationStepsController controller,
    String sectionKey,
    int index,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.3),
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        onTap: () => Navigator.of(dialogContext).pop(),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
                    ),
                    const Gap(16),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          controller.removeImage(sectionKey, index);
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.redColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.redColor.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [Text('Delete', style: AppTextStyle.semiBold16(color: AppColors.whiteColor))],
                          ),
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InstallationStepsController>(
      builder: (controller) {
        return CommonScrollable(
          padding: const EdgeInsets.only(right: 20.0, left: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,

                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => controller.setUploadView(false),
                      child: ClipOval(
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.greyADB9BD),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_outlined, color: AppColors.black002432, size: 15),
                        ),
                      ),
                    ),
                  ),
                  const Gap(16),
                  AppText(controller.selectedCardTitle ?? AppStrings.roofAndShading, style: AppTextStyle.extraBold44()),
                  const Spacer(),
                  CommonButton(
                    height: 49,
                    text: "",
                    color: AppColors.primaryColor,
                    // textColor: AppColors.black002432,
                    width: 220,
                    onTap: () async {
                      // Submit all sections
                      if (controller.selectedStepIndex == null) {
                        AppFunctions.showToast(message: 'Invalid step selection', toastType: ToastificationType.error);
                        return;
                      }

                      // Prevent submit when there are no images anywhere
                      final hasAnyImages = controller.uploadedImages.values.any((images) => images.isNotEmpty);
                      if (!hasAnyImages) {
                        AppFunctions.showToast(
                          message: 'Please upload at least one image before submitting',
                          toastType: ToastificationType.error,
                        );
                        return;
                      }

                      // Get all sections and submit images for each
                      final installFormSnapshot = await FirebaseFirestore.instance
                          .collection(PrefService.getString(PrefService.dealName))
                          .limit(1)
                          .get();

                      if (installFormSnapshot.docs.isEmpty) {
                        AppFunctions.showToast(
                          message: 'Installation form template not found',
                          toastType: ToastificationType.error,
                        );
                        return;
                      }

                      final installFormData = installFormSnapshot.docs.first.data();
                      final steps = installFormData['steps'] as List<dynamic>?;

                      if (steps == null || controller.selectedStepIndex! >= steps.length) {
                        AppFunctions.showToast(message: 'Invalid step data', toastType: ToastificationType.error);
                        return;
                      }

                      final stepData = steps[controller.selectedStepIndex!] as Map<String, dynamic>;
                      final step = InstallationStep.fromMap(stepData);
                      final dataItems = step.data ?? [];

                      // Submit images for each data section
                      for (int dataIndex = 0; dataIndex < dataItems.length; dataIndex++) {
                        final sectionKey = 'section_${controller.selectedStepIndex}_$dataIndex';
                        final uploadedImagesList = controller.uploadedImages[sectionKey] ?? [];
                        final dataItem = dataItems[dataIndex];
                        final maxCount = dataItem.count ?? 5;

                        if (uploadedImagesList.isNotEmpty) {
                          await controller.submitImagesForSection(
                            context: context,
                            stepIndex: controller.selectedStepIndex!,
                            dataIndex: dataIndex,
                            sectionKey: sectionKey,
                            maxCount: maxCount,
                          );
                        }
                      }

                      // AppFunctions.showSuccessToast(context, 'All images submitted successfully!');
                    },
                    child: Obx(() {
                      return controller.submitLoader.value
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(AppStrings.submit, style: AppTextStyle.semiBold16(color: AppColors.black002432)),
                                const Gap(12),
                                Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.black002432),
                              ],
                            );
                    }),
                  ),
                ],
              ),
              const Gap(40),

              // Dynamic sections from Firebase
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection(PrefService.getString(PrefService.dealName)).limit(1).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show shimmer loading for main list
                    return GetBuilder<InstallationStepsController>(
                      id: 'main_list',
                      builder: (controller) {
                        return _buildShimmerSection();
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

                  if (steps == null || steps.isEmpty || controller.selectedStepIndex == null) {
                    return Center(
                      child: AppText('No data found!!!', style: AppTextStyle.medium16(color: AppColors.black002432)),
                    );
                  }

                  // Get the selected step
                  final stepIndex = controller.selectedStepIndex!;
                  if (stepIndex >= steps.length) {
                    return Center(
                      child: AppText('Invalid step index', style: AppTextStyle.medium16(color: AppColors.black002432)),
                    );
                  }

                  final stepData = steps[stepIndex] as Map<String, dynamic>;
                  final step = InstallationStep.fromMap(stepData);

                  // Get data items
                  final dataItems = step.data ?? [];

                  if (dataItems.isEmpty) {
                    return Center(
                      child: AppText(
                        'No upload sections found',
                        style: AppTextStyle.medium16(color: AppColors.black002432),
                      ),
                    );
                  }

                  // Build sections dynamically from data
                  return Column(
                    children: dataItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final dataItem = entry.value;
                      final sectionKey = 'section_${stepIndex}_$index';

                      return Column(
                        children: [
                          _buildUploadSectionWithProjectImages(
                            controller: controller,
                            title: dataItem.title ?? 'Section ${index + 1}',
                            sectionKey: sectionKey,
                            instruction: dataItem.title ?? 'Upload images for this section',
                            context: context,
                            maxCount: dataItem.count ?? 5,
                            refImage: dataItem.refImage ?? '',
                            stepIndex: stepIndex,
                            dataIndex: index,
                          ),
                          if (index < dataItems.length - 1) const Gap(30),
                        ],
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

  Widget _buildUploadSectionWithProjectImages({
    required InstallationStepsController controller,
    required String title,
    required String sectionKey,
    required String instruction,
    required BuildContext context,
    int maxCount = 5,
    required String refImage,
    required int stepIndex,
    required int dataIndex,
  }) {
    // Load Firebase images once when section is first built
    if (!controller.firebaseImagesBySection.containsKey(sectionKey) &&
        !(controller.isLoadingFirebaseImages[sectionKey] ?? false)) {
      controller.loadFirebaseImagesForSection(sectionKey: sectionKey, stepIndex: stepIndex, dataIndex: dataIndex);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.whiteColor, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppText(title, style: AppTextStyle.extraBold24()),
              Spacer(),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: () {
                    ReferenceImageInstructionsDialog.show(context, refImage);
                  },
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.greyADB9BD),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppStrings.checkReferenceImage, style: AppTextStyle.medium14()),
                        const Gap(8),
                        Image.asset(Assets.icons.icGalleryPng.path, scale: 3),
                      ],
                    ),
                  ),
                ),
              ),
              Gap(12),
              // Progress indicator - uses GetBuilder for Firebase images count
              GetBuilder<InstallationStepsController>(
                id: 'firebase_images_$sectionKey',
                builder: (controller) {
                  // Use cached images if available during loading, otherwise use current images
                  final isLoading = controller.isLoadingFirebaseImages[sectionKey] ?? false;
                  final firebaseImages = isLoading
                      ? (controller.cachedFirebaseImages[sectionKey] ??
                            controller.firebaseImagesBySection[sectionKey] ??
                            [])
                      : (controller.firebaseImagesBySection[sectionKey] ?? []);
                  final uploadedCount = controller.getUploadedCount(sectionKey);
                  final totalCount = firebaseImages.length + uploadedCount;

                  return Stack(
                    alignment: AlignmentGeometry.center,
                    children: [
                      _buildProgressIndicator(totalCount, maxCount),
                      AppText('$totalCount/$maxCount', style: AppTextStyle.semiBold15()),
                    ],
                  );
                },
              ),
            ],
          ),
          const Gap(20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: Upload area
              Expanded(
                flex: 3,
                child: GetBuilder<InstallationStepsController>(
                  id: 'firebase_images_$sectionKey',
                  builder: (controller) {
                    // Use cached images if available during loading, otherwise use current images
                    final isLoading = controller.isLoadingFirebaseImages[sectionKey] ?? false;
                    final firebaseImages = isLoading
                        ? (controller.cachedFirebaseImages[sectionKey] ??
                              controller.firebaseImagesBySection[sectionKey] ??
                              [])
                        : (controller.firebaseImagesBySection[sectionKey] ?? []);
                    final uploadedCount = controller.getUploadedCount(sectionKey);

                    return _buildUploadArea(
                      controller: controller,
                      sectionKey: sectionKey,
                      instruction: instruction,
                      uploadedCount: uploadedCount,
                      maxCount: maxCount,
                      firebaseImagesCount: firebaseImages.length,
                    );
                  },
                ),
              ),
              const Gap(20),
              // Right side: Status and uploaded files - only this section uses GetBuilder
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 300,
                  child: GetBuilder<InstallationStepsController>(
                    id: 'firebase_images_$sectionKey',
                    builder: (controller) {
                      // Show shimmer only on initial load
                      if (controller.isLoadingFirebaseImages[sectionKey] ?? false) {
                        return _buildShimmerImagesList();
                      }

                      final firebaseImages = controller.firebaseImagesBySection[sectionKey] ?? [];
                      final uploadedCount = controller.getUploadedCount(sectionKey);
                      final uploadedImages = controller.uploadedImages[sectionKey] ?? [];

                      return _buildStatusArea(
                        controller: controller,
                        sectionKey: sectionKey,
                        uploadedCount: uploadedCount,
                        uploadedImages: uploadedImages,
                        firebaseImages: firebaseImages,
                        stepIndex: stepIndex,
                        dataIndex: dataIndex,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadUI({required bool canUpload, required String instruction}) {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: const Radius.circular(24),
        dashPattern: const [10, 10],
        color: canUpload ? AppColors.purpleColor : Colors.transparent,
      ),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: canUpload ? AppColors.whiteColor : AppColors.whiteF5F5F5,
          border: Border.all(color: canUpload ? Colors.transparent : AppColors.purpleColor),
        ),
        child: Center(
          child: canUpload
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(Assets.icons.icImageAdd.path, scale: 3),
                    const Gap(16),
                    AppText(AppStrings.dragAndDropOrSelectFile, style: AppTextStyle.extraBold16()),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Gap(12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: AppText(
                        'Maximum limit reached',
                        style: AppTextStyle.medium18(color: AppColors.purpleColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildUploadArea({
    required InstallationStepsController controller,
    required String sectionKey,
    required String instruction,
    required int uploadedCount,

    int maxCount = 5,
    int firebaseImagesCount = 0,
  }) {
    // Check if Firebase images are still loading
    final isLoading = controller.isLoadingFirebaseImages[sectionKey] ?? false;
    final totalCount = uploadedCount + firebaseImagesCount;
    // Disable uploads while loading to ensure accurate count
    final canUpload = !isLoading && totalCount < maxCount;

    DropzoneViewController? dragController;

    Future<void> pickFiles() async {
      if (!canUpload) return;

      final remainingSlots = maxCount - firebaseImagesCount - uploadedCount;
      if (remainingSlots <= 0) {
        return;
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        withData: true,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.isNotEmpty) {
        final currentImages = controller.uploadedImages[sectionKey] ?? [];

        // Recalculate remaining slots to ensure accuracy
        final currentFirebaseCount = controller.firebaseImagesBySection[sectionKey]?.length ?? firebaseImagesCount;
        final actualRemainingSlots = maxCount - currentFirebaseCount - currentImages.length;

        if (actualRemainingSlots <= 0) {
          AppFunctions.showToast(
            message: 'Maximum image limit ($maxCount) reached',
            toastType: ToastificationType.error,
          );
          return;
        }

        // Validate file sizes (2 MB limit)
        const maxFileSize = 2 * 1024 * 1024; // 2 MB in bytes
        final validFiles = result.files.where((file) {
          if (file.bytes == null) return false;
          return file.bytes!.length <= maxFileSize;
        }).toList();

        final oversizedFiles = result.files.where((file) {
          if (file.bytes == null) return false;
          return file.bytes!.length > maxFileSize;
        }).toList();

        // Show error message if any files exceed size limit
        if (oversizedFiles.isNotEmpty) {
          AppFunctions.showToast(
            message: '${oversizedFiles.length} image(s) exceed the 2 MB size limit and were not uploaded',
            toastType: ToastificationType.error,
          );
        }

        // Limit files to remaining slots - extra files will be ignored
        final filesToAdd = validFiles
            .take(actualRemainingSlots)
            .where((file) => file.bytes != null)
            .map((file) => UploadedImage(name: file.name, bytes: file.bytes!))
            .toList();

        // Show message if user tried to upload more than allowed
        if (result.files.length > actualRemainingSlots) {
          AppFunctions.showToast(
            message: 'Only $actualRemainingSlots image(s) added. Maximum limit is $maxCount.',
            toastType: ToastificationType.info,
          );
        }

        // Calculate the starting index for new items
        final startingIndex = currentFirebaseCount + currentImages.length;

        // Add images - ensure total never exceeds maxCount
        final newTotal = currentFirebaseCount + currentImages.length + filesToAdd.length;
        if (newTotal > maxCount) {
          // Safety check: trim to exact limit
          final allowedCount = maxCount - currentFirebaseCount - currentImages.length;
          final trimmedFiles = filesToAdd.take(allowedCount).toList();
          controller.uploadedImages[sectionKey] = [...currentImages, ...trimmedFiles];
        } else {
          controller.uploadedImages[sectionKey] = [...currentImages, ...filesToAdd];
        }

        // Update both IDs so upload area and status area both rebuild
        controller.update(['firebase_images_$sectionKey', 'status_area_$sectionKey']);

        // Set loading state for first newly added item to show shimmer
        if (filesToAdd.isNotEmpty) {
          controller.loadingItemIndex[sectionKey] = startingIndex;
          controller.update(['status_area_$sectionKey']);

          // Clear loading state after a brief moment
          Future.delayed(const Duration(milliseconds: 500), () {
            controller.loadingItemIndex[sectionKey] = null;
            controller.update(['status_area_$sectionKey']);
          });
        }

        // Open edit dialog for first newly added image
        // if (filesToAdd.isNotEmpty && mounted) {
        //   final newImageIndex = currentImages.length;
        //   final images = controller.uploadedImages[sectionKey] ?? [];
        //   if (newImageIndex < images.length) {
        //     EditImageDialog.show(
        //       context,
        //       image: images[newImageIndex],
        //       onSave: (editedBytes) {
        //         controller.updateImage(sectionKey, newImageIndex, editedBytes);
        //         Navigator.of(context).pop();
        //       },
        //     );
        //   }
        // }
      }
    }

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          // 🟣 DROPZONE (drag only)
          DropzoneView(
            operation: DragOperation.copy,
            cursor: CursorType.grab,
            onCreated: (ctrl) => dragController = ctrl,
            onDropFiles: (files) async {
              if (files == null || files.isEmpty) return;

              // Recalculate canUpload inside handler to get latest state
              final currentFirebaseImages = controller.firebaseImagesBySection[sectionKey] ?? [];
              final currentUploadedCount = controller.getUploadedCount(sectionKey);
              final isLoading = controller.isLoadingFirebaseImages[sectionKey] ?? false;
              final currentTotalCount = currentUploadedCount + currentFirebaseImages.length;
              final currentCanUpload = !isLoading && currentTotalCount < maxCount;

              if (!currentCanUpload) return;

              final remainingSlots = maxCount - currentFirebaseImages.length - currentUploadedCount;
              if (remainingSlots <= 0) return;

              final currentImages = controller.uploadedImages[sectionKey] ?? [];

              // Show message if user tried to upload more than allowed
              if (files.length > remainingSlots) {
                AppFunctions.showToast(
                  message: 'Only $remainingSlots image(s) added. Maximum limit is $maxCount.',
                  toastType: ToastificationType.info,
                );
              }

              final List<UploadedImage> newFiles = [];
              final List<String> oversizedFileNames = [];

              // Limit to remaining slots - extra files will be ignored
              for (final file in files.take(remainingSlots)) {
                try {
                  final name = await dragController!.getFilename(file);
                  final bytes = await dragController!.getFileData(file);

                  // Validate file size (3 MB limit)
                  const maxFileSize = 3 * 1024 * 1024; // 3 MB in bytes
                  if (bytes.length > maxFileSize) {
                    oversizedFileNames.add(name);
                    continue;
                  }

                  newFiles.add(UploadedImage(name: name, bytes: bytes));
                } catch (e) {
                  debugPrint('Error processing dropped file: $e');
                }
              }

              // Show error message if any files exceed size limit
              if (oversizedFileNames.isNotEmpty) {
                AppFunctions.showToast(
                  message: '${oversizedFileNames.length} image(s) exceed the 3 MB size limit and were not uploaded',
                  toastType: ToastificationType.error,
                );
              }

              final startingIndex = currentFirebaseImages.length + currentImages.length;

              // Safety check: ensure total never exceeds maxCount
              final newTotal = currentFirebaseImages.length + currentImages.length + newFiles.length;
              if (newTotal > maxCount) {
                // Trim to exact limit
                final allowedCount = maxCount - currentFirebaseImages.length - currentImages.length;
                final trimmedFiles = newFiles.take(allowedCount).toList();
                controller.uploadedImages[sectionKey] = [...currentImages, ...trimmedFiles];
              } else {
                controller.uploadedImages[sectionKey] = [...currentImages, ...newFiles];
              }

              // Update both IDs so upload area and status area both rebuild
              controller.update(['firebase_images_$sectionKey', 'status_area_$sectionKey']);

              // Set loading state for first newly added item to show shimmer
              if (newFiles.isNotEmpty) {
                controller.loadingItemIndex[sectionKey] = startingIndex;
                controller.update(['status_area_$sectionKey']);

                // Clear loading state after a brief moment
                Future.delayed(const Duration(milliseconds: 500), () {
                  controller.loadingItemIndex[sectionKey] = null;
                  controller.update(['status_area_$sectionKey']);
                });
              }
            },
          ),

          // 🟢 TAP HANDLER (ON TOP) - Only intercepts taps, allows drag events to pass through
          Positioned.fill(
            child: _TapOnlyOverlay(onTap: pickFiles, canUpload: canUpload, instruction: instruction),
          ),
        ],
      ),
    );
  }

  // Widget _buildUploadArea({
  //   required InstallationStepsController controller,
  //   required String sectionKey,
  //   required String instruction,
  //   required int uploadedCount,
  //
  //   int maxCount = 5,
  //   int firebaseImagesCount = 0,
  // })
  // {
  //   final totalCount = uploadedCount + firebaseImagesCount;
  //   final canUpload = totalCount < maxCount;
  //
  //   return InkWell(
  //     onTap: canUpload
  //         ? () async {
  //       final remainingSlots = maxCount - firebaseImagesCount - uploadedCount;
  //       if (remainingSlots <= 0) {
  //         return;
  //       }
  //
  //       final result = await FilePicker.platform.pickFiles(
  //         type: FileType.custom,
  //         allowMultiple: true,
  //         withData: true,
  //         allowedExtensions: ['png', 'jpg', 'jpeg'],
  //       );
  //
  //       if (result != null && result.files.isNotEmpty) {
  //         final currentImages = controller.uploadedImages[sectionKey] ?? [];
  //         final filesToAdd = result.files
  //             .take(remainingSlots)
  //             .where((file) => file.bytes != null)
  //             .map((file) => UploadedImage(name: file.name, bytes: file.bytes!))
  //             .toList();
  //
  //         // Calculate the starting index for new items (firebaseImagesCount + currentImages.length)
  //         final startingIndex = firebaseImagesCount + currentImages.length;
  //
  //         // Add images instantly first
  //         controller.uploadedImages[sectionKey] = [...currentImages, ...filesToAdd];
  //         controller.update(['status_area_$sectionKey']);
  //
  //         // Set loading state for first newly added item to show shimmer
  //         if (filesToAdd.isNotEmpty) {
  //           controller.loadingItemIndex[sectionKey] = startingIndex;
  //           controller.update(['status_area_$sectionKey']);
  //
  //           // Clear loading state after a brief moment
  //           Future.delayed(const Duration(milliseconds: 500), () {
  //             controller.loadingItemIndex[sectionKey] = null;
  //             controller.update(['status_area_$sectionKey']);
  //           });
  //         }
  //
  //         // Open edit dialog for first newly added image
  //         // if (filesToAdd.isNotEmpty && mounted) {
  //         //   final newImageIndex = currentImages.length;
  //         //   final images = controller.uploadedImages[sectionKey] ?? [];
  //         //   if (newImageIndex < images.length) {
  //         //     EditImageDialog.show(
  //         //       context,
  //         //       image: images[newImageIndex],
  //         //       onSave: (editedBytes) {
  //         //         controller.updateImage(sectionKey, newImageIndex, editedBytes);
  //         //         Navigator.of(context).pop();
  //         //       },
  //         //     );
  //         //   }
  //         // }
  //       }
  //     }
  //         : null,
  //     child: MouseRegion(
  //       cursor: canUpload ? SystemMouseCursors.click : SystemMouseCursors.basic,
  //       child: DottedBorder(
  //         options: RoundedRectDottedBorderOptions(
  //           radius: Radius.circular(24),
  //           dashPattern: [10, 10],
  //           color: canUpload ? AppColors.purpleColor : Colors.transparent,
  //         ),
  //
  //         child: Container(
  //           height: 300,
  //           decoration: BoxDecoration(
  //             border: canUpload == false
  //                 ? Border.all(color: AppColors.purpleColor, style: BorderStyle.solid, width: 1)
  //                 : null,
  //             borderRadius: BorderRadius.circular(16),
  //             color: canUpload ? AppColors.whiteColor : AppColors.whiteF5F5F5,
  //           ),
  //           child: canUpload
  //               ? Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Image.asset(Assets.icons.icImageAdd.path, scale: 3),
  //                   const Gap(16),
  //                   AppText(AppStrings.dragAndDropOrSelectFile, style: AppTextStyle.extraBold16()),
  //                   const Gap(12),
  //                   Padding(
  //                     padding: const EdgeInsets.symmetric(horizontal: 40),
  //                     child: AppText(instruction, style: AppTextStyle.regular16(), textAlign: TextAlign.center),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           )
  //               : Center(
  //             child: AppText(
  //               AppStrings.maximumImagesReached,
  //               style: AppTextStyle.medium16(color: AppColors.purpleColor),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildStatusArea({
    required InstallationStepsController controller,
    required String sectionKey,
    required int uploadedCount,
    required List<dynamic> uploadedImages,
    List<Map<String, dynamic>> firebaseImages = const [],
    required int stepIndex,
    required int dataIndex,
  }) {
    return GetBuilder<InstallationStepsController>(
      id: 'status_area_$sectionKey',
      builder: (controller) {
        // Get current uploaded images from controller
        final currentUploadedImages = controller.uploadedImages[sectionKey] ?? [];

        // Get Firebase images from controller (not from parameter) to ensure we have the latest data
        final currentFirebaseImages = controller.firebaseImagesBySection[sectionKey] ?? [];

        // Combine Firebase images and uploaded images
        final allImages = <_ImageItem>[];

        // Add Firebase images first (from project)
        // Exclude images that are being removed/edited
        final removedImages = controller.removedFirebaseImages[sectionKey] ?? <String>{};
        for (int i = 0; i < currentFirebaseImages.length; i++) {
          final imageData = currentFirebaseImages[i] as Map<String, dynamic>;
          final imageUrl = imageData['image']?.toString() ?? '';
          // Only add if URL is not empty and not in the removed set
          if (imageUrl.isNotEmpty && !removedImages.contains(imageUrl)) {
            allImages.add(
              _ImageItem(
                url: imageUrl,
                name: imageData['name']?.toString(), // Get name from Firebase
                isFromFirebase: true,
                index: i,
              ),
            );
          }
        }

        // Add uploaded images (bytes) - use current state from controller
        for (int i = 0; i < currentUploadedImages.length; i++) {
          allImages.add(_ImageItem(uploadedImage: currentUploadedImages[i], isFromFirebase: false, index: i));
        }

        // If no images, show empty state
        if (allImages.isEmpty) {
          return Center(
            child: AppText('No images uploaded yet', style: AppTextStyle.regular14(color: AppColors.greyADB9BD)),
          );
        }

        return SizedBox(
          height: 300,
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: double.infinity,
                height: 1,
                color: AppColors.greyADB9BD,
              );
            },
            shrinkWrap: false,
            itemCount: allImages.length,
            itemBuilder: (context, index) {
              final imageItem = allImages[index];
              return _buildImageItem(
                controller: controller,
                sectionKey: sectionKey,
                imageItem: imageItem,
                index: index,
                stepIndex: stepIndex,
                dataIndex: dataIndex,
                firebaseImagesCount: currentFirebaseImages.length,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(int progress, int total) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
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
        ],
      ),
    );
  }

  Widget _buildImageItem({
    required InstallationStepsController controller,
    required String sectionKey,
    required _ImageItem imageItem,
    required int index,
    required int stepIndex,
    required int dataIndex,
    required int firebaseImagesCount,
  }) {
    // Check loading state by index OR by identifier (URL for Firebase images)
    final isLoadingByIndex = controller.loadingItemIndex[sectionKey] == index;
    final isLoadingByIdentifier =
        imageItem.isFromFirebase &&
        imageItem.url != null &&
        controller.loadingItemIdentifier[sectionKey] == imageItem.url;
    final isLoading = isLoadingByIndex || isLoadingByIdentifier;

    // Show shimmer if this item is loading
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 150,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                  ],
                ),
              ),
              Container(width: 20, height: 20, color: Colors.white),
              const Gap(8),
              Container(width: 20, height: 20, color: Colors.white),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          // Thumbnail - show network image for Firebase or memory image for uploaded
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Builder(
              builder: (context) {
                // Check if there's a temporary edited image for this Firebase image
                if (imageItem.isFromFirebase && imageItem.url != null) {
                  final tempKey = '$sectionKey|${imageItem.url!}';
                  final temporaryImage = controller.temporaryEditedInstallationStepImages[tempKey];

                  if (temporaryImage != null) {
                    // Show edited image immediately from memory (no shimmer)
                    return InkWell(
                      onTap: () {
                        context.push(AppRoutes.imagePreview, extra: {'isNetwork': false, 'imageByte': temporaryImage});
                      },
                      child: Image.memory(temporaryImage, width: 40, height: 40, fit: BoxFit.cover),
                    );
                  }

                  // Otherwise show network image using CachedNetworkImage to prevent shimmer
                  return InkWell(
                    onTap: () {
                      context.push(AppRoutes.imagePreview, extra: {'isNetwork': true, 'image': imageItem.url!});
                    },
                    child: CachedNetworkImage(
                      imageUrl: imageItem.url!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 40,
                        height: 40,
                        color: AppColors.greyADB9BD,
                        child: Icon(Icons.broken_image, color: AppColors.black002432),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 40,
                        height: 40,
                        color: AppColors.greyADB9BD,
                        child: Icon(Icons.broken_image, color: AppColors.black002432),
                      ),
                    ),
                  );
                }

                // For uploaded images (not from Firebase)
                return imageItem.uploadedImage != null
                    ? InkWell(
                        onTap: () {
                          context.push(
                            AppRoutes.imagePreview,
                            extra: {'isNetwork': false, 'imageByte': imageItem.uploadedImage!.bytes},
                          );
                        },
                        child: Image.memory(imageItem.uploadedImage!.bytes, width: 40, height: 40, fit: BoxFit.cover),
                      )
                    : Container(width: 40, height: 40, color: AppColors.greyADB9BD);
              },
            ),
          ),

          const Gap(12),
          // File name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  imageItem.isFromFirebase
                      ? (imageItem.name ?? _fileNameFromUrl(imageItem.url!))
                      : imageItem.uploadedImage?.name ?? 'Image',
                  style: AppTextStyle.semiBold16(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!imageItem.isFromFirebase && imageItem.uploadedImage?.isUploadFailed == true) ...[
                  const Gap(4),
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                      const Gap(4),
                      AppText(AppStrings.uploadFailed, style: AppTextStyle.regular12(color: Colors.orange)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          InkWell(
            onTap: () {
              if (imageItem.isFromFirebase && imageItem.url != null) {
                final url = imageItem.url!;
                final tempKey = '$sectionKey|$url';
                final tempBytes = controller.temporaryEditedInstallationStepImages[tempKey];

                // If we have edited bytes currently displayed, open editor from memory
                if (tempBytes != null) {
                  EditImageDialog.show(
                    context,
                    image: UploadedImage(name: imageItem.name ?? _fileNameFromUrl(url), bytes: tempBytes),
                    onSave: (editedBytes) async {
                      Navigator.of(context).pop();

                      controller.temporaryEditedInstallationStepImages[tempKey] = editedBytes;
                      controller.update(['firebase_images_$sectionKey']);

                      controller
                          .updateInstallationStepImageInFirebase(
                            context: context,
                            sectionKey: sectionKey,
                            oldImageUrl: url,
                            editedBytes: editedBytes,
                            imageName: imageItem.name ?? _fileNameFromUrl(url),
                            stepIndex: stepIndex,
                            dataIndex: dataIndex,
                          )
                          .catchError((e) {
                            controller.temporaryEditedInstallationStepImages.remove(tempKey);
                            controller.update(['firebase_images_$sectionKey']);
                            debugPrint('Error uploading edited image: $e');
                          });
                    },
                  );
                  return;
                }

                // Otherwise open editor from network URL
                EditImageNetworkDialog.show(
                  context,
                  image: url,
                  onSave: (editedBytes) async {
                    Navigator.of(context).pop();

                    controller.temporaryEditedInstallationStepImages[tempKey] = editedBytes;
                    controller.update(['firebase_images_$sectionKey']);

                    controller
                        .updateInstallationStepImageInFirebase(
                          context: context,
                          sectionKey: sectionKey,
                          oldImageUrl: url,
                          editedBytes: editedBytes,
                          imageName: imageItem.name ?? _fileNameFromUrl(url),
                          stepIndex: stepIndex,
                          dataIndex: dataIndex,
                        )
                        .catchError((e) {
                          controller.temporaryEditedInstallationStepImages.remove(tempKey);
                          controller.update(['firebase_images_$sectionKey']);
                          debugPrint('Error uploading edited image: $e');
                        });
                  },
                );
              } else {
                EditImageDialog.show(
                  context,
                  image: imageItem.uploadedImage!,
                  onSave: (editedBytes) {
                    Navigator.of(context).pop();
                    // Update image instantly - no shimmer needed since it reflects instantly
                    controller.updateImage(sectionKey, imageItem.index, editedBytes);
                    controller.update(['status_area_$sectionKey']);
                  },
                );
              }
            },
            child: Assets.icons.icEdit.svg(),
          ),

          InkWell(
            onTap: () {
              if (imageItem.isFromFirebase && imageItem.url != null) {
                // Delete Firebase image immediately
                _showDeleteFirebaseImageDialog(context, controller, sectionKey, imageItem.url!, stepIndex, dataIndex);
              } else {
                // Remove uploaded image directly (not submitted yet)
                _showDeleteConfirmationDialog(context, controller, sectionKey, imageItem.index);
              }
            },
            child: Image.asset(Assets.icons.icDeletePng.path, height: 40, width: 25),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerSection() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title shimmer
          Container(height: 20, width: 250, color: Colors.white),
          const SizedBox(height: 16),
          // Upload box shimmer
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple.shade100, style: BorderStyle.solid, width: 2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, size: 40, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(height: 12, width: 100, color: Colors.white),
                        const SizedBox(height: 4),
                        Container(height: 10, width: 200, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Right-side Firebase images shimmer
              SizedBox(
                width: 300,
                child: Column(
                  children: List.generate(3, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Container(height: 40, width: 40, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Container(height: 16, color: Colors.white)),
                          const SizedBox(width: 12),
                          Icon(Icons.delete_outline, color: Colors.white),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Shimmer.fromColors(
    // baseColor: AppColors.greyADB9BD.withOpacity(0.3),
    // highlightColor: AppColors.greyADB9BD.withOpacity(0.1),
    // child:
    //
    // Container(
    //   padding: const EdgeInsets.all(24),
    //   decoration: BoxDecoration(color: AppColors.whiteColor, borderRadius: BorderRadius.circular(24)),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Row(
    //         children: [
    //           Container(
    //             width: 200,
    //             height: 24,
    //             decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(4)),
    //           ),
    //           const Spacer(),
    //           Container(
    //             width: 250,
    //             height: 40,
    //             decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(24)),
    //           ),
    //           const Gap(12),
    //           Container(
    //             width: 50,
    //             height: 50,
    //             decoration: BoxDecoration(color: AppColors.greyADB9BD, shape: BoxShape.circle),
    //           ),
    //         ],
    //       ),
    //       const Gap(20),
    //       Container(
    //         height: 300,
    //         decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(16)),
    //       ),
    //     ],
    //   ),
    // ),
    // );
  }

  Widget _buildShimmerImagesList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Generate shimmer items matching the image list structure
          ...List.generate(3, (index) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      // Thumbnail shimmer
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      ),
                      const Gap(12),
                      // File name shimmer
                      Expanded(
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const Gap(8),
                      // Edit icon shimmer
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                      ),
                      const Gap(8),
                      // Delete icon shimmer
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                      ),
                    ],
                  ),
                ),
                if (index < 2) // Add separator between items (except last)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: double.infinity,
                    height: 1,
                    color: Colors.white.withOpacity(0.3),
                  ),
              ],
            );
          }),
        ],
      ),
    );
    //   Shimmer.fromColors(
    //   baseColor: AppColors.greyADB9BD.withOpacity(0.3),
    //   highlightColor: AppColors.greyADB9BD.withOpacity(0.1),
    //   child: Container(
    //     padding: const EdgeInsets.all(24),
    //     decoration: BoxDecoration(color: AppColors.whiteColor, borderRadius: BorderRadius.circular(24)),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Row(
    //           children: [
    //             Container(
    //               width: 200,
    //               height: 24,
    //               decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(4)),
    //             ),
    //             const Spacer(),
    //             Container(
    //               width: 250,
    //               height: 40,
    //               decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(24)),
    //             ),
    //             const Gap(12),
    //             Container(
    //               width: 50,
    //               height: 50,
    //               decoration: BoxDecoration(color: AppColors.greyADB9BD, shape: BoxShape.circle),
    //             ),
    //           ],
    //         ),
    //         const Gap(20),
    //         Row(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Expanded(
    //               flex: 3,
    //               child: Container(
    //                 height: 300,
    //                 decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(16)),
    //               ),
    //             ),
    //             const Gap(20),
    //             Expanded(
    //               flex: 2,
    //               child: SizedBox(
    //                 height: 300,
    //                 child: Column(
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: [
    //                     Container(
    //                       height: 16,
    //                       width: 120,
    //                       decoration: BoxDecoration(
    //                         color: AppColors.greyADB9BD,
    //                         borderRadius: BorderRadius.circular(4),
    //                       ),
    //                     ),
    //                     const Gap(12),
    //                     ...List.generate(3, (index) {
    //                       return Column(
    //                         children: [
    //                           Container(
    //                             padding: const EdgeInsets.all(10),
    //                             child: Row(
    //                               children: [
    //                                 Container(
    //                                   width: 40,
    //                                   height: 40,
    //                                   decoration: BoxDecoration(
    //                                     color: AppColors.greyADB9BD,
    //                                     borderRadius: BorderRadius.circular(8),
    //                                   ),
    //                                 ),
    //                                 const Gap(12),
    //                                 Expanded(
    //                                   child: Container(
    //                                     height: 16,
    //                                     decoration: BoxDecoration(
    //                                       color: AppColors.greyADB9BD,
    //                                       borderRadius: BorderRadius.circular(4),
    //                                     ),
    //                                   ),
    //                                 ),
    //                                 const Gap(12),
    //                                 Container(
    //                                   width: 25,
    //                                   height: 40,
    //                                   decoration: BoxDecoration(
    //                                     color: AppColors.greyADB9BD,
    //                                     borderRadius: BorderRadius.circular(4),
    //                                   ),
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //                           if (index < 2)
    //                             Container(
    //                               margin: const EdgeInsets.symmetric(horizontal: 12),
    //                               width: double.infinity,
    //                               height: 1,
    //                               color: AppColors.greyADB9BD,
    //                             ),
    //                         ],
    //                       );
    //                     }),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  // Get project document stream
}

// Helper class to represent both types of images
// Custom widget that only handles taps, allows drag events to pass through
class _TapOnlyOverlay extends StatefulWidget {
  final VoidCallback onTap;
  final bool canUpload;
  final String instruction;

  const _TapOnlyOverlay({required this.onTap, required this.canUpload, required this.instruction});

  @override
  State<_TapOnlyOverlay> createState() => _TapOnlyOverlayState();
}

class _TapOnlyOverlayState extends State<_TapOnlyOverlay> {
  Offset? _pointerDownPosition;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        _pointerDownPosition = event.position;
        _isDragging = false;
      },
      onPointerMove: (event) {
        if (_pointerDownPosition != null) {
          final distance = (event.position - _pointerDownPosition!).distance;
          if (distance > 5.0) {
            // Pointer moved significantly - it's a drag, not a tap
            _isDragging = true;
          }
        }
      },
      onPointerUp: (event) {
        if (!_isDragging && _pointerDownPosition != null) {
          // It was a tap, not a drag - handle the tap
          widget.onTap();
        }
        _pointerDownPosition = null;
        _isDragging = false;
      },
      onPointerCancel: (_) {
        _pointerDownPosition = null;
        _isDragging = false;
      },
      behavior: HitTestBehavior.translucent,
      child: MouseRegion(
        cursor: widget.canUpload ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: _buildUploadUI(canUpload: widget.canUpload, instruction: widget.instruction),
      ),
    );
  }

  Widget _buildUploadUI({required bool canUpload, required String instruction}) {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: const Radius.circular(24),
        dashPattern: const [10, 10],
        color: canUpload ? AppColors.purpleColor : Colors.transparent,
      ),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: canUpload ? AppColors.whiteColor : AppColors.whiteF5F5F5,
          border: Border.all(color: canUpload ? Colors.transparent : AppColors.purpleColor),
        ),
        child: Center(
          child: canUpload
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(Assets.icons.icImageAdd.path, scale: 3),
                    const Gap(16),
                    AppText(AppStrings.dragAndDropOrSelectFile, style: AppTextStyle.extraBold16()),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Gap(12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: AppText(
                        'Maximum limit reached',
                        style: AppTextStyle.medium18(color: AppColors.purpleColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ImageItem {
  final String? url;
  final String? name; // Image name from Firebase
  final UploadedImage? uploadedImage;
  final bool isFromFirebase;
  final int index;

  _ImageItem({this.url, this.name, this.uploadedImage, required this.isFromFirebase, required this.index});
}

/// Extract a human‑readable file name from an image URL.
String _fileNameFromUrl(String url) {
  try {
    final uri = Uri.parse(url);
    String lastSegment = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : url;
    // Strip query params if any
    lastSegment = lastSegment.split('?').first;
    return lastSegment.isNotEmpty ? lastSegment : url;
  } catch (_) {
    return url;
  }
}

// Reuse the SegmentedCirclePainter from desktop_view.dart
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
    this.gapAngle = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final totalAngle = 2 * 3.14159;
    final segmentAngle = (totalAngle - (total * gapAngle)) / total;

    double startAngle = -3.14159 / 2;

    for (int i = 0; i < total; i++) {
      final isCompleted = i < progress;
      final color = isCompleted ? completedColor : uncompletedColor;

      final paint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, segmentAngle, false, paint);

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
