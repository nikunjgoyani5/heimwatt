import 'package:heimwatt/app/modules/installation_steps/address_selection_screen/address_selection_tablet.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_form/view/tablet_view.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_steps_controller.dart';
import 'package:heimwatt/app/modules/installation_steps/media_library_form_screen/Views/checklist_drawer.dart';
import 'package:heimwatt/app/modules/installation_steps/media_library_form_screen/Views/media_library_tablet.dart';
import 'package:heimwatt/app/modules/installation_steps/project_screen/views/project_tablet.dart';
import 'package:heimwatt/app/modules/installation_steps/steps_type_selection/views/step_type_tablet.dart';
import 'package:heimwatt/app/modules/installation_steps/tutorial_screen/views/tutorial_tablet.dart';
import 'package:heimwatt/app/utils/pref_service.dart';

import '../../../utils/exports.dart';
import '../../../utils/secure_token_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InstallationStepsTabletView extends StatefulWidget {
  const InstallationStepsTabletView({super.key});

  @override
  State<InstallationStepsTabletView> createState() =>
      _InstallationStepsTabletViewState();
}

class _InstallationStepsTabletViewState
    extends State<InstallationStepsTabletView> {
  final GlobalKey _profileKey = GlobalKey();
  bool _isProfileMenuOpen = false;

  static void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 40,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.3,
            ),
            padding: const EdgeInsets.all(40),
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
                  decoration: BoxDecoration(
                    color: AppColors.redColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    size: 56,
                    color: AppColors.redColor,
                  ),
                ),
                const Gap(24),
                AppText(
                  AppStrings.logoutConfirmation,
                  style: AppTextStyle.semiBold24(color: AppColors.black002432),
                  textAlign: TextAlign.center,
                ),
                const Gap(16),
                AppText(
                  AppStrings.logoutConfirmationMessage,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.greyADB9BD,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyle.semiBold16(
                              color: AppColors.black002432,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Gap(16),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: InkWell(
                        onTap: () async {
                          Navigator.of(dialogContext).pop();
                          // Sign out from Firebase
                          await FirebaseAuth.instance.signOut();
                          // Clear tokens
                          await SecureTokenService.deleteAllTokens();
                          await PrefService.clear();
                          // Navigate to login
                          if (context.mounted) {
                            // Use the configured auth route, which shows the login screen
                            context.go(AppRoutes.auth);
                          }
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.redColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.redColor.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.logout_rounded,
                                size: 18,
                                color: AppColors.whiteColor,
                              ),
                              const Gap(8),
                              Text(
                                AppStrings.logout,
                                style: AppTextStyle.semiBold16(
                                  color: AppColors.whiteColor,
                                ),
                              ),
                            ],
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

  void _showProfileMenu(BuildContext context) {
    final RenderBox? renderBox =
        _profileKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    setState(() {
      _isProfileMenuOpen = true;
    });

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  setState(() {
                    _isProfileMenuOpen = false;
                  });
                },
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              top: position.dy + size.height + 8,
              left: position.dx - 150 + size.width,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          setState(() {
                            _isProfileMenuOpen = false;
                          });
                          showLogoutDialog(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  size: 18,
                                  color: AppColors.redColor,
                                ),
                                const Gap(10),
                                Text(
                                  AppStrings.logout,
                                  style: AppTextStyle.medium14(
                                    color: AppColors.black002432,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() {
          _isProfileMenuOpen = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteF5F5F5,
      body: GetBuilder<InstallationStepsController>(
        builder: (controller) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          Assets.images.logo.path,
                          height: MediaQuery.of(context).size.width * 0.03,
                          fit: BoxFit.contain,
                        ),
                        Spacer(),
                        const Gap(16),
                        if ((controller.showInstallationFormScreen ||
                                controller.showMediaLibraryScreen) &&
                            (controller.ispdf == false))
                          InkWell(
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: AppColors.greyADB9BD),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    Assets.icons.icGalleryPng.path,
                                    scale: 3,
                                  ),
                                  const Gap(8),
                                  Text(
                                    controller.showInstallationFormScreen
                                        ? AppStrings.switchToBulkUpload
                                        : "Switch to Step-by-Step Upload",
                                    style: AppTextStyle.medium14(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const Gap(16),

                        controller.userRole.value == 'customer'
                            ? InkWell(
                                onTap: () {
                                  context.go(AppRoutes.dealSelection);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Gap(8),
                                      Text(
                                        'Switch Project',
                                        style: AppTextStyle.medium14(),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(),
                        const Gap(16),
                        InkWell(
                          key: _profileKey,
                          onTap: () {
                            _showProfileMenu(context);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _isProfileMenuOpen
                                    ? AppColors.primaryColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                Assets.images.staticProfile.path,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    (controller.showStepTypeScreen ||
                                            controller
                                                .showInstallationFormScreen ||
                                            controller.showMediaLibraryScreen)
                                        ? ClipOval(
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppColors.whiteColor,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppColors.greyADB9BD,
                                                ),
                                              ),
                                              child: Image.asset(
                                                Assets.icons.icProjects.path,
                                                scale: 3,
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                    (controller.showStepTypeScreen ||
                                            controller
                                                .showInstallationFormScreen ||
                                            controller.showMediaLibraryScreen)
                                        ? Gap(5)
                                        : SizedBox(),
                                    (controller.showStepTypeScreen ||
                                            controller
                                                .showInstallationFormScreen ||
                                            controller.showMediaLibraryScreen)
                                        ? AppText(
                                            AppStrings.project,
                                            style: AppTextStyle.semiBold16(
                                              color: AppColors.black002432,
                                            ),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                                (controller.showStepTypeScreen ||
                                        controller.showInstallationFormScreen ||
                                        controller.showMediaLibraryScreen)
                                    ? Gap(10)
                                    : SizedBox(),
                                (controller.showStepTypeScreen ||
                                        controller.showInstallationFormScreen ||
                                        controller.showMediaLibraryScreen)
                                    ? Icon(
                                        Icons.arrow_forward_ios,
                                        size: 17,
                                        color: AppColors.greyADB9BD,
                                      )
                                    : SizedBox(),
                                (controller.showStepTypeScreen ||
                                        controller.showInstallationFormScreen ||
                                        controller.showMediaLibraryScreen)
                                    ? Gap(10)
                                    : SizedBox(),
                                /* Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ClipOval(
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.whiteColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.greyADB9BD),
                                        ),
                                        child: Image.asset(Assets.icons.icSun.path, scale: 3),
                                      ),
                                    ),
                                    const Gap(5),
                                    AppText(
                                      AppStrings.photovoltaicSystem,
                                      style: AppTextStyle.semiBold16(color: AppColors.black002432),
                                    ),
                                  ],
                                ),
                                const Gap(10),
                                Icon(Icons.arrow_forward_ios, size: 17, color: AppColors.greyADB9BD),*/
                                const Gap(10),
                                if (controller.showStepTypeScreen ||
                                    controller.showInstallationFormScreen ||
                                    controller.showMediaLibraryScreen)
                                  InkWell(
                                    hoverColor: Colors.transparent,
                                    // Removes hover color
                                    splashColor: Colors.transparent,
                                    // Optional: remove splash
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      controller.navigateToTutorial();
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ClipOval(
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppColors.whiteColor,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.greyADB9BD,
                                              ),
                                            ),
                                            child: Image.asset(
                                              Assets.icons.icTutorial.path,
                                              scale: 3,
                                            ),
                                          ),
                                        ),
                                        const Gap(5),
                                        Text(
                                          AppStrings.tutorial,
                                          style: AppTextStyle.semiBold16(
                                            color: AppColors.black002432,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const Gap(10),
                                if (controller.showInstallationFormScreen ||
                                    controller.showMediaLibraryScreen)
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 17,
                                    color: AppColors.greyADB9BD,
                                  ),
                                if (controller.showInstallationFormScreen ||
                                    controller.showMediaLibraryScreen)
                                  const Gap(10),
                                if (controller.showInstallationFormScreen ||
                                    controller.showMediaLibraryScreen)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ClipOval(
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.whiteColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.greyADB9BD,
                                            ),
                                          ),
                                          child: Image.asset(
                                            Assets.icons.icForm.path,
                                            scale: 3,
                                          ),
                                        ),
                                      ),
                                      const Gap(5),
                                      AppText(
                                        AppStrings.installationForm,
                                        style: AppTextStyle.semiBold16(
                                          color: AppColors.black002432,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (controller.showInstallationFormScreen ||
                        controller.showMediaLibraryScreen)
                      if (controller.ispdf == false) ...[
                        Gap(20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (controller
                                .showInstallationFormScreen /*|| controller.showMediaLibraryScreen*/ )
                              Flexible(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: FutureBuilder<StepStatusResult>(
                                    future: controller.fetchStepStatuses(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return SizedBox();
                                      }

                                      if (snapshot.hasError) {
                                        return SizedBox();
                                      }

                                      final data = snapshot.data;
                                      final stepCount = data?.stepCount ?? 0;
                                      final statuses =
                                          data?.statuses ??
                                          const <StepStatus>[];

                                      return _buildStepsRow(
                                        stepCount: stepCount,
                                        statuses: statuses,
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Gap(30),
                      ],
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(1.0, 0),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeInOut,
                                        ),
                                      ),
                                  child: child,
                                ),
                              );
                            },
                        child: _buildCurrentScreen(controller),
                      ),
                    ),
                  ],
                ),
              ),

              // Drawer-related widgets with isolated updates
              GetBuilder<InstallationStepsController>(
                id: 'drawer',
                builder: (drawerController) {
                  return Stack(
                    children: [
                      // Semi-transparent overlay when drawer is open
                      if (drawerController.isChecklistDrawerOpen)
                        Positioned.fill(
                          child: InkWell(
                            onTap: () {
                              drawerController.isChecklistDrawerOpen = false;
                              drawerController.update(['drawer']);
                            },
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      // Checklist Drawer with animation (on top of overlay)
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        right: drawerController.isChecklistDrawerOpen
                            ? 0
                            : -500,
                        top: 0,
                        bottom: 0,
                        child: RepaintBoundary(
                          child: drawerController.isChecklistDrawerOpen
                              ? const ChecklistDrawer()
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentScreen(InstallationStepsController controller) {
    Widget screen;
    String key;

    if (controller.showInstallationFormScreen) {
      screen = InstallationFormTabletView();
      key = 'installation_form';
    } else if (controller.showMediaLibraryScreen) {
      screen = MediaLibraryTablet();
      key = 'media_library';
    } else if (controller.showStepTypeScreen) {
      screen = StepTypeTablet();
      key = 'step_type';
    } else if (controller.showAddressSelectionScreen) {
      screen = AddressSelectionTablet();
      key = 'address_selection';
    } else if (controller.showTutorialScreen) {
      screen = TutorialTablet();
      key = 'tutorial';
    } else {
      screen = ProjectTablet();
      key = 'project';
    }

    return KeyedSubtree(key: ValueKey(key), child: screen);
  }

  Widget _buildStepsRow({
    required int stepCount,
    required List<StepStatus> statuses,
  }) {
    if (stepCount <= 0) {
      return const SizedBox();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(stepCount, (index) {
          final status = index < statuses.length
              ? statuses[index]
              : StepStatus.empty;
          Color stepColor;
          switch (status) {
            case StepStatus.complete:
              stepColor = AppColors.primaryColor;
              break;
            case StepStatus.partial:
              stepColor = Colors.red;
              break;
            case StepStatus.empty:
            default:
              stepColor = AppColors.greyADB9BD;
          }

          return [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: stepColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AppText(
                  '${index + 1}',
                  style: AppTextStyle.semiBold16(color: AppColors.whiteColor),
                ),
              ),
            ),
            if (index < stepCount - 1) const Gap(8),
          ];
        }).expand((widgets) => widgets),
      ],
    );
  }
}
