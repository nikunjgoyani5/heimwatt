import 'package:flutter/cupertino.dart';
import 'package:heimwatt/app/utils/pref_service.dart';

import '../../../../theme/colors.dart';
import '../../../../theme/text_styles.dart';

class ProjectTablet extends StatefulWidget {
  const ProjectTablet({super.key});

  @override
  State<ProjectTablet> createState() => _ProjectTabletState();
}

class _ProjectTabletState extends State<ProjectTablet> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(height:MediaQuery.of(context).size.height*0.6,child: Center(child: Text("Projects> ${PrefService.getString(PrefService.dealName)}",style: AppTextStyle.extraBold44(color: AppColors.black002432),))),
    );
  }
}
