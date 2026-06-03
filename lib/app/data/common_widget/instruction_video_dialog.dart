import 'package:video_player/video_player.dart';

import '../../utils/exports.dart';

class InstructionVideoDialog extends StatefulWidget {
  final String? videoUrl; // Optional video URL for future implementation

  const InstructionVideoDialog({super.key, this.videoUrl});

  static void show(BuildContext context, {String? videoUrl}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width < 600 ? 16 : 40,
            vertical: MediaQuery.of(context).size.height < 600 ? 16 : 40,
          ),
          child: InstructionVideoDialog(videoUrl: videoUrl),
        );
      },
    );
  }

  @override
  State<InstructionVideoDialog> createState() => _InstructionVideoDialogState();
}

class _InstructionVideoDialogState extends State<InstructionVideoDialog> {
  VideoPlayerController? videoPlayerController;

  static const String defaultVideoUrl = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  @override
  void initState() {
    super.initState();
    final url = widget.videoUrl ?? defaultVideoUrl;
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing
    final isMobile = screenWidth < 600;
    final dialogWidth = isMobile ? screenWidth - 32 : (screenWidth * 0.8).clamp(600.0, 1000.0);
    final dialogHeight = isMobile
        ? (screenHeight * 0.2).clamp(400.0, 600.0)
        : (screenHeight * 0.75).clamp(500.0, 800.0);

    return Container(
      width: dialogWidth,
      height: dialogHeight,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Header with close button and title
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Row(
              children: [
                // Close button
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      width: isMobile ? 32 : 40,
                      height: isMobile ? 32 : 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.whiteColor,
                        border: Border.all(color: AppColors.greyADB9BD, width: 1.5),
                      ),
                      child: Icon(Icons.close, size: isMobile ? 18 : 20, color: AppColors.black002432),
                    ),
                  ),
                ),
                const Gap(16),
                // Title
                Expanded(
                  child: AppText(
                    'Instruction',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black002432,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Video player area
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 0, isMobile ? 16 : 24, isMobile ? 16 : 24),
              child:  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.whiteF5F5F5,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(borderRadius: BorderRadius.circular(16), child: _buildVideoPlayer(isMobile)),
                  ),


            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(bool isMobile) {
    if (videoPlayerController == null) {
      return SizedBox();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: videoPlayerController!.value.size.width,
                height: videoPlayerController!.value.size.height,
                child: VideoPlayer(videoPlayerController!),
              ),
            ),
          ),
        ),

        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              if (videoPlayerController!.value.isPlaying) {
                videoPlayerController!.pause(); // 👈 pause → show icon
              } else {
                videoPlayerController!.play(); // 👈 play → hide icon
              }
            });
          },
          child: AnimatedOpacity(
            opacity:  videoPlayerController!.value.isPlaying ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Image.asset(
                  Assets.icons.icPlay.path, // or pause icon if you want
                  scale: 3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
