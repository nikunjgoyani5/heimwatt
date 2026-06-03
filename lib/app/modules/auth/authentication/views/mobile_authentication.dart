import 'package:flutter/material.dart';

import 'package:heimwatt/app/theme/colors.dart';

class MobileAuthentication extends StatelessWidget {
  const MobileAuthentication({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Center(child: const CircularProgressIndicator()),
    );
  }
}
