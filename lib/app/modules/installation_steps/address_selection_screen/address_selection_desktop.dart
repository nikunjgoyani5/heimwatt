import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_steps_controller.dart';
import 'package:heimwatt/app/modules/installation_steps/address_selection_screen/models/place_suggestion_model.dart';
import 'package:heimwatt/app/utils/app_functions.dart';
import 'package:heimwatt/app/utils/exports.dart';
import 'package:screenshot/screenshot.dart';
import 'package:toastification/toastification.dart';
import 'package:shimmer/shimmer.dart';

import '../../../utils/pref_service.dart';

class AddressSelectionDesktop extends StatefulWidget {
  const AddressSelectionDesktop({super.key});

  @override
  State<AddressSelectionDesktop> createState() => _AddressSelectionDesktopState();
}

class _AddressSelectionDesktopState extends State<AddressSelectionDesktop> {
  InstallationStepsController controller = Get.put(InstallationStepsController());
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  LatLng _selectedLocation = const LatLng(51.1657, 10.4515);
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive width - max 800px, but adapt to available space
        double contentWidth = constraints.maxWidth > 800
            ? 690
            : constraints.maxWidth > 600
            ? constraints.maxWidth * 0.8
            : constraints.maxWidth * 0.95;

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
                  AppText("Address", style: AppTextStyle.extraBold36(color: AppColors.black002432)),
                  const Gap(2),
                  AppText(
                    "Enter an address or click directly on the map",
                    style: AppTextStyle.regular16(color: AppColors.black002432),
                    textAlign: TextAlign.center,
                  ),
                  Gap(MediaQuery.of(context).size.height * 0.01),
                  CommonTextField(
                    hintText: "Search",

                    radius: BorderRadius.circular(30),
                    controller: controller.addressSearchController,
                    prefixIcon: Padding(padding: const EdgeInsets.only(left: 15), child: Assets.icons.icSearch.svg()),
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
                  Gap(MediaQuery.of(context).size.height * 0.015),

                  Obx(() {
                    return Expanded(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.greyADB9BD,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            height: MediaQuery.of(context).size.height,
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                children: [
                                  Screenshot(
                                    controller: _screenshotController,
                                    child: GoogleMap(
                                      zoomControlsEnabled: false,

                                      initialCameraPosition: CameraPosition(target: _selectedLocation, zoom: 18.5),

                                      cameraTargetBounds: CameraTargetBounds(germanyBounds),
                                      markers: _markers,
                                      onMapCreated: (GoogleMapController controller) {
                                        _mapController = controller;
                                        setState(() {
                                          _isMapLoading = false;
                                        });
                                      },
                                      onTap: (LatLng location) {
                                        _onLocationChanged(location);
                                      },
                                      mapType: MapType.satellite,
                                      myLocationButtonEnabled: true,
                                      compassEnabled: false,
                                      scrollGesturesEnabled: false,
                                      zoomGesturesEnabled: false,
                                      tiltGesturesEnabled: false,
                                      rotateGesturesEnabled: false,
                                    ),
                                  ),
                                  if (_isMapLoading)
                                    Positioned.fill(
                                      child: Container(
                                        color: AppColors.greyADB9BD.withValues(alpha: 0.1),
                                        child: Center(
                                          child: CircularProgressIndicator(color: AppColors.black002432),
                                        ),
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

                  Gap(MediaQuery.of(context).size.height * 0.015),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015),
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
                              AppText(
                                "Selected location",
                                style: AppTextStyle.extraBold16(color: AppColors.black002432),
                              ),
                              const Gap(35),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      "${controller.selectedLocation?.latitude.toString() ?? ''},${controller.selectedLocation?.longitude.toString() ?? ''}",
                                      style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                                    ),
                                    Gap(4),
                                    Obx(
                                      () => AppText(
                                        controller.selectedAddress.value.isNotEmpty
                                            ? controller.selectedAddress.value
                                            : "",
                                        style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
                                        maxLines: 2,
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
                  Gap(MediaQuery.of(context).size.height * 0.015),
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
                      Gap(20),
                      Expanded(
                        /*child: CommonButton(
                                text: "Confirm Location",
                                onTap: () {
                                  controller.navigateToStepType();
                                },
                              ),*/
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
                              : CommonButton(
                                  text: "Confirm Location",
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
                                  color: AppColors.primaryColor,
                                  textColor: AppColors.black002432,
                                  height: 56,
                                  padding: const EdgeInsets.only(left: 25),
                                  icon: Icons.arrow_forward_ios,
                                  showArrow: false,
                                );
                        }),
                      ),
                    ],
                  ),
                  Gap(MediaQuery.of(context).size.height * 0.015),
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
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02),
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
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02),
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
                _mapController?.animateCamera(CameraUpdate.newLatLngZoom(controller.selectedLocation!, 18.5));
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
                        Text(suggestion.displayName, style: AppTextStyle.semiBold14(color: AppColors.black002432)),
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
