import 'package:heimwatt/app/modules/deal_selection/deal_controller.dart';
import 'package:heimwatt/app/modules/deal_selection/model/deal_model.dart';
import 'package:heimwatt/app/utils/pref_service.dart';
import '../../utils/exports.dart';

class DealScreen extends StatefulWidget {
  const DealScreen({super.key});

  @override
  State<DealScreen> createState() => _DealScreenState();
}

class _DealScreenState extends State<DealScreen> {
  DealController dealController = Get.put(DealController());

  @override
  void initState() {
    dealController.getSearchDeal(context: context);
    // dealController.dealList = [
    //   DealData(
    //     id: "453286513887",
    //     name: "TEST_PV_SYLVESTER_!NO DEL!",
    //     stage: "angebot_erstellt",
    //     stageLabel: "Angebot erstellt",
    //     projectType: "photovoltaic",
    //     projectTypeLabel: "Photovoltaikanlage",
    //     address: Address(street: "Huskoppel 5", zip: "21376", city: "Salzhausen"),
    //   ),
    //   DealData(
    //     id: "451673242863",
    //     name: "TEST_PV_SYLVESTER_!NO DEL!",
    //     stage: "angebot_erstellt",
    //     stageLabel: "Angebot erstellt",
    //     projectType: "photovoltaic",
    //     projectTypeLabel: "Photovoltaikanlage",
    //     address: Address(street: "Huskoppel 5", zip: "21376", city: "Salzhausen"),
    //   ),
    //   DealData(
    //     id: "451619774658",
    //     name: "TEST_WP_Sylvester_!NO DEL!",
    //     stage: "angebot_erstellt",
    //     stageLabel: "Angebot erstellt",
    //     projectType: "heatpump",
    //     projectTypeLabel: "Wärmepumpe",
    //     address: Address(street: "Huskoppel 5", zip: "21376", city: "Salzhausen"),
    //   ),
    // ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: GetBuilder<DealController>(
        builder: (controller) {
          return Obx(() {
            if (controller.loader.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.dealList.isEmpty) {
              return const Center(child: Text("No Deals Found"));
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// Title
                      Text(
                        "Select Deal",
                        style: AppTextStyle.semiBold24(color: Colors.black),
                      ),

                      const SizedBox(height: 30),

                      /// Deal List
                      Expanded(
                        child: ListView.separated(
                          itemCount: controller.dealList.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 20),
                          itemBuilder: (context, index) {
                            final deal = controller.dealList[index];

                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () async {

                                ///dynamic code
                                await PrefService.setValue(PrefService.dealId, controller.dealList[index].id ?? '');
                                await controller.getDealById(context: context, index: index);
                                ///static code
                                // await PrefService.setValue(PrefService.dealId, controller.dealList[index].id ?? '');
                                // await PrefService.setValue(PrefService.dealName, controller.dealList[index].projectType);
                                // context.go(AppRoutes.installationSteps);

                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                  border: Border.all(
                                      color: AppColors.primaryColor.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [

                                    /// Icon
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.home_work_outlined,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),

                                    const SizedBox(width: 20),

                                    /// Deal Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [

                                          Text(
                                            deal.projectTypeLabel ?? '',
                                            style: AppTextStyle.semiBold18(
                                                color: Colors.black),
                                          ),

                                          const SizedBox(height: 6),

                                          Text(
                                            "${deal.address?.street}, ${deal.address?.zip} ${deal.address?.city}",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                            ),
                                          ),

                                          const SizedBox(height: 6),

                                          Text(
                                            deal.stageLabel ?? '',
                                            style: TextStyle(
                                              color: AppColors.primaryColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    /// Loader / Arrow
                                    deal.loader == true
                                        ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                        : const Icon(Icons.arrow_forward_ios,
                                        size: 18)
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}