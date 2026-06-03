import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_steps_controller.dart';
import 'package:heimwatt/app/modules/installation_steps/address_selection_screen/models/place_suggestion_model.dart';
import 'package:heimwatt/app/utils/app_functions.dart';
import 'package:heimwatt/app/utils/exports.dart';
import 'package:heimwatt/app/utils/pref_service.dart';
import 'package:screenshot/screenshot.dart';
import 'package:toastification/toastification.dart';
import 'package:shimmer/shimmer.dart';

class AddressSelectionTablet extends StatefulWidget {
  const AddressSelectionTablet({super.key});

  @override
  State<AddressSelectionTablet> createState() => _AddressSelectionTabletState();
}

class _AddressSelectionTabletState extends State<AddressSelectionTablet> {
  InstallationStepsController controller = Get.put(InstallationStepsController());

  GoogleMapController? mapController;
  Set<Marker> _markers = {};
  LatLng _selectedLocation = const LatLng(53.2278, 10.1694); // Default location (Salzhausen, Germany)
  BitmapDescriptor? _customMarkerIcon;
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isMapLoading = true;

  final LatLngBounds germanyBounds = LatLngBounds(
    southwest: LatLng(47.2701, 5.8663),
    northeast: LatLng(55.0992, 15.0419),
  );

  @override
  void initState() {
    super.initState();
    loadAddressFromFirebase();
    _loadCustomMarkerIcon();
    _initializeMap();
  }

  Future<void> loadAddressFromFirebase() async {
    final userId = PrefService.getString(PrefService.userId);
    final projectRef = await FirebaseFirestore.instance
        .collection('project')
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();

    Map<String, dynamic> data = projectRef.docs[0].data();

    double lat = double.parse(data['address']['lat'] ?? '0.0');
    double long = double.parse(data['address']['lon'] ?? '0.0');

    controller.selectedLocation = LatLng(lat, long);
    controller.selectedAddress.value = data['address']['address'] ?? "";
    controller.update();
    _selectedLocation = LatLng(lat, long);
  }

  Future<void> _loadCustomMarkerIcon() async {
    final ImageConfiguration imageConfiguration = ImageConfiguration(size: const Size(30, 30));
    final BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
      imageConfiguration,
      Assets.icons.icGoogleMarker.path,
    );
    setState(() {
      _customMarkerIcon = customIcon;
    });
    // Update marker after icon is loaded
    if (mounted) {
      _updateMarker(_selectedLocation);
    }
  }

  void _initializeMap() {
    final controller = Get.find<InstallationStepsController>();
    if (controller.selectedLocation != null) {
      _selectedLocation = controller.selectedLocation!;
      _updateMarker(_selectedLocation);
    } else {
      _updateMarker(_selectedLocation);
    }
  }

  void _updateMarker(LatLng location) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: location,
          draggable: true,
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          onDragEnd: (LatLng newPosition) {
            _onLocationChanged(newPosition);
          },
        ),
      };
      _selectedLocation = location;
    });

    final controller = Get.find<InstallationStepsController>();
    controller.setSelectedLocation(location);
  }

  void _onLocationChanged(LatLng location) {
    // Check if location is within Germany bounds
    if (!germanyBounds.contains(location)) {
      AppFunctions.showToast(
        message: 'Please select a location within Germany only.',
        toastType: ToastificationType.error,
      );
      return;
    }

    _updateMarker(location);
    final controller = Get.find<InstallationStepsController>();
    controller.setSelectedLocation(location);
    controller.updateAddressFromLocation(location);
  }

  @override
  void dispose() {
    // _mapController?.dispose();
    super.dispose();
  }
  Timer? debounce;
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InstallationStepsController>();
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive width for tablet
        double contentWidth = constraints.maxWidth > 700 ? 700 : constraints.maxWidth * 0.9;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: AlignmentGeometry.center,
              width: contentWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppText("Address", style: AppTextStyle.extraBold44(color: AppColors.black002432)),
                  const Gap(4),
                  AppText(
                    "Enter an address or click directly on the map",
                    style: AppTextStyle.regular16(color: AppColors.black002432),
                    textAlign: TextAlign.center,
                  ),
                  Gap(MediaQuery.of(context).size.height * 0.02),
                  CommonTextField(
                    hintText: "Search",
                    controller: controller.addressSearchController,
                    prefixIcon: Padding(padding: const EdgeInsets.only(left: 12), child: Assets.icons.icSearch.svg()),
                    onChanged: (value) {
                      if (debounce?.isActive ?? false) debounce!.cancel();

                      debounce = Timer(const Duration(milliseconds: 500), () {
                        controller.searchAddress(value);

                      });
                    },
                    suffixIcon: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        onTap: () {
                          controller.addressSearchController.clear();
                          controller.addressSuggestions.clear();
                        },
                        child: Padding(padding: const EdgeInsets.only(right: 18.0), child: Icon(Icons.close)),
                      ),
                    ),
                  ),
                  const Gap(20),

                  Obx(() {
                    return Expanded(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.grey6B7E8F,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            height: MediaQuery.of(context).size.height,
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                children: [
                                  GoogleMap(
                                    initialCameraPosition: CameraPosition(target: _selectedLocation, zoom: 18.5),
                                    cameraTargetBounds: CameraTargetBounds(germanyBounds),
                                    markers: _markers,
                                    onMapCreated: (GoogleMapController controller) {
                                      setState(() {
                                        mapController = controller;
                                        _isMapLoading = false;
                                      });
                                    },
                                    onTap: (LatLng location) {
                                      _onLocationChanged(location);
                                    },
                                    mapType: MapType.satellite,
                                    zoomControlsEnabled: false,
                                    myLocationButtonEnabled: true,
                                    compassEnabled: false,
                                    scrollGesturesEnabled: false,
                                    zoomGesturesEnabled: false,
                                    tiltGesturesEnabled: false,
                                    rotateGesturesEnabled: false,
                                  ),
                                  if (_isMapLoading)
                                    Positioned.fill(
                                      child: Container(
                                        color: AppColors.greyADB9BD.withValues(alpha: 0.1),
                                        child: Center(child: CircularProgressIndicator(color: AppColors.black002432)),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Obx(() {
                            if (controller.isLoadingSuggestions.value) {
                              return _buildShimmerSuggestions();
                            }
                            if (controller.addressSuggestions.isNotEmpty) {
                              return _buildSuggestionsList(controller);
                            }
                            return const SizedBox.shrink();
                          }),
                          if (controller.isGeocoding.value)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(child: CircularProgressIndicator(color: AppColors.black002432)),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                  Gap(10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.greenFAFFE9, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Assets.icons.icLocationIcon.svg(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppText(
                                "Selected location",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                              const Gap(8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      "${controller.selectedLocation?.latitude.toString() ?? ''},${controller.selectedLocation?.longitude.toString() ?? ''}",

                                      style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                                    ),
                                    Obx(
                                      () => AppText(
                                        controller.selectedAddress.value.isNotEmpty
                                            ? controller.selectedAddress.value
                                            : "",
                                        style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(20),
                  Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          controller.showAddressSelectionScreen = false;
                          controller.showStepTypeScreen = true;
                          controller.addressLoader.value = false;
                          controller.update();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.greyADB9BD),
                          ),
                          child: Text("Skip", style: AppTextStyle.semiBold16(color: AppColors.black002432)),
                        ),
                      ),
                      const Gap(20),
                      Expanded(
                        child: Obx(() {
                          return controller.addressLoader.value
                              ? CommonButton(
                                  text: "",
                                  onTap: () {},
                                  color: AppColors.primaryColor,
                                  textColor: AppColors.black002432,
                                  height: 56,
                                  padding: const EdgeInsets.only(left: 25),
                                  icon: Icons.arrow_forward_ios,
                                  showArrow: false,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: CircularProgressIndicator(color: AppColors.black002432),
                                      ),
                                    ],
                                  ),
                                )
                              : InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: () {
                                    if (controller.selectedLocation != null && controller.selectedAddress.isNotEmpty) {
                                      controller.navigateToStepType(
                                        context,
                                        screenshotController: _screenshotController,
                                      );
                                    } else {
                                      AppFunctions.showToast(
                                        message: 'Please select location!',
                                        toastType: ToastificationType.error,
                                      );
                                      return;
                                    }
                                  },
                                  child: Container(
                                    height: 56,
                                    padding: const EdgeInsets.only(left: 25),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.black002432),
                                        const Gap(25),
                                        Text(
                                          "Confirm Location",
                                          style: AppTextStyle.semiBold16(color: AppColors.black002432),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerSuggestions() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: List.generate(3, (index) {
          return Shimmer.fromColors(
            baseColor: AppColors.greyADB9BD.withOpacity(0.3),
            highlightColor: AppColors.greyADB9BD.withOpacity(0.1),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: index < 2 ? BorderSide(color: AppColors.greyADB9BD.withOpacity(0.2)) : BorderSide.none,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: AppColors.greyADB9BD, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
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
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
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
          );
        }),
      ),
    );
  }

  Widget _buildSuggestionsList(InstallationStepsController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: controller.addressSuggestions.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.greyADB9BD.withOpacity(0.2)),
        itemBuilder: (context, index) {
          final suggestion = controller.addressSuggestions[index];
          return InkWell(
            onTap: () async {
              await controller.geocodeAddress(suggestion.formattedAddress);
              // Update map marker after geocoding
              if (controller.selectedLocation != null) {
                _updateMarker(controller.selectedLocation!);
                mapController?.animateCamera(CameraUpdate.newLatLngZoom(controller.selectedLocation!, 16.0));
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: AppColors.primaryColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(suggestion.displayName, style: AppTextStyle.semiBold14(color: AppColors.black002432)),
                        const SizedBox(height: 4),
                        Text(
                          suggestion.formattedAddress,
                          style: AppTextStyle.regular12(color: AppColors.greyADB9BD),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
