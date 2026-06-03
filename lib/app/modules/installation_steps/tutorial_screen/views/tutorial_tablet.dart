import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';

import '../../../../utils/exports.dart';
import '../../installation_steps_controller.dart';

class TutorialTablet extends StatelessWidget {
  const TutorialTablet({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return GetBuilder<InstallationStepsController>(
      builder: (controller) {
        return Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              controller.navigateToAddressSelection();
            },
            extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
            backgroundColor: AppColors.primaryColor,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            icon: Icon(Icons.chevron_right, color: AppColors.black002432, size: 20),
            label: Text('Continue', style: AppTextStyle.semiBold16(color: AppColors.black002432)),
          ),
          backgroundColor: AppColors.whiteF5F5F5,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText('Tutorial', style: AppTextStyle.extraBold40(color: AppColors.black002432)),
                const Gap(20),
                // Video Player Container
                SizedBox(
                  width: width,
                  height: height * 0.6,
                  child: Stack(
                    children: [
                      // Video Player
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: controller.isVideoInitialized.value && controller.videoController != null
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
                                  child: CircularProgressIndicator(
                                    color: AppColors.whiteColor,

                                  ),
                                ),
                              ),
                      ),
                      // Play/Stop Button (top left)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: GestureDetector(
                          onTap: () => controller.togglePlayPause(),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  controller.showPlayButton.value ? CupertinoIcons.play_arrow : CupertinoIcons.stop,
                                  color: AppColors.black002432,
                                  size: 18,
                                ),
                                const Gap(6),
                                Text(
                                  controller.showPlayButton.value ? 'Play' : 'Stop',
                                  style: AppTextStyle.semiBold14(color: AppColors.black002432),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(24),
                // Instructional Text
                SizedBox(
                  width: width * 0.9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Start with wide photos of the front and back of your house that show the full roof outline. Then, take closer shots of the roof surface so the tiles or materials are clearly visible. Capture the roof edges, corners, chimneys, vents, skylights, or anything else built into or attached to the roof.',
                        style: AppTextStyle.regular14(color: AppColors.black002432),
                      ),
                      const Gap(14),
                      AppText(
                        'It\'s also important to show any shading elements like nearby trees, taller buildings, or structures that could block sunlight during the day. If possible, step back far enough to capture how the roof slopes and in which direction it faces.',
                        style: AppTextStyle.regular14(color: AppColors.black002432),
                      ),
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
