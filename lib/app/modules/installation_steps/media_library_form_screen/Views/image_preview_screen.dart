import 'dart:io';

import 'package:shimmer/shimmer.dart';

import '../../../../utils/exports.dart';

class ImagePreviewScreen extends StatelessWidget {
  final bool isNetwork;
  final String? image;
  final Uint8List? imageByte;

  const ImagePreviewScreen({super.key, required this.isNetwork,  this.image, this.imageByte});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(

        backgroundColor: AppColors.whiteColor,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,

            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,

              borderRadius: BorderRadius.circular(100),
              onTap: () {
                context.pop();
              },
              child: ClipOval(
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.greyADB9BD),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_outlined, color: AppColors.black002432, size: 22),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: isNetwork
                ? Image.network(
                    image!,
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width,

                  )
                : Image.memory(imageByte!, fit: BoxFit.fitWidth, width: MediaQuery.of(context).size.width),
          ),
        ),
      ),
    );
  }
}
