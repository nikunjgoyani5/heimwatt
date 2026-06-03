import 'package:heimwatt/app/modules/deal_selection/model/deal_model.dart';
import 'package:heimwatt/app/utils/app_functions.dart';
import 'package:heimwatt/app/utils/pref_service.dart';
import 'package:heimwatt/repository/main_repository.dart';

import '../../utils/exports.dart';

class DealController extends GetxController {
  RxBool loader = false.obs;

  MainRepository mainRepository = MainRepository();
  List<DealData> dealList = [];

  Future<void> getSearchDeal({required BuildContext context}) async {
    loader.value = true;
    await mainRepository.dealSearch(
      onSuccess: (dynamic response) {
        try {
          debugPrint('success:::${response.toString()} ');

          DealModel dealModel = DealModel.fromJson(response);
          dealList = dealModel.data ?? [];
          print(dealList);
          update();
        } catch (e) {
          debugPrint('error:::${response.toString()} ');
          debugPrint('error:::$e ');
        }
        loader.value = false;
        update();
      },
      onError: (dynamic error) {
        debugPrint('error:::$error');
        String message = error.message;
        loader.value = false;
        AppFunctions.showToast(message: message);
      },
    );
  }

  Future<void> getDealById({required BuildContext context, required int index}) async {
    dealList[index].loader = true;
    update();
    await mainRepository.getDealById(
      dealId: PrefService.getString(PrefService.dealId),
      onSuccess: (dynamic response) async {
        try {
          debugPrint('success:::${response.toString()} ');
          // dealList[index].loader = false;
          await PrefService.setValue(PrefService.dealName, response['data']['projectType']);
          update();
          context.go(AppRoutes.installationSteps);
        } catch (e) {
          debugPrint('error:::${response.toString()} ');
          dealList[index].loader = false;
          update();
          dealList[index].loader = false;
          update();
        }
      },
      onError: (dynamic error) {
        debugPrint('error:::$error');
        String message = error.message;
        dealList[index].loader = false;
        update();
        AppFunctions.showToast(message: message);
      },
    );
  }
}
