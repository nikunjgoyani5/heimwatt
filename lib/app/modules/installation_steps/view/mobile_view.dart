import 'package:heimwatt/app/modules/installation_steps/address_selection_screen/address_selection_mobile.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_form/view/mobile_view.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_steps_controller.dart';
import 'package:heimwatt/app/modules/installation_steps/media_library_form_screen/Views/media_library_mobile.dart';
import 'package:heimwatt/app/modules/installation_steps/project_screen/views/project_mobile.dart';
import 'package:heimwatt/app/modules/installation_steps/steps_type_selection/views/step_type_mobile.dart';
import 'package:heimwatt/app/modules/installation_steps/tutorial_screen/views/tutorial_mobile.dart';
import 'package:heimwatt/app/utils/pref_service.dart';

import '../../../utils/exports.dart';
import '../../../utils/secure_token_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InstallationStepsMobileView extends StatefulWidget {
  const InstallationStepsMobileView({super.key});

  @override
  State<InstallationStepsMobileView> createState() => _InstallationStepsMobileViewState();
}

class _InstallationStepsMobileViewState extends State<InstallationStepsMobileView> {
  final GlobalKey _profileKey = GlobalKey();
  bool _isProfileMenuOpen = false;

  static void showLogoutDialog(BuildContext context) {
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
                  child: Icon(Icons.logout_rounded, size: 56, color: AppColors.redColor),
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
                      onTap: () async {
                        Navigator.of(dialogContext).pop();
                        // Sign out from Firebase
                        await FirebaseAuth.instance.signOut();
                        // Clear tokens
                        await SecureTokenService.deleteAllTokens();
                        // Clear
                        await PrefService.clear();
                        // Navigate to login
                        if (context.mounted) {
                          context.go(AppRoutes.login);
                        }
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
                            const Icon(Icons.logout_rounded, size: 18, color: AppColors.whiteColor),
                            const Gap(8),
                            Text(AppStrings.logout, style: AppTextStyle.semiBold16(color: AppColors.whiteColor)),
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

  void _showProfileMenu(BuildContext context) {
    final RenderBox? renderBox = _profileKey.currentContext?.findRenderObject() as RenderBox?;
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Icon(Icons.logout_rounded, size: 18, color: AppColors.redColor),
                              const Gap(10),
                              Text(AppStrings.logout, style: AppTextStyle.medium14(color: AppColors.black002432)),
                            ],
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
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.whiteF5F5F5,
      body: GetBuilder<InstallationStepsController>(
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, width, controller),
                const Gap(25),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                          child: child,
                        ),
                      );
                    },
                    child: _buildCurrentScreen(controller),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double width, InstallationStepsController controller) {
    return Column(
      children: [
        Row(
          children: [
            Image.asset(
              Assets.images.logo.path,
              height: MediaQuery.of(context).size.width * 0.075,
              fit: BoxFit.contain,
            ),
            const Spacer(),

            const Gap(10),

            controller.userRole.value == 'customer'
                ? InkWell(
                    onTap: () {
                      context.go(AppRoutes.dealSelection);
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Gap(8),
                          Text('Switch Project', style: AppTextStyle.medium12()),
                        ],
                      ),
                    ),
                  )
                : SizedBox(),
            const Gap(10),
            InkWell(
              key: _profileKey,
              onTap: () {
                _showProfileMenu(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _isProfileMenuOpen ? AppColors.primaryColor : Colors.transparent, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(Assets.images.staticProfile.path, width: 40, height: 40, fit: BoxFit.cover),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentScreen(InstallationStepsController controller) {
    Widget screen;
    String key;

    if (controller.showInstallationFormScreen) {
      screen = InstallationFormMobileView();
      key = 'installation_form';
    } else if (controller.showMediaLibraryScreen) {
      screen = MediaLibraryMobile();
      key = 'media_library';
    } else if (controller.showStepTypeScreen) {
      screen = StepTypeMobile();
      key = 'step_type';
    } else if (controller.showAddressSelectionScreen) {
      screen = AddressSelectionMobile();
      key = 'address_selection';
    } else if (controller.showTutorialScreen) {
      screen = TutorialMobile();
      key = 'tutorial';
    } else {
      screen = ProjectMobile();
      key = 'project';
    }

    return KeyedSubtree(key: ValueKey(key), child: screen);
  }
}
