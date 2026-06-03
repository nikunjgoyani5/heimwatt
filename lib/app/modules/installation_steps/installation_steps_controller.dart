import 'dart:developer';
import 'dart:async';
import 'dart:io';
import 'dart:html' as html;

import 'dart:typed_data';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:heimwatt/app/data/common_widget/edit_image_dialog.dart';
import 'package:heimwatt/app/data/common_widget/netwrok_image_edit_dialog.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_form/models/installation_step_model.dart';
import 'package:heimwatt/repository/main_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:toastification/toastification.dart';
import 'package:video_player/video_player.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:heimwatt/app/utils/pref_service.dart';
import 'package:heimwatt/app/utils/app_functions.dart';
import 'package:heimwatt/app/services/pdf_generation_service.dart';
import 'package:screenshot/screenshot.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../utils/exports.dart';
import 'media_library_form_screen/Views/checklist_drawer.dart';
import 'address_selection_screen/models/place_suggestion_model.dart';
import 'address_selection_screen/models/geocode_model.dart';

class UploadedImage {
  final String name;
  final Uint8List bytes;
  final bool isUploadFailed;

  UploadedImage({required this.name, required this.bytes, this.isUploadFailed = false});
}

enum StepStatus { empty, partial, complete }

class StepStatusResult {
  final int stepCount;
  final List<StepStatus> statuses;

  StepStatusResult({required this.stepCount, required this.statuses});
}

class InstallationStepsController extends GetxController {
  int currentStep = 1;

  Map<int, int> cardProgress = {1: 3, 2: 3, 3: 3, 4: 3, 5: 3, 6: 3, 7: 3};

  int totalItemsPerCard = 5;

  bool isUpload = false;
  bool ispdf = false;
  bool isChecklistDrawerOpen = false;
  String? selectedCardTitle;
  int? selectedStepIndex; // Store the step index for Firebase data retrieval
  String? pdfNetworkUrl; // Store the network URL of the generated PDF
  final RxBool isGeneratingPdf = false.obs; // Loading state for PDF generation
  final RxDouble pdfGenerationProgress = 0.0.obs; // Progress for PDF generation (0.0 to 1.0)
  final RxString userRole = ''.obs; // Store the user role from Firestore
  final RxBool isUploadingToHubSpot = false.obs; // Loading state for HubSpot upload
  final RxDouble hubSpotUploadProgress = 0.0.obs; // Progress for HubSpot upload (0.0 to 1.0)
  Timer? _hubSpotProgressTimer; // Timer for smooth HubSpot progress animation
  Map<String, bool> expandedState = {};
  ChecklistItem? enlargedItem;
  ChecklistSection? enlargedItemSection;
  int totalPdfPage = 0;
  Uint8List? pdfBytes;

  // send compressed to API

  // Checklist data storage
  Map<String, dynamic>? installFormData;
  Map<String, dynamic>? projectData;
  final RxBool isLoadingChecklistData = false.obs;

  // Screen flow management
  bool showProjectScreen = true;
  bool showTutorialScreen = false;
  bool isTutorialSection = false;
  bool showAddressSelectionScreen = false;
  bool showStepTypeScreen = false;
  bool showMediaLibraryScreen = false;
  bool showInstallationFormScreen = false;

  // Store uploaded images for each section
  Map<String, List<UploadedImage>> uploadedImages = {
    'houseAndRoofOverview': [],
    'roofSurface': [],
    'tileSize': [],
    'shadingObjects': [],
    'mediaLibrary': [], // Media library images
  };

  // Track loading state for individual items (sectionKey -> item index in allImages list)
  Map<String, int?> loadingItemIndex = {};

  // Track loading state by unique identifier (sectionKey -> imageUrl for Firebase images)
  Map<String, String?> loadingItemIdentifier = {};

  // Track Firebase images that are being removed/edited (sectionKey -> Set of imageUrls)
  // This allows us to hide them from display immediately while async removal happens
  Map<String, Set<String>> removedFirebaseImages = {};

  // Cache last known Firebase images per section to prevent blank screen during updates
  // Format: sectionKey -> List of image data maps with 'image' (URL) and 'name' fields
  Map<String, List<Map<String, dynamic>>> cachedFirebaseImages = {};

  // Store Firebase images per section (sectionKey -> List of image data maps with 'image' (URL) and 'name' fields)
  // This replaces StreamBuilder - we load once and update manually
  Map<String, List<Map<String, dynamic>>> firebaseImagesBySection = {};

  // Track loading state for Firebase images per section
  Map<String, bool> isLoadingFirebaseImages = {};

  // Store temporary edited images for media library (index -> bytes)
  // This allows showing edited image immediately while Firebase upload happens in background
  Map<int, Uint8List> temporaryEditedMediaLibraryImages = {};

  // Store temporary edited images for installation steps (sectionKey + imageUrl -> bytes)
  // This allows showing edited image immediately while Firebase upload happens in background
  Map<String, Uint8List> temporaryEditedInstallationStepImages = {};

  // Store media library bulk import list (fetched once, updated manually)
  List<Map<String, dynamic>> mediaLibraryBulkImportList = [];
  bool isLoadingMediaLibrary = false;
  Future<List<Map<String, dynamic>>>? mediaLibraryFuture;

  // Load media library images once (replaces StreamBuilder)
  Future<List<Map<String, dynamic>>> loadMediaLibraryImages() async {
    try {
      isLoadingMediaLibrary = true;
      // Don't call update() here - FutureBuilder will handle UI updates

      final userId = PrefService.getString(PrefService.userId);
      if (userId.isEmpty) {
        mediaLibraryBulkImportList = [];
        isLoadingMediaLibrary = false;
        return [];
      }

      final projectRef = await _getProjectDocument();
      if (projectRef == null) {
        mediaLibraryBulkImportList = [];
        isLoadingMediaLibrary = false;
        return [];
      }

      final projectDoc = await projectRef.get();
      final projectData = projectDoc.data() as Map<String, dynamic>?;

      if (projectData == null || !projectData.containsKey('bulk_import')) {
        mediaLibraryBulkImportList = [];
        isLoadingMediaLibrary = false;
        return [];
      }

      final bulkImport = projectData['bulk_import'];
      if (bulkImport == null) {
        mediaLibraryBulkImportList = [];
        isLoadingMediaLibrary = false;
        return [];
      }

      // Convert to list if it's a map (Firestore sometimes returns maps with numeric keys)
      List<Map<String, dynamic>> bulkImportList = [];
      if (bulkImport is List) {
        bulkImportList = bulkImport.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      } else if (bulkImport is Map) {
        bulkImportList = bulkImport.values.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }

      mediaLibraryBulkImportList = bulkImportList;
      isLoadingMediaLibrary = false;
      // Don't call update() here - FutureBuilder will handle UI updates
      return bulkImportList;
    } catch (e) {
      debugPrint('Error loading media library images: $e');
      mediaLibraryBulkImportList = [];
      isLoadingMediaLibrary = false;
      // Don't call update() here - FutureBuilder will handle UI updates
      return [];
    }
  }

  // Refresh media library images (call after add/update/delete)
  void refreshMediaLibraryImages() {
    mediaLibraryFuture = loadMediaLibraryImages();
    // Schedule update after current frame to avoid build phase issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      update();
    });
  }

  /// Normalize `images` field coming from Firestore.
  /// Supports both legacy `List<String>` and new `List<Map>` formats:
  /// - "https://..."                      -> {'image': 'https://...'}
  /// - {'image': 'https://...', 'name': 'a.jpg'} stays as-is
  /// - {'imageUrl': '...', 'image_name': 'a.jpg'} is mapped to image/name
  List<Map<String, dynamic>> _normalizeImageList(dynamic rawImages) {
    final List<Map<String, dynamic>> result = [];

    if (rawImages is List) {
      for (final item in rawImages) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item as Map);
          final dynamic imageVal = map['image'] ?? map['imageUrl'] ?? map['url'];
          final dynamic nameVal = map['name'] ?? map['image_name'];

          if (imageVal != null && imageVal.toString().isNotEmpty) {
            final normalized = <String, dynamic>{'image': imageVal.toString()};
            if (nameVal != null && nameVal.toString().isNotEmpty) {
              normalized['name'] = nameVal.toString();
            }
            result.add(normalized);
          }
        } else if (item is String && item.isNotEmpty) {
          result.add({'image': item});
        }
      }
    }

    return result;
  }

  void toggleUploadView() {
    isUpload = !isUpload;
    update();
  }

  void setUploadView(bool value, {String? cardTitle, int? stepIndex}) {
    isUpload = value;
    if (cardTitle != null) {
      selectedCardTitle = cardTitle;
    }
    if (stepIndex != null) {
      selectedStepIndex = stepIndex;
    }
    update();
  }

  void setPdfView(bool value) {
    ispdf = value;
    update();
  }

  VideoPlayerController? videoController;
  final RxBool isVideoInitialized = false.obs;
  final RxBool showPlayButton = true.obs;
  bool hasPlayedOnce = false; // Track if user has played the video at least once
  String? instructionVideo;
  String? tutorialVideo;
  String? tutorialText;

  // Address selection
  TextEditingController addressSearchController = TextEditingController();
  final Set<int> selectedAddresses = <int>{};
  LatLng? selectedLocation;
  RxString selectedAddress = ''.obs;
  String? _mapImageUrl; // Store the uploaded map screenshot URL
  final RxList<PlaceSuggestion> addressSuggestions = <PlaceSuggestion>[].obs;
  final RxBool isLoadingSuggestions = false.obs;
  final RxBool isGeocoding = false.obs;
  final Dio _dio = Dio();
  static const String _googlePlacesApiKey = 'AIzaSyBQRdjBmH5EAgdmVvCynK_t621G4Qa2-bo';

  // Germany bounds
  static LatLngBounds germanyBounds = LatLngBounds(
    southwest: LatLng(47.2701, 5.8663),
    northeast: LatLng(55.0992, 15.0419),
  );

  // Check if location is within Germany bounds
  bool isLocationInGermany(LatLng location) {
    return germanyBounds.contains(location);
  }

  // Check if geocoding result is in Germany
  bool _isAddressInGermany(Map<String, dynamic> geocodeResult) {
    try {
      final addressComponents = geocodeResult['address_components'] as List<dynamic>?;
      if (addressComponents != null) {
        for (var component in addressComponents) {
          final types = component['types'] as List<dynamic>?;
          if (types != null && types.contains('country')) {
            final shortName = component['short_name'] as String?;
            return shortName == 'DE';
          }
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error checking if address is in Germany: $e');
      return false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    getInstructionVideo();
    fetchUserRole();
    loadPdfUrlFromProject();
    // Keep project.installation_steps in sync with the latest install_form template
    initializeInstallationStepsInProject();

    _startScreenFlow();
  }


  void _startScreenFlow() {
    // After 2 seconds, show tutorial screen
    Future.delayed(const Duration(seconds: 2), () {
      if (showProjectScreen) {
        showProjectScreen = false;
        showTutorialScreen = true;
        isTutorialSection = true;
        update();
      }
    });
  }

  void navigateToAddressSelection() {
    showTutorialScreen = false;
    showAddressSelectionScreen = true;
    update();
  }

  Future<void> captureMapScreenshot(ScreenshotController screenshotController) async {
    try {
      // Capture the screenshot
      final Uint8List? imageBytes = await screenshotController.capture();
      if (imageBytes == null) {
        debugPrint('Failed to capture screenshot');
        return;
      }

      // Upload to Firebase Storage
      final userId = PrefService.getString(PrefService.userId);
      if (userId.isEmpty) {
        debugPrint('User ID not found in preferences');
        return;
      }

      final storage = FirebaseStorage.instance;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'map_screenshots/$userId/map_$timestamp.png';
      final ref = storage.ref().child(fileName);

      // Upload the image
      await ref.putData(imageBytes, SettableMetadata(contentType: 'image/png'));

      // Get the download URL
      _mapImageUrl = await ref.getDownloadURL();
      debugPrint('Map screenshot uploaded: $_mapImageUrl');
    } catch (e) {
      debugPrint('Error capturing/uploading map screenshot: $e');
      _mapImageUrl = null; // Reset on error
    }
  }

  RxBool addressLoader = false.obs;

  Future<void> navigateToStepType(BuildContext context, {ScreenshotController? screenshotController}) async {
    try {
      addressLoader.value = true;
      // if (screenshotController != null) {
      //   await captureMapScreenshot(screenshotController);
      // }

      String staticMapUrl =
          'https://maps.googleapis.com/maps/api/staticmap'
          '?center=${selectedLocation!.latitude},${selectedLocation!.longitude}'
          '&zoom=19'
          '&size=600x400'
          '&maptype=normal'
          '&markers=color:red%7C${selectedLocation!.latitude},${selectedLocation!.longitude}'
          '&key=AIzaSyBQRdjBmH5EAgdmVvCynK_t621G4Qa2-bo';

      debugPrint('NETWORK URL $staticMapUrl');
      _mapImageUrl = staticMapUrl;
      if (!context.mounted) return;
      await _updateProjectAddress(context);

      showAddressSelectionScreen = false;
      showStepTypeScreen = true;
      addressLoader.value = false;
      updateLocationAPI(context: context);
      update();
    } catch (e) {
      addressLoader.value = false;
      debugPrint(e.toString());
    }
  }

  Future<void> updateLocationAPI({required BuildContext context}) async {
    await mainRepository.updateLocationById(
      body: {
        "objectAddress": {"lat": selectedLocation!.latitude, "lng": selectedLocation!.longitude},
      },
      dealId: PrefService.getString(PrefService.dealId),
      onSuccess: (dynamic response) {
        try {
          debugPrint('success:::${response.toString()} ');
        } catch (e) {
          debugPrint('error:::${response.toString()} ');
        }
      },
      onError: (dynamic error) {
        debugPrint('error:::$error');
        String message = error.message;
      },
    );
  }

  Future<void> _updateProjectAddress(BuildContext context) async {
    try {
      final userId = PrefService.getString(PrefService.userId);
      if (userId.isEmpty) {
        debugPrint('User ID not found in preferences');
        return;
      }

      if (selectedLocation == null) {
        debugPrint('Selected location is null');
        return;
      }

      // Find the project document for this user
      final querySnapshot = await FirebaseFirestore.instance
          .collection('project')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('Project not found for user: $userId');
        if (!context.mounted) return;
        AppFunctions.showToast(
          message: 'Project not found. Please try logging in again.',
          toastType: ToastificationType.error,
        );
        return;
      }

      final projectDoc = querySnapshot.docs.first;

      // Update the project document with address data
      await projectDoc.reference.update({
        'address': {
          'address': selectedAddress.toString(),
          'image': _mapImageUrl ?? 'test.png',
          'lat': selectedLocation!.latitude.toString(),
          'lon': selectedLocation!.longitude.toString(),
        },
      });

      debugPrint('Project address updated successfully');
      if (!context.mounted) return;

      AppFunctions.showToast(message: 'Address confirmed successfully!', toastType: ToastificationType.success);
    } catch (e) {
      debugPrint('Error updating project address: $e');
      AppFunctions.showToast(message: 'Failed to save address. Please try again.', toastType: ToastificationType.error);
    }
  }

  void navigateToMediaLibrary() {
    showStepTypeScreen = false;
    showMediaLibraryScreen = true;
    update();
  }

  void navigateToInstallationForm() {
    showStepTypeScreen = false;
    showInstallationFormScreen = true;
    update();
  }

  void navigateBackToStepType() {
    showMediaLibraryScreen = false;
    showInstallationFormScreen = false;
    showStepTypeScreen = true;
    update();
  }

  void navigateToTutorial() {
    showProjectScreen = false;
    showAddressSelectionScreen = false;
    showStepTypeScreen = false;
    showMediaLibraryScreen = false;
    showInstallationFormScreen = false;
    showTutorialScreen = true;
    isTutorialSection = true;
    update();
  }

  void navigateToProject() {
    showAddressSelectionScreen = false;
    showStepTypeScreen = false;
    showMediaLibraryScreen = false;
    showInstallationFormScreen = false;
    showTutorialScreen = false;
    showProjectScreen = true;
    update();
    _startScreenFlow();
  }

  Future<void> _initializeVideo(String url) async {
    try {
      videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await videoController!.initialize();
      isVideoInitialized.value = true;
      videoController!.addListener(_videoListener);

      update();
    } catch (e) {
      debugPrint('Error initializing video: $e');
      isVideoInitialized.value = false;
      update();
    }
  }

  void _videoListener() {
    if (videoController != null) {
      final isPlaying = videoController!.value.isPlaying;
      final position = videoController!.value.position;
      final duration = videoController!.value.duration;

      // Check if video has ended or is very close to ending (check 100ms before to prevent white screen)
      if (duration.inMilliseconds > 0 && hasPlayedOnce) {
        final timeRemaining = duration.inMilliseconds - position.inMilliseconds;

        // If we're within 100ms of the end and still playing, loop immediately
        if (timeRemaining <= 100 && isPlaying) {
          videoController!.seekTo(Duration.zero);
          return; // Don't update UI, just loop
        }

        // If video has actually ended
        if (position.inMilliseconds >= duration.inMilliseconds) {
          if (hasPlayedOnce) {
            // Loop it automatically
            videoController!.seekTo(Duration.zero);
            videoController!.play();
            showPlayButton.value = false;
            update();
            return;
          }
        }
      }

      // Update play button state only when needed
      final shouldShowPlay = !isPlaying;
      if (showPlayButton.value != shouldShowPlay) {
        showPlayButton.value = shouldShowPlay;
        update();
      }
    }
  }

  void togglePlayPause() {
    if (videoController != null && isVideoInitialized.value) {
      if (videoController!.value.isPlaying) {
        videoController!.pause();
        showPlayButton.value = true;
      } else {
        // Mark that user has played the video at least once
        hasPlayedOnce = true;
        // If video has ended, restart from beginning
        final position = videoController!.value.position;
        final duration = videoController!.value.duration;
        if (duration.inMilliseconds > 0 && position.inMilliseconds >= (duration.inMilliseconds - 100)) {
          videoController!.seekTo(Duration.zero);
        }
        videoController!.play();
        showPlayButton.value = false;
      }
      update();
    }
  }

  @override
  void onClose() {
    videoController?.removeListener(_videoListener);
    final controllerToDispose = videoController;
    videoController = null;
    isVideoInitialized.value = false;
    // Defer dispose to next frame so widgets still in the tree (e.g. TutorialDashtop
    // during route transition) do not use the controller after dispose.
    if (controllerToDispose != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controllerToDispose.dispose();
      });
    }
    addressSearchController.dispose();
    super.onClose();
  }

  void removeImage(String section, int index) {
    final currentImages = uploadedImages[section] ?? [];
    if (index >= 0 && index < currentImages.length) {
      currentImages.removeAt(index);
      uploadedImages[section] = currentImages;
      // Update both IDs so upload area and status area both rebuild
      update(['firebase_images_$section', 'status_area_$section']);
    }
  }

  RxBool deleteImageLoader = false.obs;

  // Remove Firebase image immediately from database
  Future<bool> removeFirebaseImage({
    required String sectionKey,
    required String imageUrl,
    required int stepIndex,
    required int dataIndex,
  }) async {
    try {
      final projectRef = await _getProjectDocument();
      if (projectRef == null) {
        debugPrint('Project document not found');
        return false;
      }

      // Get existing images from project
      final existingImages = await getImagesFromProject(stepIndex: stepIndex, dataIndex: dataIndex);

      // Remove the image URL from the list (by matching the 'image' field)
      final updatedImages = existingImages.where((item) => (item['image']?.toString() ?? '') != imageUrl).toList();

      // Save updated images to project
      await saveImagesToProject(stepIndex: stepIndex, dataIndex: dataIndex, imageItems: updatedImages);

      // Update local Firebase images list (no StreamBuilder, manual update)
      // Store full image data (URL + name) instead of just URLs
      final updatedImageData = updatedImages.where((item) => item['image']?.toString().isNotEmpty ?? false).toList();
      firebaseImagesBySection[sectionKey] = updatedImageData;
      cachedFirebaseImages[sectionKey] = updatedImageData;
      update(['firebase_images_$sectionKey', 'status_area_$sectionKey']);

      return true;
    } catch (e) {
      debugPrint('Error removing Firebase image: $e');
      return false;
    }
  }

  // Update/replace existing Firebase image in installation steps (runs in background)
  Future<bool> updateInstallationStepImageInFirebase({
    required BuildContext context,
    required String sectionKey,
    required String oldImageUrl,
    required Uint8List editedBytes,
    required String imageName,
    required int stepIndex,
    required int dataIndex,
  }) async {
    try {
      // Don't show toast immediately - image is already displayed locally
      // AppFunctions.showToast(message: 'Uploading edited image...', toastType: ToastificationType.info);

      final userId = PrefService.getString(PrefService.userId);
      if (userId.isEmpty) {
        if (!context.mounted) return false;
        AppFunctions.showToast(message: 'User ID not found', toastType: ToastificationType.error);
        return false;
      }

      final projectRef = await _getProjectDocument();
      if (projectRef == null) {
        if (!context.mounted) return false;
        AppFunctions.showToast(message: 'Project not found', toastType: ToastificationType.error);
        return false;
      }

      // Upload edited image to Firebase Storage
      final storage = FirebaseStorage.instance;

      // Compress image to 50% quality before uploading
      final compressedBytes = await compressImage(editedBytes);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          '${PrefService.getString(PrefService.dealName)}/$userId/step_$stepIndex/data_$dataIndex/image_${timestamp}_edited.jpg';
      final ref = storage.ref().child(fileName);

      await ref.putData(compressedBytes, SettableMetadata(contentType: 'image/jpeg'));
      final newDownloadUrl = await ref.getDownloadURL();

      // Get existing images from project
      final existingImages = await getImagesFromProject(stepIndex: stepIndex, dataIndex: dataIndex);

      // Replace the old image URL with the new one (keep the same name)
      final updatedImages = existingImages.map((item) {
        if ((item['image']?.toString() ?? '') == oldImageUrl) {
          return {
            'image': newDownloadUrl,
            'name': imageName, // Keep the original name
          };
        }
        return item;
      }).toList();

      // Preload the new image before removing temporary image to prevent shimmer
      if (context.mounted) {
        try {
          await CachedNetworkImage.evictFromCache(newDownloadUrl);
          await precacheImage(CachedNetworkImageProvider(newDownloadUrl), context);
        } catch (e) {
          debugPrint('Error precaching image: $e');
        }
      }

      // Save updated images to project
      await saveImagesToProject(stepIndex: stepIndex, dataIndex: dataIndex, imageItems: updatedImages);

      // Update local Firebase images list
      final updatedImageData = updatedImages.where((item) => item['image']?.toString().isNotEmpty ?? false).toList();
      firebaseImagesBySection[sectionKey] = updatedImageData;
      cachedFirebaseImages[sectionKey] = updatedImageData;

      // Remove temporary image after preloading
      final tempKey = '$sectionKey|$oldImageUrl';
      temporaryEditedInstallationStepImages.remove(tempKey);

      update(['firebase_images_$sectionKey', 'status_area_$sectionKey']);

      // Don't show success toast - image is already displayed
      // if (!context.mounted) return true;
      // AppFunctions.showToast(message: 'Image updated successfully!', toastType: ToastificationType.success);
      return true;
    } catch (e) {
      debugPrint('Error updating installation step image: $e');
      if (context.mounted) {
        AppFunctions.showToast(message: 'Error updating image: $e', toastType: ToastificationType.error);
      }
      return false;
    }
  }

  int getUploadedCount(String section) {
    return uploadedImages[section]?.length ?? 0;
  }

  Future<StepStatusResult> fetchStepStatuses() async {
    try {
      // Step count is driven by the install_form template
      final installSnapshot = await FirebaseFirestore.instance
          .collection(PrefService.getString(PrefService.dealName))
          .limit(1)
          .get();
      int stepCount = 0;

      if (installSnapshot.docs.isNotEmpty) {
        final installFormData = installSnapshot.docs.first.data();
        final steps = installFormData['steps'] as List<dynamic>?;
        stepCount = steps?.length ?? 0;
      }

      // Default all steps to empty
      var statuses = stepCount > 0 ? List<StepStatus>.filled(stepCount, StepStatus.empty) : <StepStatus>[];

      final userId = PrefService.getString(PrefService.userId);
      if (userId.isEmpty) {
        return StepStatusResult(stepCount: stepCount, statuses: statuses);
      }

      final projectSnapshot = await FirebaseFirestore.instance
          .collection('project')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (projectSnapshot.docs.isEmpty) {
        return StepStatusResult(stepCount: stepCount, statuses: statuses);
      }

      final projectData = projectSnapshot.docs.first.data() as Map<String, dynamic>?;
      if (projectData == null) {
        return StepStatusResult(stepCount: stepCount, statuses: statuses);
      }

      final installationSteps = projectData[PrefService.getString(PrefService.dealName)] as Map<String, dynamic>?;
      if (installationSteps == null) {
        return StepStatusResult(stepCount: stepCount, statuses: statuses);
      }

      // If install_form was missing, fall back to project step count
      if (stepCount == 0) {
        stepCount = installationSteps.length;
        statuses = List<StepStatus>.filled(stepCount, StepStatus.empty);
      }

      for (int i = 0; i < stepCount; i++) {
        final stepData = installationSteps[i.toString()];
        if (stepData is! Map<String, dynamic>) {
          continue;
        }

        final dataItems = _extractDataItems(stepData['data']);
        if (dataItems.isEmpty) {
          statuses[i] = StepStatus.empty;
          continue;
        }

        bool anyImages = false;
        bool allComplete = true;

        for (final dataItem in dataItems) {
          final images =
              (dataItem['images'] as List<dynamic>?)?.where((e) => e != null && e.toString().isNotEmpty).toList() ?? [];
          final count = (dataItem['count'] as num?)?.toInt() ?? 0;

          if (images.isNotEmpty) {
            anyImages = true;
          }

          // A sub-step is complete only when expected count is satisfied
          if (count <= 0 || images.length < count) {
            allComplete = false;
          }
        }

        if (anyImages && allComplete) {
          statuses[i] = StepStatus.complete;
        } else if (anyImages) {
          statuses[i] = StepStatus.partial;
        } else {
          statuses[i] = StepStatus.empty;
        }
      }

      return StepStatusResult(stepCount: stepCount, statuses: statuses);
    } catch (e) {
      debugPrint('Error fetching step statuses: $e');
      return StepStatusResult(stepCount: 0, statuses: const []);
    }
  }

  List<Map<String, dynamic>> _extractDataItems(dynamic dataField) {
    if (dataField is List) {
      return dataField.whereType<Map<String, dynamic>>().toList();
    }
    if (dataField is Map) {
      return dataField.values.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  // Preserve existing images when rebuilding data from the install_form template
  Map<String, dynamic> _mergeTemplateDataWithExistingImages({
    required dynamic templateDataField,
    required dynamic existingDataField,
  }) {
    Map<String, dynamic> processedData = {};

    List<Map<String, dynamic>> _existingImagesForKey(String key) {
      if (existingDataField is Map && existingDataField[key] is Map<String, dynamic>) {
        final images = (existingDataField[key]['images']) as List<dynamic>?;
        return _normalizeImageList(images);
      }
      if (existingDataField is List) {
        final idx = int.tryParse(key);
        if (idx != null && idx >= 0 && idx < existingDataField.length) {
          final entry = existingDataField[idx];
          if (entry is Map<String, dynamic>) {
            final images = entry['images'] as List<dynamic>?;
            return _normalizeImageList(images);
          }
        }
      }
      return <Map<String, dynamic>>[];
    }

    if (templateDataField is List) {
      for (int dataIndex = 0; dataIndex < templateDataField.length; dataIndex++) {
        final dataItem = templateDataField[dataIndex];
        if (dataItem is Map<String, dynamic>) {
          final key = dataIndex.toString();
          processedData[key] = {...dataItem, 'images': _existingImagesForKey(key)};
        }
      }
    } else if (templateDataField is Map) {
      templateDataField.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          final keyStr = key.toString();
          processedData[keyStr] = {...value, 'images': _existingImagesForKey(keyStr)};
        }
      });
    }

    return processedData;
  }

  // Get project document reference for current user
  Future<DocumentReference?> _getProjectDocument() async {
    try {
      final userId = PrefService.getString(PrefService.userId);
      if (userId.isEmpty) {
        debugPrint('User ID not found in preferences');
        return null;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('project')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('Project not found for user: $userId');
        return null;
      }

      return querySnapshot.docs.first.reference;
    } catch (e) {
      debugPrint('Error getting project document: $e');
      return null;
    }
  }

  // Initialize installation_steps structure in project (mirroring install_form)
  Future<void> initializeInstallationStepsInProject() async {
    try {
      final projectRef = await _getProjectDocument();
      if (projectRef == null) return;

      final projectDoc = await projectRef.get();
      final projectData = projectDoc.data() as Map<String, dynamic>?;
      final existingInstallationSteps =
          projectData?[PrefService.getString(PrefService.dealName)] as Map<String, dynamic>?;

      // Get the template from install_form
      final installFormSnapshot = await FirebaseFirestore.instance
          .collection(PrefService.getString(PrefService.dealName))
          .limit(1)
          .get();

      if (installFormSnapshot.docs.isEmpty) {
        debugPrint('install_form template not found');
        return;
      }

      final installFormData = installFormSnapshot.docs.first.data();
      final steps = installFormData['steps'] as List<dynamic>?;

      if (steps == null) {
        debugPrint('Steps not found in install_form');
        return;
      }

      // Create installation_steps structure with empty images arrays
      final installationSteps = <String, dynamic>{};
      for (int stepIndex = 0; stepIndex < steps.length; stepIndex++) {
        final stepData = steps[stepIndex] as Map<String, dynamic>;
        final stepKey = stepIndex.toString();
        final existingStep = existingInstallationSteps != null
            ? existingInstallationSteps[stepKey] as Map<String, dynamic>?
            : null;
        final existingDataField = existingStep?['data'];
        final dataField = stepData['data'];
        final processedData = _mergeTemplateDataWithExistingImages(
          templateDataField: dataField,
          existingDataField: existingDataField,
        );

        installationSteps[stepKey] = {
          'title': stepData['title'],
          'des': stepData['des'],
          'info_video': stepData['info_video'],
          'data': processedData,
        };
      }

      // Update project with installation_steps
      await projectRef.update({PrefService.getString(PrefService.dealName): installationSteps});

      debugPrint('installation_steps synced with install_form template');
    } catch (e) {
      debugPrint('Error initializing/syncing installation_steps in project: $e');
    }
  }

  // Save uploaded images to project.installation_steps
  Future<void> saveImagesToProject({
    required int stepIndex,
    required int dataIndex,
    required List<Map<String, dynamic>> imageItems,
  }) async {
    try {
      final projectRef = await _getProjectDocument();
      if (projectRef == null) {
        debugPrint('Project document not found');
        return;
      }

      // Ensure installation_steps is initialized
      await initializeInstallationStepsInProject();

      // Update the images array for the specific step and data index
      await projectRef.update({
        '${PrefService.getString(PrefService.dealName)}.$stepIndex.data.$dataIndex.images': imageItems,
      });

      debugPrint('Images saved to project: stepIndex=$stepIndex, dataIndex=$dataIndex, count=${imageItems.length}');
    } catch (e) {
      debugPrint('Error saving images to project: $e');
    }
  }

  // Get images from project.installation_steps
  // Returns a normalized List<Map> with keys like "image" and optional "name"
  Future<List<Map<String, dynamic>>> getImagesFromProject({required int stepIndex, required int dataIndex}) async {
    try {
      final projectRef = await _getProjectDocument();
      if (projectRef == null) {
        return [];
      }

      final projectDoc = await projectRef.get();
      final projectData = projectDoc.data() as Map<String, dynamic>?;

      if (projectData == null) {
        return [];
      }

      final installationSteps = projectData[PrefService.getString(PrefService.dealName)] as Map<String, dynamic>?;
      if (installationSteps == null) {
        return [];
      }

      final stepData = installationSteps[stepIndex.toString()] as Map<String, dynamic>?;
      if (stepData == null) {
        return [];
      }

      final dataField = stepData['data'] as Map<String, dynamic>?;
      if (dataField == null) {
        return [];
      }

      final dataItem = dataField[dataIndex.toString()] as Map<String, dynamic>?;
      if (dataItem == null) {
        return [];
      }

      final images = dataItem['images'] as List<dynamic>?;
      if (images == null) {
        return [];
      }

      return _normalizeImageList(images);
    } catch (e) {
      debugPrint('Error getting images from project: $e');
      return [];
    }
  }

  // Load Firebase images for a section (replaces StreamBuilder)
  Future<void> loadFirebaseImagesForSection({
    required String sectionKey,
    required int stepIndex,
    required int dataIndex,
  }) async {
    try {
      isLoadingFirebaseImages[sectionKey] = true;
      update(['firebase_images_$sectionKey']);

      final imageItems = await getImagesFromProject(stepIndex: stepIndex, dataIndex: dataIndex);
      // Store full image data (URL + name) instead of just URLs
      final imageData = imageItems.where((item) => item['image']?.toString().isNotEmpty ?? false).toList();
      firebaseImagesBySection[sectionKey] = imageData;
      cachedFirebaseImages[sectionKey] = imageData;

      isLoadingFirebaseImages[sectionKey] = false;
      update(['firebase_images_$sectionKey', 'status_area_$sectionKey']);
    } catch (e) {
      debugPrint('Error loading Firebase images for section: $e');
      isLoadingFirebaseImages[sectionKey] = false;
      update(['firebase_images_$sectionKey', 'status_area_$sectionKey']);
    }
  }

  // Refresh Firebase images for a section after update
  Future<void> refreshFirebaseImagesForSection({
    required String sectionKey,
    required int stepIndex,
    required int dataIndex,
  }) async {
    final imageItems = await getImagesFromProject(stepIndex: stepIndex, dataIndex: dataIndex);
    // Store full image data (URL + name) instead of just URLs
    final imageData = imageItems.where((item) => item['image']?.toString().isNotEmpty ?? false).toList();
    firebaseImagesBySection[sectionKey] = imageData;
    cachedFirebaseImages[sectionKey] = imageData;
    update(['firebase_images_$sectionKey', 'status_area_$sectionKey']);
  }

  RxBool submitLoader = false.obs;

  // Compress image to 50% quality using flutter_image_compress
  Future<Uint8List> compressImage(Uint8List imageBytes) async {
    try {
      // Use flutter_image_compress to compress image to 50% quality
      // Only compress quality, don't resize (no minHeight/minWidth specified)
      final compressedBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: 40, // 50% quality
        format: CompressFormat.jpeg,
      );
      return compressedBytes;
    } catch (e) {
      debugPrint('Error compressing image with flutter_image_compress: $e');
      // Fallback to image package if flutter_image_compress fails
      try {
        final img.Image? decodedImage = img.decodeImage(imageBytes);
        if (decodedImage != null) {
          final compressedBytes = img.encodeJpg(decodedImage, quality: 50);
          return Uint8List.fromList(compressedBytes);
        }
      } catch (e2) {
        debugPrint('Error with fallback compression: $e2');
      }
      return imageBytes; // Return original if all compression fails
    }
  }

  // Upload images to Firebase Storage and save URLs to project
  Future<void> submitImagesForSection({
    required BuildContext context,
    required int stepIndex,
    required int dataIndex,
    required String sectionKey,
    int maxCount = 5,
  }) async {
    try {
      final uploadedImagesList = uploadedImages[sectionKey] ?? [];
      if (uploadedImagesList.isEmpty) {
        AppFunctions.showToast(message: 'No images to upload', toastType: ToastificationType.error);
        return;
      }
      submitLoader.value = true;
      // Get existing images from project to check total count
      final existingImages = await getImagesFromProject(stepIndex: stepIndex, dataIndex: dataIndex);

      // Check if adding new images would exceed maxCount
      final totalAfterUpload = existingImages.length + uploadedImagesList.length;
      if (totalAfterUpload > maxCount) {
        final allowedCount = maxCount - existingImages.length;
        if (allowedCount <= 0) {
          if (!context.mounted) return;
          AppFunctions.showToast(
            message: 'Maximum image limit ($maxCount) already reached',
            toastType: ToastificationType.error,
          );
          submitLoader.value = false;
          return;
        }
        if (!context.mounted) return;
        AppFunctions.showToast(
          message: 'You can only upload $allowedCount more image(s)',
          toastType: ToastificationType.error,
        );
        submitLoader.value = false;
        return;
      }

      // AppFunctions.showSuccessToast(context, 'Uploading images...');

      final userId = PrefService.getString(PrefService.userId);
      if (userId.isEmpty) {
        if (!context.mounted) return;
        AppFunctions.showToast(message: 'User ID not found', toastType: ToastificationType.error);
        return;
      }

      final storage = FirebaseStorage.instance;
      final List<Map<String, dynamic>> newImageItems = [];

      // Upload each image to Firebase Storage
      for (int i = 0; i < uploadedImagesList.length; i++) {
        final image = uploadedImagesList[i];
        try {
          // Compress image to 50% quality before uploading
          final compressedBytes = await compressImage(image.bytes);

          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName =
              '${PrefService.getString(PrefService.dealName)}/$userId/step_$stepIndex/data_$dataIndex/image_${timestamp}_$i.jpg';
          final ref = storage.ref().child(fileName);

          await ref.putData(compressedBytes, SettableMetadata(contentType: 'image/jpeg'));

          final downloadUrl = await ref.getDownloadURL();
          newImageItems.add({'image': downloadUrl, 'name': image.name});
        } catch (e) {
          debugPrint('Error uploading image $i: $e');
          // Mark image as failed
          uploadedImagesList[i] = UploadedImage(name: image.name, bytes: image.bytes, isUploadFailed: true);
        }
      }

      // Update the uploaded images list
      uploadedImages[sectionKey] = uploadedImagesList;
      update();

      // Save image URLs to project
      if (newImageItems.isNotEmpty) {
        // Combine existing and new images
        final allImages = [...existingImages, ...newImageItems];

        // Ensure we don't exceed maxCount
        final finalImages = allImages.take(maxCount).toList();

        // Save to project
        await saveImagesToProject(stepIndex: stepIndex, dataIndex: dataIndex, imageItems: finalImages);

        // Update local Firebase images list (no StreamBuilder, manual update)
        // Store full image data (URL + name) instead of just URLs
        final finalImageData = finalImages.where((item) => item['image']?.toString().isNotEmpty ?? false).toList();
        firebaseImagesBySection[sectionKey] = finalImageData;
        cachedFirebaseImages[sectionKey] = finalImageData;

        // Clear uploaded images after successful save
        uploadedImages[sectionKey] = [];
        update(['firebase_images_$sectionKey', 'status_area_$sectionKey']);
        submitLoader.value = false;
        if (!context.mounted) return;
        AppFunctions.showToast(message: 'Image Uploaded successfully!', toastType: ToastificationType.success);
      } else {
        if (!context.mounted) return;
        AppFunctions.showToast(message: 'Failed to upload images', toastType: ToastificationType.error);
      }
      submitLoader.value = false;
    } catch (e) {
      submitLoader.value = false;
      debugPrint('Error submitting images: $e');
      AppFunctions.showToast(message: 'Error uploading images: $e', toastType: ToastificationType.error);
    }
  }

  // Media Library specific methods
  List<UploadedImage> get mediaLibraryImages => uploadedImages['mediaLibrary'] ?? [];

  Future<int?> pickMediaLibraryImages({BuildContext? context}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        withData: true,

        allowedExtensions: ['png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.isNotEmpty) {
        final userId = PrefService.getString(PrefService.userId);
        if (userId.isEmpty) {
          if (context != null) {
            if (!context.mounted) return null;
            AppFunctions.showToast(message: 'User ID not found', toastType: ToastificationType.error);
          }
          return null;
        }

        // Get existing bulk_import count from Firebase
        final projectRef = await _getProjectDocument();
        int existingCount = 0;
        if (projectRef != null) {
          final projectDoc = await projectRef.get();
          final projectData = projectDoc.data() as Map<String, dynamic>?;
          final bulkImport = projectData?['bulk_import'];
          if (bulkImport != null) {
            if (bulkImport is List) {
              existingCount = bulkImport.length;
            } else if (bulkImport is Map) {
              existingCount = bulkImport.length;
            }
          }
        }

        final maxImages = 25;
        final remainingSlots = maxImages - existingCount;

        if (remainingSlots <= 0) {
          if (context != null) {
            if (!context.mounted) return null;
            AppFunctions.showToast(
              message: 'Maximum image limit ($maxImages) reached',
              toastType: ToastificationType.error,
            );
          }
          log('Maximum image limit ($maxImages) reached');
          return null;
        }

        // Validate file sizes (2 MB limit)
        const maxFileSize = 3 * 1024 * 1024; // 3 MB in bytes
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
          if (context != null) {
            if (!context.mounted) return null;
            AppFunctions.showToast(
              message: '${oversizedFiles.length} image(s) exceed the 3 MB size limit and were not uploaded',
              toastType: ToastificationType.error,
            );
          }
        }

        final filesToAdd = validFiles
            .take(remainingSlots)
            .where((file) => file.bytes != null)
            .map((file) => UploadedImage(name: file.name, bytes: file.bytes!))
            .toList();

        if (filesToAdd.isEmpty) {
          return null;
        }

        await submitMediaLibraryImages(context: context, images: filesToAdd);

        return existingCount;
      }
      return null;
    } catch (e) {
      log('Error picking media library images: $e');
      if (context != null) {
        if (!context.mounted) return null;
        AppFunctions.showToast(message: 'Error picking images: $e', toastType: ToastificationType.error);
      }
      return null;
    }
  }

  // Handle dropped files from dropzone
  Future<void> handleDroppedMediaLibraryFiles({required BuildContext? context, required List<dynamic> files}) async {
    try {
      if (files.isEmpty) {
        return;
      }

      final userId = PrefService.getString(PrefService.userId);
      if (userId.isEmpty) {
        if (context != null) {
          if (!context.mounted) return;
          AppFunctions.showToast(message: 'User ID not found', toastType: ToastificationType.error);
        }
        return;
      }

      // Get existing bulk_import count from Firebase
      final projectRef = await _getProjectDocument();
      int existingCount = 0;
      if (projectRef != null) {
        final projectDoc = await projectRef.get();
        final projectData = projectDoc.data() as Map<String, dynamic>?;
        final bulkImport = projectData?['bulk_import'];
        if (bulkImport != null) {
          if (bulkImport is List) {
            existingCount = bulkImport.length;
          } else if (bulkImport is Map) {
            existingCount = bulkImport.length;
          }
        }
      }

      final maxImages = 25;
      final remainingSlots = maxImages - existingCount;

      if (remainingSlots <= 0) {
        if (context != null) {
          if (!context.mounted) return;
          AppFunctions.showToast(
            message: 'Maximum image limit ($maxImages) reached',
            toastType: ToastificationType.error,
          );
        }
        log('Maximum image limit ($maxImages) reached');
        return;
      }

      // Process dropped files
      final List<UploadedImage> filesToAdd = [];
      for (var file in files.take(remainingSlots)) {
        try {
          // Get file name and bytes from dropzone file
          // In flutter_dropzone, files are dynamic objects with name and readAsBytes methods
          String fileName;
          try {
            fileName = file.name?.toString() ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
          } catch (e) {
            fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
          }

          final fileBytes = await file.readAsBytes() as Uint8List;

          // Check if it's a valid image format
          final extension = fileName.split('.').last.toLowerCase();
          if (['png', 'jpg', 'jpeg'].contains(extension)) {
            filesToAdd.add(UploadedImage(name: fileName, bytes: fileBytes));
          }
        } catch (e) {
          log('Error processing dropped file: $e');
        }
      }

      if (filesToAdd.isEmpty) {
        if (context != null) {
          if (!context.mounted) return;
          AppFunctions.showToast(message: 'No valid images found', toastType: ToastificationType.error);
        }
        return;
      }

      await submitMediaLibraryImages(context: context, images: filesToAdd);
    } catch (e) {
      log('Error handling dropped files: $e');
      if (context != null) {
        if (!context.mounted) return;
        AppFunctions.showToast(message: 'Error processing dropped files: $e', toastType: ToastificationType.error);
      }
    }
  }

  // Upload media library images to Firebase Storage and save to bulk_import
  Future<void> submitMediaLibraryImages({required BuildContext? context, required List<UploadedImage> images}) async {
    try {
      if (images.isEmpty) {
        if (context != null) {
          AppFunctions.showToast(message: 'No images to upload', toastType: ToastificationType.error);
        }
        return;
      }

      final userId = PrefService.getString(PrefService.userId);
      if (userId.isEmpty) {
        if (context != null) {
          AppFunctions.showToast(message: 'User ID not found', toastType: ToastificationType.error);
        }
        return;
      }

      final projectRef = await _getProjectDocument();
      if (projectRef == null) {
        if (context != null) {
          if (!context.mounted) return;
          AppFunctions.showToast(message: 'Project not found', toastType: ToastificationType.error);
        }
        return;
      }

      // Show uploading toast
      if (context != null) {
        if (!context.mounted) return;
        AppFunctions.showToast(message: 'Uploading ${images.length} image(s)...', toastType: ToastificationType.info);
      }

      final storage = FirebaseStorage.instance;
      final List<Map<String, dynamic>> bulkImportItems = [];

      // Upload each image to Firebase Storage
      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        try {
          // Compress image to 50% quality before uploading
          final compressedBytes = await compressImage(image.bytes);

          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'media_library/$userId/image_${timestamp}_$i.jpg';
          final ref = storage.ref().child(fileName);

          await ref.putData(compressedBytes, SettableMetadata(contentType: 'image/jpeg'));

          final downloadUrl = await ref.getDownloadURL();

          // Format date as "dd MMMM, yyyy" (e.g., "08 December, 2025")
          final formattedDate = DateFormat('dd MMMM, yyyy').format(DateTime.now());

          // Create bulk_import item
          bulkImportItems.add({'imageUrl': downloadUrl, 'image_name': image.name, 'time': formattedDate});
        } catch (e) {
          debugPrint('Error uploading image $i: $e');
          // Continue with other images even if one fails
        }
      }

      // Save to bulk_import array in Firestore
      if (bulkImportItems.isNotEmpty) {
        final projectDoc = await projectRef.get();
        final projectData = projectDoc.data() as Map<String, dynamic>?;

        // Get existing bulk_import list
        List<dynamic> existingBulkImport = [];
        if (projectData != null && projectData.containsKey('bulk_import')) {
          final bulkImport = projectData['bulk_import'];
          if (bulkImport is List) {
            existingBulkImport = List.from(bulkImport);
          } else if (bulkImport is Map) {
            existingBulkImport = bulkImport.values.toList();
          }
        }

        // Add new items to existing list
        final updatedBulkImport = [...existingBulkImport, ...bulkImportItems];

        // Update Firestore
        await projectRef.update({'bulk_import': updatedBulkImport});

        debugPrint('Media library images uploaded successfully: ${bulkImportItems.length} images');

        // Refresh media library list
        refreshMediaLibraryImages();

        if (context != null) {
          if (!context.mounted) return;

          AppFunctions.showToast(message: 'Images uploaded successfully!', toastType: ToastificationType.success);
        }
      } else {
        if (context != null) {
          if (!context.mounted) return;
          AppFunctions.showToast(message: 'Failed to upload images', toastType: ToastificationType.error);
        }
      }
    } catch (e) {
      debugPrint('Error submitting media library images: $e');
      if (context != null) {
        if (!context.mounted) return;
        AppFunctions.showToast(message: 'Error uploading images: $e', toastType: ToastificationType.error);
      }
    }
  }

  void removeMediaLibraryImage(int index) {
    final currentImages = mediaLibraryImages;
    if (index >= 0 && index < currentImages.length) {
      currentImages.removeAt(index);
      uploadedImages['mediaLibrary'] = currentImages;
      update();
    }
  }

  Future<bool> deleteMediaLibraryImage({required BuildContext context, required int index}) async {
    try {
      String userId = PrefService.getString(PrefService.userId);
      final querySnapshot = await FirebaseFirestore.instance
          .collection('project')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      List firebaseImageList = await querySnapshot.docs.first.data()['bulk_import'] ?? [];

      for (int i = 0; i < firebaseImageList.length; i++) {
        if (index == i) {
          await firebaseImageList.removeAt(index);
          break;
        }
      }

      final docId = querySnapshot.docs.first.id;

      await FirebaseFirestore.instance.collection('project').doc(docId).update({'bulk_import': firebaseImageList});

      // Refresh media library list
      refreshMediaLibraryImages();

      debugPrint('bulk_import updated successfully!');

      return true;
    } catch (e) {
      debugPrint('Error deleting media library image: $e');
      if (!context.mounted) return false;
      AppFunctions.showToast(message: 'Error deleting image: $e', toastType: ToastificationType.error);
      return false;
    }
  }

  // Delete media library image from Firebase Storage and database
  // Future<bool> deleteMediaLibraryImage({
  //   required BuildContext context,
  //   required String imageUrl,
  //   required int index,
  // }) async
  // {
  //   try {
  //     // If imageUrl is empty, it's a local image - just remove from local list
  //     if (imageUrl.isEmpty) {
  //       removeMediaLibraryImage(index);
  //       return true;
  //     }
  //
  //     final userId = PrefService.getString(PrefService.userId);
  //     if (userId.isEmpty) {
  //       AppFunctions.showErrorToast(context, 'User ID not found');
  //       return false;
  //     }
  //
  //     final projectRef = await _getProjectDocument();
  //     if (projectRef == null) {
  //       AppFunctions.showErrorToast(context, 'Project not found');
  //       return false;
  //     }
  //
  //     // Delete from Firebase Storage
  //     try {
  //       final storage = FirebaseStorage.instance;
  //       final ref = storage.refFromURL(imageUrl);
  //       await ref.delete();
  //       debugPrint('Image deleted from Firebase Storage: $imageUrl');
  //     } catch (e) {
  //       debugPrint('Error deleting image from Storage (continuing with DB delete): $e');
  //       // Continue with database deletion even if storage deletion fails
  //     }
  //
  //     // Get existing bulk_import list
  //     final projectDoc = await projectRef.get();
  //     final projectData = projectDoc.data() as Map<String, dynamic>?;
  //
  //     if (projectData == null || !projectData.containsKey('bulk_import')) {
  //       AppFunctions.showErrorToast(context, 'Bulk import data not found');
  //       return false;
  //     }
  //
  //     final bulkImport = projectData['bulk_import'];
  //
  //     // Handle both List and Map cases
  //     if (bulkImport is List) {
  //       // If it's a List, remove by index
  //       if (index >= 0 && index < bulkImport.length) {
  //         final updatedBulkImport = List.from(bulkImport);
  //         updatedBulkImport.removeAt(index);
  //
  //         // Update Firestore
  //         await projectRef.update({'bulk_import': updatedBulkImport});
  //
  //         debugPrint('Media library image deleted successfully at index $index');
  //         return true;
  //       } else {
  //         AppFunctions.showErrorToast(context, 'Image index not found');
  //         return false;
  //       }
  //     } else if (bulkImport is Map) {
  //       // If it's a Map, convert to List, remove, and convert back
  //       final bulkImportList = bulkImport.values.toList();
  //       if (index >= 0 && index < bulkImportList.length) {
  //         bulkImportList.removeAt(index);
  //
  //         // Convert back to List for Firestore
  //         await projectRef.update({'bulk_import': bulkImportList});
  //
  //         debugPrint('Media library image deleted successfully at index $index');
  //         return true;
  //       } else {
  //         AppFunctions.showErrorToast(context, 'Image index not found');
  //         return false;
  //       }
  //     } else {
  //       AppFunctions.showErrorToast(context, 'Invalid bulk import data format');
  //       return false;
  //     }
  //   } catch (e) {
  //     debugPrint('Error deleting media library image: $e');
  //     AppFunctions.showErrorToast(context, 'Error deleting image: $e');
  //     return false;
  //   }
  // }

  // Download image from URL and convert to bytes
  Future<Uint8List?> downloadImageFromUrl(String imageUrl) async {
    try {
      final dio = Dio();
      final response = await dio.get<List<int>>(imageUrl, options: Options(responseType: ResponseType.bytes));
      if (response.data != null) {
        return Uint8List.fromList(response.data!);
      }
      return null;
    } catch (e) {
      debugPrint('Error downloading image: $e');
      return null;
    }
  }

  Future<Uint8List?> downloadImageDioWeb(String imageUrl) async {
    try {
      Dio dio = Dio();

      final response = await dio.get(imageUrl, options: Options(responseType: ResponseType.bytes));

      Uint8List bytes = Uint8List.fromList(response.data);

      print("📥 Image downloaded & bytes ready!");
      return bytes;
    } catch (e) {
      print("❌ Error downloading image: $e");
      return null;
    }
  }

  Future<Uint8List?> fetchImageViaProxy(String proxyUrl) async {
    try {
      final response = await Dio().get(proxyUrl, options: Options(responseType: ResponseType.bytes));
      return Uint8List.fromList(response.data);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> editMediaLibraryImage({
    required BuildContext context,
    required String imageUrl,
    required String imageName,
    required int index,
  }) async {
    try {
      final existingTemp = temporaryEditedMediaLibraryImages[index];

      // If we already have an edited version in memory, open the editor from bytes
      if (existingTemp != null) {
        EditImageDialog.show(
          context,
          image: UploadedImage(name: imageName, bytes: existingTemp),
          onSave: (editedBytes) async {
            Navigator.of(context).pop(); // Close edit dialog

            // Store edited image locally immediately for instant display
            temporaryEditedMediaLibraryImages[index] = editedBytes;
            update(); // Update UI to show edited image immediately

            // Upload to Firebase in background (non-blocking)
            updateMediaLibraryImageInFirebase(
              context: context,
              oldImageUrl: imageUrl,
              editedBytes: editedBytes,
              imageName: imageName,
              index: index,
            ).catchError((e) {
              temporaryEditedMediaLibraryImages.remove(index);
              update();
              debugPrint('Error uploading edited image: $e');
            });
          },
        );
        return;
      }

      // Otherwise open the editor from network URL
      EditImageNetworkDialog.show(
        context,
        image: imageUrl,
        onSave: (editedBytes) async {
          Navigator.of(context).pop(); // Close edit dialog

          // Store edited image locally immediately for instant display
          temporaryEditedMediaLibraryImages[index] = editedBytes;
          update(); // Update UI to show edited image immediately

          // Upload to Firebase in background (non-blocking)
          updateMediaLibraryImageInFirebase(
            context: context,
            oldImageUrl: imageUrl,
            editedBytes: editedBytes,
            imageName: imageName,
            index: index,
          ).catchError((e) {
            temporaryEditedMediaLibraryImages.remove(index);
            update();
            debugPrint('Error uploading edited image: $e');
          });
        },
      );
    } catch (e) {
      debugPrint('Error editing media library image: $e');

      AppFunctions.showToast(message: 'Error editing image: $e', toastType: ToastificationType.error);
    }
  }

  // Update media library image in Firebase after editing (runs in background)
  Future<void> updateMediaLibraryImageInFirebase({
    required BuildContext context,
    required String oldImageUrl,
    required Uint8List editedBytes,
    required String imageName,
    required int index,
  }) async {
    try {
      // Don't show toast immediately - image is already displayed locally
      // AppFunctions.showToast(message: 'Uploading edited image...', toastType: ToastificationType.info);

      final userId = PrefService.getString(PrefService.userId);
      if (userId.isEmpty) {
        AppFunctions.showToast(message: 'User ID not found', toastType: ToastificationType.error);
        return;
      }

      final projectRef = await _getProjectDocument();
      if (projectRef == null) {
        if (!context.mounted) return;
        AppFunctions.showToast(message: 'Project not found', toastType: ToastificationType.error);
        return;
      }

      // Upload edited image to Firebase Storage
      final storage = FirebaseStorage.instance;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'media_library/$userId/image_${timestamp}_edited.jpg';
      final ref = storage.ref().child(fileName);

      await ref.putData(editedBytes, SettableMetadata(contentType: 'image/jpeg'));
      final newDownloadUrl = await ref.getDownloadURL();

      // Get existing bulk_import list
      final projectDoc = await projectRef.get();
      final projectData = projectDoc.data() as Map<String, dynamic>?;

      if (projectData == null || !projectData.containsKey('bulk_import')) {
        if (!context.mounted) return;
        AppFunctions.showToast(message: 'Bulk import data not found', toastType: ToastificationType.error);
        return;
      }

      final bulkImport = projectData['bulk_import'];

      // Handle both List and Map cases
      if (bulkImport is List) {
        // If it's a List, update directly by index
        if (index >= 0 && index < bulkImport.length) {
          // Format date as "dd MMMM, yyyy"
          final formattedDate = DateFormat('dd MMMM, yyyy').format(DateTime.now());

          // Update the item at the specified index
          final updatedBulkImport = List.from(bulkImport);
          updatedBulkImport[index] = {'imageUrl': newDownloadUrl, 'image_name': imageName, 'time': formattedDate};

          // Update Firestore
          await projectRef.update({'bulk_import': updatedBulkImport});

          // Preload the new image before removing temporary image to prevent shimmer
          if (context.mounted) {
            try {
              await CachedNetworkImage.evictFromCache(newDownloadUrl);
              await precacheImage(CachedNetworkImageProvider(newDownloadUrl), context);
            } catch (e) {
              debugPrint('Error precaching image: $e');
            }
          }

          // Remove temporary image after preloading
          temporaryEditedMediaLibraryImages.remove(index);
          // Refresh media library list to show updated image
          refreshMediaLibraryImages();
          debugPrint('Media library image updated successfully at index $index');
          if (!context.mounted) return;

          // AppFunctions.showToast(message: 'Image updated successfully!!', toastType: ToastificationType.success);
        } else {
          if (!context.mounted) return;
          AppFunctions.showToast(message: 'Image index not found', toastType: ToastificationType.error);
        }
      } else if (bulkImport is Map) {
        final bulkImportList = bulkImport.values.toList();

        if (index >= 0 && index < bulkImportList.length) {
          final formattedDate = DateFormat('dd MMMM, yyyy').format(DateTime.now());

          bulkImportList[index] = {'imageUrl': newDownloadUrl, 'image_name': imageName, 'time': formattedDate};

          await projectRef.update({'bulk_import': bulkImportList});

          // Preload the new image before removing temporary image to prevent shimmer
          if (context.mounted) {
            try {
              await CachedNetworkImage.evictFromCache(newDownloadUrl);
              await precacheImage(CachedNetworkImageProvider(newDownloadUrl), context);
            } catch (e) {
              debugPrint('Error precaching image: $e');
            }
          }

          // Remove temporary image after preloading
          temporaryEditedMediaLibraryImages.remove(index);
          // Refresh media library list to show updated image
          refreshMediaLibraryImages();
          debugPrint('Media library image updated successfully at index $index');
          if (!context.mounted) return;
          AppFunctions.showToast(message: 'Image updated successfully!', toastType: ToastificationType.success);
        } else {
          if (!context.mounted) return;
          AppFunctions.showToast(message: 'Image index not found', toastType: ToastificationType.error);
        }
      } else {
        if (!context.mounted) return;
        AppFunctions.showToast(message: 'Invalid bulk import data format', toastType: ToastificationType.error);
      }
    } catch (e) {
      debugPrint('Error updating media library image in Firebase: $e');
      AppFunctions.showToast(message: 'Error updating image: $e', toastType: ToastificationType.error);
    }
  }

  void setSelectedLocation(LatLng location) {
    selectedLocation = location;
    // update();
  }

  Future<void> updateAddressFromLocation(LatLng location) async {
    try {
      addressSearchController.clear();
      selectedLocation = LatLng(location.latitude, location.longitude);
      await getAddressFromLatLong(location);
      update();
    } catch (e) {
      debugPrint('Error getting address from location: $e');
    }
  }

  Future<void> searchAddress(String query) async {
    if (query.isEmpty) {
      addressSuggestions.clear();
      isLoadingSuggestions.value = false;
      return;
    }

    isLoadingSuggestions.value = true;

    try {
      // Debounce: wait 500ms before making the API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if query is still not empty after debounce
      if (query.isEmpty || addressSearchController.text != query) {
        isLoadingSuggestions.value = false;
        return;
      }

      final response = await _dio.post(
        'https://places.googleapis.com/v1/places:searchText',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': _googlePlacesApiKey,
            'X-Goog-FieldMask': 'places.displayName,places.formattedAddress,places.priceLevel,places.location',
          },
        ),
        data: {
          'textQuery': query,
          'locationRestriction': {
            'rectangle': {
              'low': {'latitude': germanyBounds.southwest.latitude, 'longitude': germanyBounds.southwest.longitude},
              'high': {'latitude': germanyBounds.northeast.latitude, 'longitude': germanyBounds.northeast.longitude},
            },
          },
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final placesResponse = PlacesSearchResponse.fromJson(response.data);
        // Filter to ensure all places are in Germany (double check)
        final filteredPlaces = placesResponse.places.where((place) {
          // Additional check: verify address contains Germany/Deutschland
          return place.formattedAddress.toLowerCase().contains('germany') ||
              place.formattedAddress.toLowerCase().contains('deutschland') ||
              place.formattedAddress.toLowerCase().contains(', de');
        }).toList();
        addressSuggestions.value = filteredPlaces;
      } else {
        addressSuggestions.clear();
      }
    } catch (e) {
      debugPrint('Error searching address: $e');
      addressSuggestions.clear();
    } finally {
      isLoadingSuggestions.value = false;
    }
  }

  Future<void> getAddressFromLatLong(LatLng latLong) async {
    addressSuggestions.clear();
    update();
    isGeocoding.value = true;

    try {
      // Check if location is in Germany first
      if (!isLocationInGermany(latLong)) {
        isGeocoding.value = false;
        AppFunctions.showToast(
          message: 'Please select a location within Germany only.',
          toastType: ToastificationType.error,
        );
        return;
      }

      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'latlng': "${latLong.latitude},${latLong.longitude}",
          'key': _googlePlacesApiKey,
          'region': 'de', // Restrict to Germany
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final results = response.data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          final firstResult = results[0] as Map<String, dynamic>;
          // Double check if address is in Germany
          if (_isAddressInGermany(firstResult)) {
            selectedAddress.value = firstResult['formatted_address'] ?? '';
            update();
          } else {
            AppFunctions.showToast(
              message: 'Please select a location within Germany only.',
              toastType: ToastificationType.error,
            );
          }
        }
      } else {
        print(response.data);
      }
    } catch (e) {
      debugPrint('Error geocoding address: $e');
      AppFunctions.showToast(message: 'Failed to get location. Please try again.', toastType: ToastificationType.error);
    } finally {
      isGeocoding.value = false;
    }
  }

  Future<void> geocodeAddress(String formattedAddress) async {
    addressSuggestions.clear();
    update();
    isGeocoding.value = true;

    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'address': formattedAddress,
          'key': _googlePlacesApiKey,
          'region': 'de', // Restrict to Germany
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final results = response.data['results'] as List<dynamic>?;

        if (results != null && results.isNotEmpty) {
          final firstResult = results[0] as Map<String, dynamic>;

          // Check if address is in Germany
          if (!_isAddressInGermany(firstResult)) {
            isGeocoding.value = false;
            AppFunctions.showToast(
              message: 'Please select a location within Germany only.',
              toastType: ToastificationType.error,
            );
            return;
          }

          final geocodeResponse = GeocodeResponse.fromJson(response.data);

          if (geocodeResponse.results.isNotEmpty) {
            final result = geocodeResponse.results.first;
            LatLng location = LatLng(result.location.lat, result.location.lng);

            // Double check location bounds
            if (!isLocationInGermany(location)) {
              isGeocoding.value = false;
              AppFunctions.showToast(
                message: 'Please select a location within Germany only.',
                toastType: ToastificationType.error,
              );
              return;
            }

            // Update selected location
            selectedLocation = location;
            selectedAddress.value = result.formattedAddress;

            // Clear suggestions
            addressSuggestions.clear();
            addressSearchController.text = result.formattedAddress;

            // Notify listeners (if using GetX update)
            update();
          }
        }
      }
    } catch (e) {
      debugPrint('Error geocoding address: $e');
      AppFunctions.showToast(message: 'Failed to get location. Please try again.', toastType: ToastificationType.error);
    } finally {
      isGeocoding.value = false;
    }
  }

  void updateMediaLibraryImage(int index, Uint8List newBytes) {
    final currentImages = mediaLibraryImages;
    if (index >= 0 && index < currentImages.length) {
      currentImages[index] = UploadedImage(
        name: currentImages[index].name,
        bytes: newBytes,
        isUploadFailed: currentImages[index].isUploadFailed,
      );
      uploadedImages['mediaLibrary'] = currentImages;
      update();
    }
  }

  void updateImage(String section, int index, Uint8List newBytes) {
    final currentImages = uploadedImages[section] ?? [];
    if (index >= 0 && index < currentImages.length) {
      currentImages[index] = UploadedImage(
        name: currentImages[index].name,
        bytes: newBytes,
        isUploadFailed: currentImages[index].isUploadFailed,
      );
      uploadedImages[section] = currentImages;
      update();
    }
  }

  void toggleChecklistDrawer() {
    isChecklistDrawerOpen = !isChecklistDrawerOpen;
    if (isChecklistDrawerOpen) {
      // Pre-load data before showing drawer to prevent glitch
      // loadChecklistData();
    }
    // Only update drawer-related widgets, not the entire screen
    update(['drawer']);
  }

  // Load checklist data from Firestore
  Future<void> loadChecklistData() async {
    try {
      isLoadingChecklistData.value = true;

      // Load install_form data
      final installFormSnapshot = await FirebaseFirestore.instance
          .collection(PrefService.getString(PrefService.dealName))
          .limit(1)
          .get();

      if (installFormSnapshot.docs.isNotEmpty) {
        installFormData = installFormSnapshot.docs.first.data();
      } else {
        installFormData = null;
      }

      // Load project data if user is logged in
      final userId = PrefService.getString(PrefService.userId);
      if (userId.isNotEmpty) {
        final projectSnapshot = await FirebaseFirestore.instance
            .collection('project')
            .where('user_id', isEqualTo: userId)
            .limit(1)
            .get();

        if (projectSnapshot.docs.isNotEmpty) {
          projectData = projectSnapshot.docs.first.data();
        } else {
          projectData = null;
        }
      } else {
        projectData = null;
      }

      update(['checkList']);
    } catch (e) {
      debugPrint('Error loading checklist data: $e');
      installFormData = null;
      projectData = null;
    } finally {
      isLoadingChecklistData.value = false;
      update(['checkList']);
    }
  }

  String firebasePdfStoragePath = '';
  String firebasePdfName = '';

  Future<void> generateAndUploadPdf({required BuildContext context}) async {
    try {
      isGeneratingPdf.value = true;
      pdfGenerationProgress.value = 0.0;
      update();

      if (!context.mounted) return;

      AppFunctions.showToast(message: 'Generating PDF...', toastType: ToastificationType.info);
      pdfGenerationProgress.value = 0.01;
      final userId = PrefService.getString(PrefService.userId);
      if (userId.isEmpty) {
        if (!context.mounted) return;
        AppFunctions.showToast(message: 'User ID not found', toastType: ToastificationType.error);
        isGeneratingPdf.value = false;
        pdfGenerationProgress.value = 0.0;
        update();
        return;
      }

      pdfGenerationProgress.value = 0.03;
      final projectRef = await _getProjectDocument();
      if (projectRef == null) {
        if (!context.mounted) return;
        AppFunctions.showToast(message: 'Project not found', toastType: ToastificationType.error);
        isGeneratingPdf.value = false;
        pdfGenerationProgress.value = 0.0;
        update();
        return;
      }

      pdfGenerationProgress.value = 0.05;
      final projectDoc = await projectRef.get();
      final projectData = projectDoc.data() as Map<String, dynamic>?;

      if (projectData == null || !projectData.containsKey(PrefService.getString(PrefService.dealName))) {
        if (!context.mounted) return;
        AppFunctions.showToast(message: 'Installation steps not found', toastType: ToastificationType.error);
        isGeneratingPdf.value = false;
        pdfGenerationProgress.value = 0.0;
        update();
        return;
      }
      final rawSteps = projectData[PrefService.getString(PrefService.dealName)];
      List<InstallationStep> steps = parseInstallationSteps(rawSteps);
      log(steps.toString());
      pdfGenerationProgress.value = 0.1;
      // final pdfBytes = await PdfGenerationService.generatePdf(installationSteps: steps);
      pdfBytes = await PdfGenerationService.generateHeatPumpPdf(installationSteps: steps, type: 3);

      pdfGenerationProgress.value = 0.7;
      final storage = FirebaseStorage.instance;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      firebasePdfStoragePath = 'media_library/$userId/pdf_$timestamp.pdf';
      firebasePdfName = 'pdf_$timestamp.pdf';
      final ref = storage.ref().child(firebasePdfStoragePath);

      final uploadTask = ref.putData(pdfBytes!, SettableMetadata(contentType: 'application/pdf'));
      uploadTask.snapshotEvents.listen((taskSnapshot) {
        final progress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
        // pdfGenerationProgress.value = 0.7 + (progress * 0.2); // Progress from 0.7 to 0.9
      });

      await uploadTask;
      pdfGenerationProgress.value = 0.9;

      final downloadUrl = await ref.getDownloadURL();
      pdfNetworkUrl = downloadUrl;
      await projectRef.update({'pdf_url': downloadUrl});
      debugPrint('PDF URL updated in project document: $downloadUrl');
      pdfGenerationProgress.value = 1.0;
      showMediaLibraryScreen = false;
      showInstallationFormScreen = true;
      ispdf = true;
      isGeneratingPdf.value = false;
      update();
      if (!context.mounted) return;

      AppFunctions.showToast(
        message: 'PDF generated and uploaded successfully!',
        toastType: ToastificationType.success,
      );
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      isGeneratingPdf.value = false;
      pdfGenerationProgress.value = 0.0;
      update();
      if (!context.mounted) return;
      AppFunctions.showToast(message: 'Failed to generate PDF', toastType: ToastificationType.error);
    }
  }

  List<InstallationStep> parseInstallationSteps(dynamic rawSteps) {
    List<InstallationStep> steps = [];

    if (rawSteps == null) return steps;

    if (rawSteps is Map) {
      rawSteps.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          steps.add(InstallationStep.fromMap(value));
        }
      });
    } else if (rawSteps is List) {
      for (var item in rawSteps) {
        if (item is Map<String, dynamic>) {
          steps.add(InstallationStep.fromMap(item));
        }
      }
    }

    return steps;
  }

  Future<void> getInstructionVideo() async {
    final installFormSnapshot = await FirebaseFirestore.instance
        .collection(PrefService.getString(PrefService.dealName))
        .limit(1)
        .get();

    if (installFormSnapshot.docs.isEmpty) {
      debugPrint('install_form template not found');
      return;
    } else {
      String video = installFormSnapshot.docs[0].data()['instruction_video'];
      instructionVideo = video;
      String tutorial = installFormSnapshot.docs[0].data()['tutorial']['video'];
      String tutorialDes = installFormSnapshot.docs[0].data()['tutorial']['des'];
      tutorialVideo = tutorial;
      tutorialText = tutorialDes;
    }
    _initializeVideo(tutorialVideo ?? "");
  }

  // Fetch user role from Firestore users collection
  Future<void> fetchUserRole() async {
    try {
      final userId = PrefService.getString(PrefService.userId);
      if (userId.isEmpty) {
        debugPrint('User ID not found in preferences');
        return;
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;
        if (userData != null && userData.containsKey('role')) {
          userRole.value = userData['role'] as String? ?? '';
          debugPrint('User role fetched: ${userRole.value}');
        }
      }
    } catch (e) {
      debugPrint('Error fetching user role: $e');
    }
  }

  // Load PDF URL from project document
  Future<void> loadPdfUrlFromProject() async {
    try {
      final projectRef = await _getProjectDocument();
      if (projectRef == null) {
        debugPrint('Project document not found');
        return;
      }

      final projectDoc = await projectRef.get();
      final projectData = projectDoc.data() as Map<String, dynamic>?;
      if (projectData != null && projectData.containsKey('pdf_url')) {
        final pdfUrl = projectData['pdf_url'] as String?;
        if (pdfUrl != null && pdfUrl.isNotEmpty) {
          pdfNetworkUrl = pdfUrl;
          debugPrint('PDF URL loaded from project: $pdfNetworkUrl');
        }
      }
    } catch (e) {
      debugPrint('Error loading PDF URL from project: $e');
    }
  }

  // Show PDF for customers (loads existing PDF from project)
  Future<void> showPdfForCustomer({required BuildContext context}) async {
    try {
      await loadPdfUrlFromProject();
      if (pdfNetworkUrl != null && pdfNetworkUrl!.isNotEmpty) {
        showMediaLibraryScreen = false;
        showInstallationFormScreen = true;
        ispdf = true;
        update();
      } else {
        if (!context.mounted) return;
        AppFunctions.showToast(message: 'PDF not found. Please contact support.', toastType: ToastificationType.error);
      }
    } catch (e) {
      debugPrint('Error showing PDF for customer: $e');
      if (!context.mounted) return;
      AppFunctions.showToast(message: 'Failed to load PDF', toastType: ToastificationType.error);
    }
  }

  MainRepository mainRepository = MainRepository();

  Future<void> uploadToHubSpot({required BuildContext context}) async {
    try {
      // Start smooth progress animation
      isUploadingToHubSpot.value = true;
      hubSpotUploadProgress.value = 0.0;
      _hubSpotProgressTimer?.cancel();
      _hubSpotProgressTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
        // Increase progress smoothly but don't complete fully until all steps are done
        if (hubSpotUploadProgress.value < 0.9) {
          hubSpotUploadProgress.value = (hubSpotUploadProgress.value + 0.01).clamp(0.0, 0.9);
          update();
        }
      });
      update();

      // Step 1/3: upload file
      // final uploadOk = await uploadFileAPI(context: context);
      // if (!uploadOk) {
      //   // Error toast already shown inside uploadFileAPI
      //   return;
      // }
      //
      // // Step 2/3: create note
      // final noteOk = await createNote(context: context);
      // if (!noteOk) {
      //   // Error toast already shown inside createNote
      //   return;
      // }
      //
      // // Step 3/3: link file to property
      // final linkOk = await linkFileToProperty(context: context);
      // if (!linkOk) {
      //   // Error toast already shown inside linkFileToProperty
      //   return;
      // }

      await uploadDocAPI(context: context);

      // Mark as fully complete and show success
      hubSpotUploadProgress.value = 1.0;
      update();
    } catch (e) {
      debugPrint('Error uploading to HubSpot: $e');
    } finally {
      // Briefly show completion before resetting state
      await Future.delayed(const Duration(milliseconds: 400));
      _hubSpotProgressTimer?.cancel();
      isUploadingToHubSpot.value = false;
      hubSpotUploadProgress.value = 0.0;
      update();
    }
  }

  Future<File> compressPdfFFmpeg(File input) async {
    final outputPath = '${input.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.pdf';

    final command = '-i "${input.path}" -vcodec copy -acodec copy -pdf_compression_level 7 "$outputPath"';

    await FFmpegKit.execute(command);

    return File(outputPath);
  }

  Future<Uint8List> compressPdfBytes(Uint8List pdfBytes) async {
    final tempDir = await getTemporaryDirectory();

    final inputPath = '${tempDir.path}/input_${DateTime.now().millisecondsSinceEpoch}.pdf';

    final outputPath = '${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.pdf';

    // 1️⃣ Write bytes to file
    final inputFile = File(inputPath);
    await inputFile.writeAsBytes(pdfBytes);

    // 2️⃣ Compress using FFmpeg
    final command = '-i "$inputPath" -pdf_compression_level 6 "$outputPath"';

    await FFmpegKit.execute(command);

    // 3️⃣ Read compressed file back to bytes
    final compressedBytes = await File(outputPath).readAsBytes();

    // Optional cleanup
    inputFile.delete();
    File(outputPath).delete();

    return compressedBytes;
  }

  Future<void> getDealById({required String dealId, required BuildContext context}) async {
    await mainRepository.getDealById(
      dealId: dealId,
      onSuccess: (dynamic response) {
        try {
          debugPrint('success:::${response.toString()} ');

          context.go(AppRoutes.installationSteps);
          AppFunctions.showToast(message: 'Login successful!!', toastType: ToastificationType.success);
        } catch (e) {
          debugPrint('error:::${response.toString()} ');
        }
      },
      onError: (dynamic error) {
        debugPrint('error:::$error');
        String message = error.message;
      },
    );
  }

  void downloadPdfWeb(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  Future<Uint8List> compressPdfWeb(Uint8List inputBytes) async {
    final document = PdfDocument(inputBytes: inputBytes);

    document.compressionLevel = PdfCompressionLevel.belowNormal;

    final compressedBytes = document.saveSync();
    document.dispose();
    // downloadPdfWeb(Uint8List.fromList(compressedBytes), "compressed.pdf");
    return Uint8List.fromList(compressedBytes);
  }

  Future<bool> uploadFileAPI({required BuildContext context}) async {
    bool isSuccess = false;
    String folderId = '340063591612';

    Uint8List compressedPDF = await compressPdfWeb(pdfBytes!);

    // final decoded = img.decodeImage(pdfBytes!)!;
    // final compressedBytes = Uint8List.fromList(img.encodeJpg(decoded, quality: 60));

    await mainRepository.uploadPdfBytes(
      pdfBytes: compressedPDF,
      body: {
        "folderId": folderId,
        "options": {
          "access": "PRIVATE",
          "overwrite": false,
          "duplicateValidationStrategy": "NONE",
          "duplicateValidationScope": "EXACT_FOLDER",
        },
      },

      onSuccess: (dynamic response) {
        try {
          debugPrint('success:::${response.toString()}');
          isSuccess = true;
        } catch (e) {
          debugPrint('error:::${response.toString()} ');
        }
      },
      onError: (dynamic error) {
        debugPrint('error:::${error.message}');
        String message = error.message;
        if (context.mounted) {
          AppFunctions.showToast(
            message: message.isNotEmpty ? message : 'Failed to upload file to HubSpot.',
            toastType: ToastificationType.error,
          );
        }
      },
    );
    return isSuccess;
  }

  Future<bool> linkFileToProperty({required BuildContext context}) async {
    bool isSuccess = false;
    String folderId = '340063591612';

    await mainRepository.linkFileToProperty(
      dealId: PrefService.getString(PrefService.dealId),
      body: {
        "properties": {"fotoleitfaden_bilddokumentation": folderId},
      },

      onSuccess: (dynamic response) {
        try {
          debugPrint('success:::${response.toString()} ');
          isSuccess = true;
        } catch (e) {
          debugPrint('error:::${response.toString()} ');
        }
      },
      onError: (dynamic error) {
        debugPrint('error:::$error');
        String message = error.message;
        if (context.mounted) {
          AppFunctions.showToast(
            message: message.isNotEmpty ? message : 'Failed to link file to HubSpot deal.',
            toastType: ToastificationType.error,
          );
        }
      },
    );
    return isSuccess;
  }

  Future<bool> createNote({required BuildContext context}) async {
    bool isSuccess = false;
    await mainRepository.createNote(
      body: {
        "properties": {
          "hs_note_body": "Fotoleitfaden erfolgreich erstellt und hochgeladen.",
          "hs_timestamp": "1736337600000",
          "hs_attachment_ids": "340048789707",
        },
        "associations": [
          {
            "to": {"id": "274770218196"},
            "types": [
              {"associationCategory": "HUBSPOT_DEFINED", "associationTypeId": 214},
            ],
          },
        ],
      },

      onSuccess: (dynamic response) {
        try {
          debugPrint('success:::${response.toString()} ');
          isSuccess = true;
        } catch (e) {
          debugPrint('error:::${response.toString()} ');
        }
      },
      onError: (dynamic error) {
        debugPrint('error:::$error');
        String message = error.message;
        if (context.mounted) {
          AppFunctions.showToast(
            message: message.isNotEmpty ? message : 'Failed to create HubSpot note.',
            toastType: ToastificationType.error,
          );
        }
      },
    );
    return isSuccess;
  }

  Future<void> uploadDocAPI({required BuildContext context}) async {
    await mainRepository.uploadDoc(
      body: {"storagePath": firebasePdfStoragePath, "productType": PrefService.getString(PrefService.dealName), "fileName": firebasePdfName},
      dealId: PrefService.getString(PrefService.dealId),

      onSuccess: (dynamic response) {
        try {
          debugPrint('success:::${response.toString()} ');
        } catch (e) {
          debugPrint('error:::${response.toString()} ');
        }
      },
      onError: (dynamic error) {
        debugPrint('error:::$error');
        String message = error.message;
      },
    );
  }
}
