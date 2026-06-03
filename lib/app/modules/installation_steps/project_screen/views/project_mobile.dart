import 'package:flutter/cupertino.dart';
import 'package:heimwatt/app/utils/pref_service.dart';

import '../../../../theme/colors.dart';
import '../../../../theme/text_styles.dart';

class ProjectMobile extends StatefulWidget {
  const ProjectMobile({super.key});

  @override
  State<ProjectMobile> createState() => _ProjectMobileState();
}

class _ProjectMobileState extends State<ProjectMobile> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(height:MediaQuery.of(context).size.height*0.7,child: Center(child: Text("Projects> ${PrefService.getString(PrefService.dealName)}",style: AppTextStyle.extraBold40(color: AppColors.black002432),))),
    );
  }
}
