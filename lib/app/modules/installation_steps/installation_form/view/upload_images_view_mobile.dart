import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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

class UploadImagesViewMobile extends StatefulWidget {
  const UploadImagesViewMobile({super.key});

  @override
  State<UploadImagesViewMobile> createState() => _UploadImagesViewMobileState();
}

class _UploadImagesViewMobileState extends State<UploadImagesViewMobile> {
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
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
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
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(color: AppColors.redColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(Icons.delete_rounded, size: 48, color: AppColors.redColor),
                ),
                const Gap(20),
                AppText(
                  'Delete Image?',
                  style: AppTextStyle.semiBold22(color: AppColors.black002432),
                  textAlign: TextAlign.center,
                ),
                const Gap(12),
                AppText(
                  'Are you sure you want to delete this image? This action cannot be undone.',
                  style: AppTextStyle.regular14(color: AppColors.greyADB9BD),
                  textAlign: TextAlign.center,
                ),
                const Gap(30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.of(dialogContext).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.greyADB9BD, width: 1.5),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyle.medium14(color: AppColors.black002432),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          controller.deleteImageLoader.value = true;
                          final success = await controller.removeFirebaseImage(
                            sectionKey: sectionKey,
                            imageUrl: imageUrl,
                            stepIndex: stepIndex,
                            dataIndex: dataIndex,
                          );

                          if (success) {
                            controller.deleteImageLoader.value = false;
                            Navigator.of(dialogContext).pop();

                            AppFunctions.showToast(
                              message: 'Image deleted successfully!',
                              toastType: ToastificationType.success,
                            );
                          } else {
                            controller.deleteImageLoader.value = false;
                            AppFunctions.showToast(
                              message: 'Failed to delete image',
                              toastType: ToastificationType.error,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Obx(() {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.redColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: controller.deleteImageLoader.value
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(color: AppColors.whiteColor),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.delete_rounded, size: 16, color: AppColors.whiteColor),
                                      const Gap(6),
                                      Text('Delete', style: AppTextStyle.medium14(color: AppColors.whiteColor)),
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
                    InkWell(
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        controller.removeImage(sectionKey, index);
                        // Controller's removeImage already updates both IDs
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.redColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.redColor.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.delete_rounded, size: 18, color: AppColors.whiteColor),
                            const Gap(8),
                            Text('Delete', style: AppTextStyle.semiBold16(color: AppColors.whiteColor)),
                          ],
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
        return SingleChildScrollView(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonButton(
                height: 45,
                text: "",
                color: AppColors.primaryColor,
                // textColor: AppColors.black002432,
                width: double.infinity,
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
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(color: AppColors.black002432),
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
              Gap(20),
              Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,

                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => controller.setUploadView(false),
                      child: ClipOval(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.greyADB9BD),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_outlined, color: AppColors.black002432, size: 14),
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: AppText(
                      controller.selectedCardTitle ?? AppStrings.roofAndShading,
                      style: AppTextStyle.extraBold28(),
                    ),
                  ),
                ],
              ),
              const Gap(24),

              // Progress Steps
              // _buildStepProgress(controller),
              // const Gap(24),

              // Dynamic sections from Firebase
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection(PrefService.getString(PrefService.dealName)).limit(1).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show shimmer loading for main list
                    return GetBuilder<InstallationStepsController>(
                      id: 'main_list',
                      builder: (controller) {
                        return Column(
                          children: List.generate(4, (index) {
                            return Padding(padding: const EdgeInsets.only(bottom: 20), child: _buildShimmerSection());
                          }),
                        );
                      },
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

                  if (steps == null || steps.isEmpty || controller.selectedStepIndex == null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AppText('No data found!!!', style: AppTextStyle.medium16(color: AppColors.black002432)),
                      ),
                    );
                  }

                  // Get the selected step
                  final stepIndex = controller.selectedStepIndex!;
                  if (stepIndex >= steps.length) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AppText(
                          'Invalid step index',
                          style: AppTextStyle.medium16(color: AppColors.black002432),
                        ),
                      ),
                    );
                  }

                  final stepData = steps[stepIndex] as Map<String, dynamic>;
                  final step = InstallationStep.fromMap(stepData);

                  // Get data items
                  final dataItems = step.data ?? [];

                  if (dataItems.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AppText(
                          'No upload sections found',
                          style: AppTextStyle.medium16(color: AppColors.black002432),
                        ),
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
                            context: context,
                            controller: controller,
                            title: dataItem.title ?? 'Section ${index + 1}',
                            sectionKey: sectionKey,
                            instruction: dataItem.title ?? 'Upload images for this section',
                            maxCount: dataItem.count ?? 5,
                            refImage: dataItem.refImage ?? '',
                            stepIndex: stepIndex,
                            dataIndex: index,
                          ),
                          if (index < dataItems.length - 1) const Gap(20),
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

  Widget _buildStepProgress(InstallationStepsController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        int step = index + 1;
        Color stepColor;
        if (step <= 2) {
          stepColor = AppColors.primaryColor;
        } else if (step <= 4) {
          stepColor = Colors.red;
        } else {
          stepColor = AppColors.greyADB9BD;
        }

        return Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: stepColor, shape: BoxShape.circle),
              child: Center(
                child: AppText('$step', style: AppTextStyle.semiBold12(color: AppColors.whiteColor)),
              ),
            ),
            if (step < 7) const Gap(6),
          ],
        );
      }),
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
    return StreamBuilder<DocumentSnapshot>(
      stream: _getProjectStream(),
      builder: (context, projectSnapshot) {
        // Show shimmer for images list when loading
        if (projectSnapshot.connectionState == ConnectionState.waiting) {
          return GetBuilder<InstallationStepsController>(
            id: 'images_list_$sectionKey',
            builder: (controller) {
              return _buildShimmerImagesList();
            },
          );
        }

        // Get Firebase images from project
        List<String> firebaseImages = [];
        if (projectSnapshot.hasData && projectSnapshot.data!.exists) {
          final projectData = projectSnapshot.data!.data() as Map<String, dynamic>?;
          final installationSteps = projectData?[PrefService.getString(PrefService.dealName)] as Map<String, dynamic>?;
          final stepData = installationSteps?[stepIndex.toString()] as Map<String, dynamic>?;
          final dataField = stepData?['data'] as Map<String, dynamic>?;
          final dataItem = dataField?[dataIndex.toString()] as Map<String, dynamic>?;
          final images = dataItem?['images'] as List<dynamic>?;
          if (images != null) {
            firebaseImages = images
                .map((e) {
                  if (e is Map<String, dynamic>) {
                    final url = e['image'] ?? e['imageUrl'] ?? e['url'];
                    return url?.toString() ?? '';
                  }
                  return e.toString();
                })
                .where((url) => url.isNotEmpty)
                .toList();
          }
        }

        // Load Firebase images once when section is first built
        if (!controller.firebaseImagesBySection.containsKey(sectionKey) &&
            !(controller.isLoadingFirebaseImages[sectionKey] ?? false)) {
          controller.loadFirebaseImagesForSection(sectionKey: sectionKey, stepIndex: stepIndex, dataIndex: dataIndex);
        }

        return GetBuilder<InstallationStepsController>(
          id: 'firebase_images_$sectionKey',
          builder: (controller) {
            // Use cached images if available during loading, otherwise use current images
            final isLoading = controller.isLoadingFirebaseImages[sectionKey] ?? false;
            final controllerFirebaseImages = isLoading
                ? (controller.cachedFirebaseImages[sectionKey] ?? controller.firebaseImagesBySection[sectionKey] ?? [])
                : (controller.firebaseImagesBySection[sectionKey] ?? []);
            final firebaseImagesCount = controllerFirebaseImages.length;

            return GetBuilder<InstallationStepsController>(
              id: 'status_area_$sectionKey',
              builder: (controller) {
                final uploadedCount = controller.getUploadedCount(sectionKey);
                final uploadedImages = controller.uploadedImages[sectionKey] ?? [];
                final totalCount = firebaseImagesCount + uploadedCount;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.whiteColor, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row with progress indicator
                      Row(
                        children: [
                          Expanded(child: Text(title, style: AppTextStyle.extraBold28())),
                          const Gap(12),
                          Stack(
                            alignment: AlignmentGeometry.center,
                            children: [
                              _buildProgressIndicator(totalCount, maxCount),
                              AppText('$totalCount/$maxCount', style: AppTextStyle.semiBold12()),
                            ],
                          ),
                        ],
                      ),
                      const Gap(16),

                      // Check Reference Image button
                      MouseRegion(
                        cursor: SystemMouseCursors.click,

                        child: InkWell(
                          onTap: () {
                            ReferenceImageInstructionsDialog.show(context, refImage);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.greyADB9BD),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppStrings.checkReferenceImage, style: AppTextStyle.medium13()),
                                const Gap(6),
                                Image.asset(Assets.icons.icGalleryPng.path, scale: 3),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Gap(16),

                      // Upload area
                      _buildUploadArea(
                        controller: controller,
                        sectionKey: sectionKey,
                        instruction: instruction,
                        uploadedCount: uploadedCount,
                        maxCount: maxCount,
                        firebaseImagesCount: firebaseImagesCount,
                      ),
                      const Gap(16),

                      // Uploaded files list - show both Firebase and uploaded images
                      if (firebaseImages.isNotEmpty || uploadedImages.isNotEmpty) ...[
                        AppText(AppStrings.uploadedFiles, style: AppTextStyle.semiBold16()),
                        const Gap(12),
                        // Firebase images (from project)
                        ...firebaseImages.asMap().entries.map((entry) {
                          final index = entry.key;
                          return Column(
                            children: [
                              _buildFirebaseImageItem(
                                controller: controller,
                                sectionKey: sectionKey,
                                imageUrl: entry.value,
                                index: index,
                                stepIndex: stepIndex,
                                dataIndex: dataIndex,
                              ),
                              if (index < firebaseImages.length - 1 || uploadedImages.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  width: double.infinity,
                                  height: 1,
                                  color: AppColors.greyADB9BD,
                                ),
                            ],
                          );
                        }),
                        // Uploaded images (bytes)
                        ...uploadedImages.asMap().entries.map((entry) {
                          final index = entry.key;
                          final image = entry.value;
                          return Column(
                            children: [
                              _buildUploadedFileItem(
                                controller: controller,
                                sectionKey: sectionKey,
                                image: image,
                                index: index,
                              ),
                              if (index < uploadedImages.length - 1)
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  width: double.infinity,
                                  height: 1,
                                  color: AppColors.greyADB9BD,
                                ),
                            ],
                          );
                        }),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Get project document stream
  Stream<DocumentSnapshot> _getProjectStream() {
    return Stream.fromFuture(_getProjectDocument()).asyncExpand((projectRef) {
      if (projectRef == null) {
        return Stream<DocumentSnapshot>.empty();
      }
      return projectRef.snapshots();
    });
  }

  Future<DocumentReference?> _getProjectDocument() async {
    try {
      final userId = PrefService.getString(PrefService.userId);
      if (userId.isEmpty) {
        return null;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('project')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final projectRef = querySnapshot.docs.first.reference;

      // Ensure installation_steps is initialized
      final controller = Get.find<InstallationStepsController>();
      await controller.initializeInstallationStepsInProject();

      return projectRef;
    } catch (e) {
      debugPrint('Error getting project document: $e');
      return null;
    }
  }

  Widget _buildFirebaseImageItem({
    required InstallationStepsController controller,
    required String sectionKey,
    required String imageUrl,
    required int index,
    required int stepIndex,
    required int dataIndex,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Builder(
              builder: (context) {
                final tempKey = '$sectionKey|$imageUrl';
                final temporaryImage = controller.temporaryEditedInstallationStepImages[tempKey];

                if (temporaryImage != null) {
                  return InkWell(
                    onTap: () {
                      context.push(AppRoutes.imagePreview, extra: {'isNetwork': false, 'imageByte': temporaryImage});
                    },
                    child: Image.memory(temporaryImage, width: 50, height: 50, fit: BoxFit.cover),
                  );
                }

                return InkWell(
                  onTap: () {
                    context.push(AppRoutes.imagePreview, extra: {'isNetwork': true, 'image': imageUrl});
                  },
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 50,
                      height: 50,
                      color: AppColors.greyADB9BD,
                      child: Icon(Icons.broken_image, color: AppColors.black002432),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 50,
                      height: 50,
                      color: AppColors.greyADB9BD,
                      child: Icon(Icons.broken_image, color: AppColors.black002432),
                    ),
                  ),
                );
              },
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fileNameFromUrl(imageUrl),
                  style: AppTextStyle.semiBold14(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              final tempKey = '$sectionKey|$imageUrl';
              final tempBytes = controller.temporaryEditedInstallationStepImages[tempKey];

              // If we have edited bytes currently displayed, open editor from memory
              if (tempBytes != null) {
                EditImageDialog.show(
                  context,
                  image: UploadedImage(name: _fileNameFromUrl(imageUrl), bytes: tempBytes),
                  onSave: (editedBytes) async {
                    Navigator.of(context).pop();

                    controller.temporaryEditedInstallationStepImages[tempKey] = editedBytes;
                    controller.update(['firebase_images_$sectionKey']);

                    controller
                        .updateInstallationStepImageInFirebase(
                          context: context,
                          sectionKey: sectionKey,
                          oldImageUrl: imageUrl,
                          editedBytes: editedBytes,
                          imageName: _fileNameFromUrl(imageUrl),
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
                image: imageUrl,
                onSave: (editedBytes) async {
                  Navigator.of(context).pop();

                  // Store edited image locally immediately for instant display
                  controller.temporaryEditedInstallationStepImages[tempKey] = editedBytes;
                  controller.update(['firebase_images_$sectionKey']);

                  // Upload to Firebase in background (non-blocking)
                  controller
                      .updateInstallationStepImageInFirebase(
                        context: context,
                        sectionKey: sectionKey,
                        oldImageUrl: imageUrl,
                        editedBytes: editedBytes,
                        imageName: _fileNameFromUrl(imageUrl),
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
            },
            child: Assets.icons.icEdit.svg(),
          ),
          // Delete button for Firebase images
          InkWell(
            onTap: () {
              _showDeleteFirebaseImageDialog(context, controller, sectionKey, imageUrl, stepIndex, dataIndex);
            },
            child: Image.asset(Assets.icons.icDeletePng.path, height: 32, width: 20),
          ),
        ],
      ),
    );
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
        compressionQuality: 50
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

        // Safety check: ensure total never exceeds maxCount
        final newTotal = currentFirebaseCount + currentImages.length + filesToAdd.length;
        if (newTotal > maxCount) {
          // Trim to exact limit
          final allowedCount = maxCount - currentFirebaseCount - currentImages.length;
          final trimmedFiles = filesToAdd.take(allowedCount).toList();
          controller.uploadedImages[sectionKey] = [...currentImages, ...trimmedFiles];
        } else {
          controller.uploadedImages[sectionKey] = [...currentImages, ...filesToAdd];
        }

        // Update both IDs so upload area and status area both rebuild
        controller.update(['firebase_images_$sectionKey', 'status_area_$sectionKey']);
      }
    }

    // Use DropzoneView for web, InkWell for mobile
    if (kIsWeb) {
      DropzoneViewController? dragController;

      return SizedBox(
        width: double.infinity,
        height: 280,
        child: Stack(
          children: [
            // Dropzone overlay
            DropzoneView(
              operation: DragOperation.copy,
              cursor: CursorType.grab,
              onCreated: (ctrl) => dragController = ctrl,
              onDropFiles: (files) async {
                if (files == null || files.isEmpty || dragController == null) return;

                // Recalculate canUpload and counts inside handler to get latest state
                final currentFirebaseImages = controller.firebaseImagesBySection[sectionKey] ?? [];
                final currentUploadedCount = controller.getUploadedCount(sectionKey);
                final isLoading = controller.isLoadingFirebaseImages[sectionKey] ?? false;
                final currentTotalCount = currentUploadedCount + currentFirebaseImages.length;
                final currentCanUpload = !isLoading && currentTotalCount < maxCount;

                if (!currentCanUpload) {
                  AppFunctions.showToast(
                    message: 'Maximum image limit ($maxCount) reached',
                    toastType: ToastificationType.error,
                  );
                  return;
                }

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

                    // Validate file size (5 MB limit)
                    const maxFileSize = 5 * 1024 * 1024; // 5 MB in bytes
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
                    message: '${oversizedFileNames.length} image(s) exceed the 5 MB size limit and were not uploaded',
                    toastType: ToastificationType.error,
                  );
                }

                if (newFiles.isNotEmpty) {
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
                }
              },
            ),
            // Content overlay with tap handler - only intercepts taps, allows drag events to pass through
            Positioned.fill(
              child: _TapOnlyOverlayMobile(onTap: pickFiles, canUpload: canUpload, instruction: instruction),
            ),
          ],
        ),
      );
    } else {
      // Mobile: Use InkWell with file picker
      return InkWell(
        onTap: canUpload ? pickFiles : null,
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            radius: const Radius.circular(20),
            dashPattern: const [10, 10],
            color: canUpload ? AppColors.purpleColor : Colors.transparent,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 75),
            decoration: BoxDecoration(
              border: canUpload == false
                  ? Border.all(color: AppColors.purpleColor, style: BorderStyle.solid, width: 1)
                  : null,
              borderRadius: BorderRadius.circular(20),
              color: canUpload ? AppColors.whiteColor : AppColors.whiteF5F5F5,
            ),
            child: canUpload
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(Assets.icons.icImageAdd.path, scale: 3),
                      const Gap(14),
                      AppText(
                        AppStrings.dragAndDropOrSelectFile,
                        style: AppTextStyle.extraBold14(),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(10),
                      AppText(instruction, style: AppTextStyle.regular14(), textAlign: TextAlign.center),
                    ],
                  )
                : Center(
                    child: AppText(
                      AppStrings.maximumImagesReached,
                      style: AppTextStyle.medium14(color: AppColors.purpleColor),
                    ),
                  ),
          ),
        ),
      );
    }
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

  Widget _buildUploadedFileItem({
    required InstallationStepsController controller,
    required String sectionKey,
    required UploadedImage image,
    required int index,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              context.push(AppRoutes.imagePreview, extra: {'isNetwork': false, 'imageByte': image.bytes});
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(image.bytes, width: 50, height: 50, fit: BoxFit.cover),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(image.name, style: AppTextStyle.semiBold14(), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (image.isUploadFailed) ...[
                  const Gap(4),
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange),
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
              EditImageDialog.show(
                context,
                image: image,
                onSave: (editedBytes) {
                  controller.updateImage(sectionKey, index, editedBytes);
                  controller.update(['status_area_$sectionKey']);
                  Navigator.of(context).pop();
                },
              );
            },
            child: Assets.icons.icEdit.svg(),
          ),

          InkWell(
            onTap: () => _showDeleteConfirmationDialog(context, controller, sectionKey, index),
            child: Image.asset(Assets.icons.icDeletePng.path, height: 32, width: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerSection() {
    return Shimmer.fromColors(
      baseColor: AppColors.greyADB9BD.withOpacity(0.3),
      highlightColor: AppColors.greyADB9BD.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.whiteColor, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 28,
                    decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const Gap(12),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: AppColors.greyADB9BD, shape: BoxShape.circle),
                ),
              ],
            ),
            const Gap(16),
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(20)),
            ),
            const Gap(16),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(20)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerImagesList() {
    return Shimmer.fromColors(
      baseColor: AppColors.greyADB9BD.withOpacity(0.3),
      highlightColor: AppColors.greyADB9BD.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.whiteColor, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 28,
                    decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const Gap(12),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: AppColors.greyADB9BD, shape: BoxShape.circle),
                ),
              ],
            ),
            const Gap(16),
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(20)),
            ),
            const Gap(16),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(color: AppColors.greyADB9BD, borderRadius: BorderRadius.circular(20)),
            ),
            const Gap(16),
            // Shimmer for images list
            AppText(AppStrings.uploadedFiles, style: AppTextStyle.semiBold16()),
            const Gap(12),
            ...List.generate(3, (index) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.greyADB9BD,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: Container(
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.greyADB9BD,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const Gap(12),
                        Container(
                          width: 20,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.greyADB9BD,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index < 2)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: double.infinity,
                      height: 1,
                      color: AppColors.greyADB9BD,
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// Custom widget that only handles taps, allows drag events to pass through (for web)
class _TapOnlyOverlayMobile extends StatefulWidget {
  final VoidCallback onTap;
  final bool canUpload;
  final String instruction;

  const _TapOnlyOverlayMobile({required this.onTap, required this.canUpload, required this.instruction});

  @override
  State<_TapOnlyOverlayMobile> createState() => _TapOnlyOverlayMobileState();
}

class _TapOnlyOverlayMobileState extends State<_TapOnlyOverlayMobile> {
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
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: const Radius.circular(20),
          dashPattern: const [10, 10],
          color: widget.canUpload ? AppColors.purpleColor : Colors.transparent,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 75),
          decoration: BoxDecoration(
            border: widget.canUpload == false
                ? Border.all(color: AppColors.purpleColor, style: BorderStyle.solid, width: 1)
                : null,
            borderRadius: BorderRadius.circular(20),
            color: widget.canUpload ? AppColors.whiteColor : AppColors.whiteF5F5F5,
          ),
          child: widget.canUpload
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(Assets.icons.icImageAdd.path, scale: 3),
                    const Gap(14),
                    AppText(
                      AppStrings.dragAndDropOrSelectFile,
                      style: AppTextStyle.extraBold14(),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(10),
                    AppText(widget.instruction, style: AppTextStyle.regular14(), textAlign: TextAlign.center),
                  ],
                )
              : Center(
                  child: AppText(
                    AppStrings.maximumImagesReached,
                    style: AppTextStyle.medium14(color: AppColors.purpleColor),
                  ),
                ),
        ),
      ),
    );
  }
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
