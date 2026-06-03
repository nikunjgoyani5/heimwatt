import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heimwatt/app/modules/installation_steps/installation_form/models/steps_model.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../utils/exports.dart';
import '../../installation_steps_controller.dart';

class ChecklistItem {
  final String title;
  final bool isCompleted;
  final String? refImage;

  ChecklistItem({required this.title, required this.isCompleted, this.refImage});
}

class ChecklistSection {
  final String title;
  final List<ChecklistItem> items;
  final String iconPath;
  bool isExpanded;

  ChecklistSection({required this.title, required this.items, required this.iconPath, this.isExpanded = false});
}

class ChecklistDrawer extends StatefulWidget {
  final bool isDialog;

  const ChecklistDrawer({super.key, this.isDialog = false});

  static void showAsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: ChecklistDrawer(isDialog: true),
        );
      },
    );
  }

  @override
  State<ChecklistDrawer> createState() => _ChecklistDrawerState();
}

class _ChecklistDrawerState extends State<ChecklistDrawer> {
  ChecklistItem? enlargedItem;
  ChecklistSection? enlargedItemSection;

  // Default icon paths for different step titles
  String _getIconPathForStep(String stepTitle) {
    final titleLower = stepTitle.toLowerCase();
    if (titleLower.contains('roof') && titleLower.contains('shading')) {
      return Assets.images.roof.path;
    } else if (titleLower.contains('roof') && titleLower.contains('construction')) {
      return Assets.images.roofConstruction.path;
    } else if (titleLower.contains('inverter') || titleLower.contains('battery')) {
      return Assets.images.inverter.path;
    } else if (titleLower.contains('meter') || titleLower.contains('distribution')) {
      return Assets.images.meterCabinet.path;
    }
    // Default icon
    return Assets.images.roof.path;
  }

  // List sections = [];
  List<SectionModel> sections = [];

  // final sections = _buildSectionsFromFirestore(
  //   controller.installFormData,
  //   controller.projectData,
  // );
  List<ChecklistSection> _buildSectionsFromFirestore(
    Map<String, dynamic>? installFormData,
    Map<String, dynamic>? projectData,
  ) {
    if (installFormData == null) {
      return [];
    }

    final steps = installFormData['steps'] as List<dynamic>?;
    if (steps == null || steps.isEmpty) {
      return [];
    }

    final installationSteps = projectData?['installation_steps'] as Map<String, dynamic>?;

    final List<ChecklistSection> sections = [];

    for (int stepIndex = 0; stepIndex < steps.length; stepIndex++) {
      final stepData = steps[stepIndex] as Map<String, dynamic>?;
      if (stepData == null) continue;

      final stepTitle = stepData['title'] as String? ?? 'Step ${stepIndex + 1}';
      final dataField = stepData['data'];

      if (dataField == null) continue;

      // Extract data items (handle both List and Map formats)
      List<Map<String, dynamic>> dataItems = [];
      if (dataField is List) {
        dataItems = dataField
            .asMap()
            .entries
            .map((entry) {
              final item = entry.value as Map<String, dynamic>?;
              if (item != null) {
                // Add index if not present
                final itemWithIndex = Map<String, dynamic>.from(item);
                if (!itemWithIndex.containsKey('index')) {
                  itemWithIndex['index'] = entry.key.toString();
                }
                return itemWithIndex;
              }
              return <String, dynamic>{'index': entry.key.toString()};
            })
            .whereType<Map<String, dynamic>>()
            .toList();
      } else if (dataField is Map) {
        dataItems = dataField.entries
            .map((entry) {
              final item = entry.value as Map<String, dynamic>?;
              if (item != null) {
                final itemWithIndex = Map<String, dynamic>.from(item);
                // Preserve the key as index if not present
                if (!itemWithIndex.containsKey('index')) {
                  itemWithIndex['index'] = entry.key.toString();
                }
                return itemWithIndex;
              }
              return <String, dynamic>{'index': entry.key.toString()};
            })
            .whereType<Map<String, dynamic>>()
            .toList();
        // Sort by index
        dataItems.sort((a, b) {
          final aIndex = int.tryParse(a['index']?.toString() ?? '0') ?? 0;
          final bIndex = int.tryParse(b['index']?.toString() ?? '0') ?? 0;
          return aIndex.compareTo(bIndex);
        });
      }

      if (dataItems.isEmpty) continue;

      // Get project data for this step
      final stepProjectData = installationSteps?[stepIndex.toString()] as Map<String, dynamic>?;
      final stepProjectDataField = stepProjectData?['data'];

      final List<ChecklistItem> items = [];

      for (int dataIndex = 0; dataIndex < dataItems.length; dataIndex++) {
        final dataItem = dataItems[dataIndex];
        final itemTitle = dataItem['title'] as String? ?? 'Item ${dataIndex + 1}';
        final refImage = dataItem['ref_image'] as String?;
        final expectedCount = (dataItem['count'] as num?)?.toInt() ?? 0;
        final itemIndex = dataItem['index']?.toString() ?? dataIndex.toString();

        // Check completion status from project data
        bool isCompleted = false;
        if (stepProjectDataField != null) {
          Map<String, dynamic>? projectDataItem;

          // Handle both List and Map formats for project data
          if (stepProjectDataField is List) {
            final listIndex = int.tryParse(itemIndex) ?? dataIndex;
            if (listIndex < stepProjectDataField.length) {
              projectDataItem = stepProjectDataField[listIndex] as Map<String, dynamic>?;
            }
          } else if (stepProjectDataField is Map) {
            // Try both the index from dataItem and the dataIndex
            projectDataItem = stepProjectDataField[itemIndex] as Map<String, dynamic>?;
            if (projectDataItem == null) {
              projectDataItem = stepProjectDataField[dataIndex.toString()] as Map<String, dynamic>?;
            }
          }

          if (projectDataItem != null) {
            final images = projectDataItem['images'] as List<dynamic>?;
            final uploadedCount = images?.where((e) => e != null && e.toString().isNotEmpty).length ?? 0;
            // Item is completed if uploaded count meets or exceeds expected count
            isCompleted = expectedCount > 0 && uploadedCount >= expectedCount;
          }
        }

        items.add(ChecklistItem(title: itemTitle, isCompleted: isCompleted, refImage: refImage));
      }

      if (items.isNotEmpty) {
        sections.add(
          ChecklistSection(
            title: stepTitle,
            iconPath: _getIconPathForStep(stepTitle),
            isExpanded: stepIndex == 0, // Expand first section by default
            items: items,
          ),
        );
      }
    }

    return sections;
  }

  @override
  void initState() {
    super.initState();
    // Set loading state immediately when drawer opens (if data not already loaded)
    final controller = Get.find<InstallationStepsController>();
    
    // If data is not loaded, set loading state immediately to show shimmer
    if (controller.installFormData == null && !controller.isLoadingChecklistData.value) {
      controller.isLoadingChecklistData.value = true;
      controller.update(['checkList']);
    }
    
    // Load data after drawer opens (non-blocking)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataAndBuildSections();
    });
  }

  void _loadDataAndBuildSections() async {
    final controller = Get.find<InstallationStepsController>();
    
    // If data is already loaded, build sections immediately
    if (controller.installFormData != null) {
      controller.isLoadingChecklistData.value = false;
      _buildSectionsFromController(controller);
      controller.update(['checkList']);
      return;
    }
    
    // Otherwise, load data first (this will set loading state), then build sections
    await controller.loadChecklistData();
    if (mounted) {
      _buildSectionsFromController(controller);
    }
  }

  void _buildSectionsFromController(InstallationStepsController controller) {
    if (controller.installFormData != null) {
      final firebaseData = controller.installFormData!['steps'] as List<dynamic>?;
      if (firebaseData != null && mounted) {
        setState(() {
          sections = firebaseData.map((e) => SectionModel.fromJson(e)).toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          width: widget.isDialog ? (isMobile ? screenWidth - 32 : 500) : 500,
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: widget.isDialog ? BorderRadius.circular(24) : null,
            boxShadow: widget.isDialog
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 4))]
                : const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(-2, 0))],
          ),
          child: Column(
            children: [
              // Header with close button and title
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // Close button
                    GetBuilder<InstallationStepsController>(
                      id: 'drawer',
                      builder: (closeController) {
                        return InkWell(
                          onTap: () {
                            closeController.isChecklistDrawerOpen = false;
                            closeController.update(['drawer']);
                            if (widget.isDialog == true) {
                              context.pop();
                            }
                          },
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.whiteColor,
                                border: Border.all(color: AppColors.greyADB9BD),
                              ),
                              child: const Icon(Icons.close, size: 20, color: AppColors.black002432),
                            ),
                          ),
                        );
                      },
                    ),
                    const Gap(16),
                    // Title
                    Expanded(
                      child: Center(
                        child: AppText('Checklist', style: AppTextStyle.extraBold44(color: AppColors.black002432)),
                      ),
                    ),
                  ],
                ),
              ),

              // Checklist sections with data from controller
              Expanded(
                child: GetBuilder<InstallationStepsController>(
                  id: 'checkList',
                  builder: (controller) {
                    // Rebuild sections when controller data updates (if sections are empty)
                    if (controller.installFormData != null && sections.isEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _buildSectionsFromController(controller);
                      });
                    }

                    // Show loading indicator while data is loading OR if data is null (initial state)
                    if (controller.isLoadingChecklistData.value || controller.installFormData == null) {
                      return buildShimmerList();
                    }

                    // Show loading if sections are empty but data exists (still building)
                    if (sections.isEmpty) {
                      return buildShimmerList();
                    }

                    // Only show "No data found" if loading is complete and data is still null
                    if (controller.installFormData == null && !controller.isLoadingChecklistData.value) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: AppText(
                            'No checklist data found',
                            style: AppTextStyle.medium14(color: AppColors.grey78797A),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: sections.length,
                      itemBuilder: (context, index) {
                        SectionModel section = sections[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.whiteF5F5F5,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(22),
                              topLeft: Radius.circular(22),
                              bottomRight: Radius.circular(section.isOpen ? 22 : 0),
                              bottomLeft: Radius.circular(section.isOpen ? 22 : 0),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Section header
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    sections[index].isOpen = !sections[index].isOpen;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      const Gap(12),
                                      // Section title
                                      Expanded(
                                        child: Text(
                                          section.title ?? "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyle.semiBold16(color: AppColors.black002432),
                                        ),
                                      ),
                                      Gap(15),
                                      // Chevron icon
                                      Icon(
                                        sections[index].isOpen
                                            ? Icons.keyboard_arrow_down
                                            : Icons.keyboard_arrow_up,
                                        color: AppColors.black002432,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              if (sections[index].isOpen)
                                ...section.data.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        // Thumbnail icon (reference image or default) - clickable
                                        InkWell(
                                          onTap: () {},
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: Container(
                                              width: 45,
                                              height: 45,
                                              decoration: BoxDecoration(
                                                color: AppColors.greyADB9BD.withValues(alpha: 0.1),
                                                border: Border.all(color: AppColors.black002432, width: 3),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: item.refImage != null && item.refImage!.isNotEmpty
                                                  ? ClipRRect(
                                                      borderRadius: BorderRadius.circular(9),
                                                      child: Image.network(
                                                        item.refImage!,
                                                        width: 45,
                                                        height: 45,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return Image.asset(
                                                            Assets.images.loginImage.path,
                                                            fit: BoxFit.cover,
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  : Image.asset(Assets.images.loginImage.path, fit: BoxFit.cover),
                                            ),
                                          ),
                                        ),
                                        const Gap(12),
                                        // Item title
                                        Expanded(
                                          child: AppText(
                                            item.title ?? '',
                                            style: AppTextStyle.regular16(color: AppColors.black002432),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              item.isFilled = !item.isFilled;
                                            });
                                          },
                                          child: item.isFilled
                                              ? Icon(Icons.check_circle_sharp, color: AppColors.primaryColor)
                                              : Icon(
                                                  Icons.check_circle_outline_outlined,
                                                  color: AppColors.greyADB9BD,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: 4, // number of shimmer blocks
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
            child: Column(
              children: [
                // --- HEADER SHIMMER ---
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle),
                      ),
                    ],
                  ),
                ),

                // --- 3 ITEMS SHIMMER ---
                ...List.generate(
                  1,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        // Thumbnail
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title
                        Expanded(
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Check icon
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
