import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';

import '../../../../utils/exports.dart';
import '../../installation_steps_controller.dart';

class TutorialDashtop extends StatelessWidget {
  const TutorialDashtop({super.key});

  /// Only show VideoPlayer when controller has a non-null, initialized controller.
  /// Avoids using a controller after it has been disposed (e.g. during route exit).
  static bool _shouldShowVideo(InstallationStepsController controller) {
    final vc = controller.videoController;
    return controller.isVideoInitialized.value && vc != null;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return GetBuilder<InstallationStepsController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.whiteF5F5F5,
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
          floatingActionButton: Padding(
            padding: EdgeInsets.only(top: 12),
            child: FloatingActionButton.extended(
              onPressed: () {
                controller.navigateToAddressSelection();
              },
              extendedPadding: EdgeInsets.only(right: 150, left: 15),
              backgroundColor: AppColors.primaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              icon: Icon(Icons.chevron_right, color: AppColors.black002432, size: 25),
              label: Text('Continue', style: AppTextStyle.semiBold16(color: AppColors.black002432)),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText('Tutorial', style: AppTextStyle.extraBold44(color: AppColors.black002432)),
                const Gap(16),
                // Video Player Container
                SizedBox(
                  width: width,
                  height: height * 0.8,
                  child: Stack(
                    children: [
                      // Video Player
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _shouldShowVideo(controller)
                            ? GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => controller.togglePlayPause(),
                                child: SizedBox.expand(
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: controller.videoController!.value.size.width,
                                      height: controller.videoController!.value.size.height,
                                      child: VideoPlayer(controller.videoController!),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                color: AppColors.black002432,
                                child: Center(
                                  child:  const  CircularProgressIndicator(
                                  color: AppColors.whiteColor,

                                ),
                                ),
                              ),
                      ),
                      // Play/Stop Button (top left)
                      Positioned(
                        top: 16,
                        left: 16,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => controller.togglePlayPause(),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.15,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    controller.showPlayButton.value ? CupertinoIcons.play_arrow : CupertinoIcons.stop,
                                    color: AppColors.black002432,
                                    size: 20,
                                  ),
                                  const Gap(8),
                                  Text(
                                    controller.showPlayButton.value ? 'Play' : 'Stop',
                                    style: AppTextStyle.semiBold16(color: AppColors.black002432),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Continue Button (bottom center) - FloatingActionButton
                    ],
                  ),
                ),
                const Gap(32),
                // Instructional Text
                SizedBox(
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        controller.tutorialText??'',
                        style: AppTextStyle.regular16(color: AppColors.black002432),
                      ),
                      // const Gap(16),
                      // AppText(
                      //   'It\'s also important to show any shading elements like nearby trees, taller buildings, or structures that could block sunlight during the day. If possible, step back far enough to capture how the roof slopes and in which direction it faces.',
                      //   style: AppTextStyle.regular16(color: AppColors.black002432),
                      // ),
                      Gap(height * 0.09),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
