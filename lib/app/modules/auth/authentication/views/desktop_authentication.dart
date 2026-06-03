import 'package:flutter/material.dart';
import 'package:heimwatt/app/theme/colors.dart';


class DesktopAuthentication extends StatelessWidget {
  const DesktopAuthentication({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body:
      Center(
          child: const CircularProgressIndicator()
      ),
    );
  }
}

