

import 'exports.dart';

class AppImageViewer {



  static CachedNetworkImage showNetworkImage({
    required String url,
    BoxFit? boxFit,
    double? height,
    double? width,
    Widget? placeholder,
  }) {

    return
     CachedNetworkImage(
      imageUrl: url,
      fit: boxFit ?? BoxFit.cover,
      height: height,
      width: width,
      placeholder: (context, url) {
        return placeholder ??
            Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color:  AppColors.black002432 ,
                shape: BoxShape.circle,
              ),
              child: Image.asset(Assets.icons.icWifi.path, scale: 4, color: AppColors.black002432),
            );

      },

      errorWidget: (context, url, error) {
        return placeholder ??
            Container(
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color:  AppColors.black002432 ,
                shape: BoxShape.circle,
              ),
              child: Image.asset(Assets.icons.icWifi.path, scale: 4, color: AppColors.black002432),
            );

      },
    );
  }
}
