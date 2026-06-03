import 'package:fluttertoast/fluttertoast.dart';
import 'package:toastification/toastification.dart';

import 'exports.dart';

class AppFunctions {

  static void   showToast({
    required String message,
    ToastificationType toastType = ToastificationType.success,
    void Function(ToastificationItem)? onTap,
    void Function(ToastificationItem)? onCloseButtonTap,
    void Function(ToastificationItem)? onAutoCompleteCompleted,
    void Function(ToastificationItem)? onDismissed,
  }) {
    toastification.dismissAll();
    toastification.show(
      type: toastType,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 4),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5),
          Row(
            children: [
              Icon(
                (toastType == ToastificationType.success)
                    ? Icons.check_circle
                    : (toastType == ToastificationType.info)
                    ? Icons.info
                    : (toastType == ToastificationType.warning)
                    ? Icons.warning
                    : Icons.close,
              ),
              SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (toastType == ToastificationType.success)
                          ? "SUCCESS"
                          : (toastType == ToastificationType.info)
                          ? "INFO"
                          : (toastType == ToastificationType.warning)
                          ? "WARNING"
                          : "ERROR",

                    ),
                    Gap(2),
                    Text(message, maxLines: 3),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      showIcon: false,
      alignment: Alignment.topRight,
      direction: TextDirection.ltr,
      primaryColor: (toastType == ToastificationType.success)
          ? AppColors.primaryColor
          : (toastType == ToastificationType.info)
          ? AppColors.yellowFFC602
          : (toastType == ToastificationType.warning)
          ? AppColors.yellowFFC602
          : AppColors.redEF4444,
      backgroundColor: (toastType == ToastificationType.success)
          ? AppColors.greenF2FBFA
          : (toastType == ToastificationType.info)
          ? AppColors.yellowFfffea
          : (toastType == ToastificationType.warning)
          ? AppColors.yellowFfffea
          : AppColors.redFee2e2,

      borderSide: BorderSide(
        color: (toastType == ToastificationType.success)
            ? AppColors.green4AB7B0
            : (toastType == ToastificationType.info)
            ? AppColors.yellowFFC602
            : (toastType == ToastificationType.warning)
            ? AppColors.yellowFFC602
            : AppColors.redEF4444,
        width: 1,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: false,
      closeButton: ToastCloseButton(
        showType: CloseButtonShowType.always,
        buttonBuilder: (context, onClose) {
          return IconButton(
            hoverColor: Colors.transparent,
            onPressed: onClose,
            icon: Icon(Icons.close, size: 16, color: AppColors.grey6B7E8F),
          );
        },
      ),
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
      applyBlurEffect: false,
      callbacks: ToastificationCallbacks(
        onTap: onTap,
        onCloseButtonTap: onCloseButtonTap,
        onAutoCompleteCompleted: onAutoCompleteCompleted,
        onDismissed: onDismissed,
      ),
    );
  }







  void closeKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }



}
