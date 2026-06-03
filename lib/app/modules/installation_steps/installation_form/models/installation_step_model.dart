// class InstallationStep {
//   final String? title;
//   final String? des;
//   final String? infoVideo;
//   final List<StepDataItem>? data;
//
//   InstallationStep({
//     this.title,
//     this.des,
//     this.infoVideo,
//     this.data,
//   });
//
//   factory InstallationStep.fromMap(Map<String, dynamic> map) {
//     List<StepDataItem>? dataList;
//     if (map['data'] != null) {
//       final dataValue = map['data'];
//
//       if (dataValue is List) {
//         // Handle array format: [{...}, {...}]
//         dataList = dataValue.asMap().entries.map((entry) {
//           final index = entry.key.toString();
//           final value = entry.value;
//           if (value is Map<String, dynamic>) {
//             return StepDataItem.fromMap(value, index);
//           }
//           // If value is not a map, return a default item
//           return StepDataItem(index: index);
//         }).toList();
//       } else if (dataValue is Map) {
//         // Handle map format: {"0": {...}, "1": {...}}
//         final dataMap = dataValue as Map;
//         dataList = dataMap.entries.map((entry) {
//           final index = entry.key.toString();
//           final value = entry.value;
//           if (value is Map<String, dynamic>) {
//             return StepDataItem.fromMap(value, index);
//           }
//           // If value is not a map, return a default item
//           return StepDataItem(index: index);
//         }).toList();
//         // Sort by index to maintain order
//         dataList.sort((a, b) {
//           final aIndex = int.tryParse(a.index) ?? 0;
//           final bIndex = int.tryParse(b.index) ?? 0;
//           return aIndex.compareTo(bIndex);
//         });
//       }
//     }
//
//     return InstallationStep(
//       title: map['title'] as String?,
//       des: map['des'] as String?,
//       infoVideo: map['info_video'] as String?,
//       data: dataList,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'title': title,
//       'des': des,
//       'info_video': infoVideo,
//       'data': data?.asMap().map((index, item) => MapEntry(index.toString(), item.toMap())),
//     };
//   }
// }
//
// class StepDataItem {
//   final String index;
//   final int? count;
//   final List<String>? images;
//   final String? refImage;
//   final String? title;
//
//   StepDataItem({
//     required this.index,
//     this.count,
//     this.images,
//     this.refImage,
//     this.title,
//   });
//
//   factory StepDataItem.fromMap(Map<String, dynamic> map, String index) {
//     List<String>? imagesList;
//     if (map['images'] != null) {
//       final imagesData = map['images'];
//       if (imagesData is List) {
//         imagesList = imagesData.map((e) => e.toString()).toList();
//       }
//     }
//
//     return StepDataItem(
//       index: index,
//       count: map['count'] as int?,
//       images: imagesList,
//       refImage: map['ref_image'] as String?,
//       title: map['title'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'count': count,
//       'images': images,
//       'ref_image': refImage,
//       'title': title,
//     };
//   }
// }
//
class InstallationStep {
  final String? title;
  final String? des;
  final String? infoVideo;
  final List<StepDataItem>? data;

  InstallationStep({
    this.title,
    this.des,
    this.infoVideo,
    this.data,
  });

  factory InstallationStep.fromMap(Map<String, dynamic> map) {
    final List<StepDataItem> dataList = [];
    final dynamic rawData = map["data"];

    // Accept both array and map formats coming from Firestore:
    // - List:  [{...}, {...}]
    // - Map:   {"0": {...}, "1": {...}}
    if (rawData is List) {
      rawData.asMap().forEach((index, value) {
        if (value is Map<String, dynamic>) {
          dataList.add(StepDataItem.fromFirebase(value, index.toString()));
        } else {
          dataList.add(StepDataItem(index: index.toString()));
        }
      });
    } else if (rawData is Map) {
      Map<String, dynamic> dataMap = Map<String, dynamic>.from(rawData);

      dataMap.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          dataList.add(StepDataItem.fromFirebase(value, key));
        }
      });

      // Preserve order by index key when stored as map
      dataList.sort((a, b) {
        final ai = int.tryParse(a.index) ?? 0;
        final bi = int.tryParse(b.index) ?? 0;
        return ai.compareTo(bi);
      });
    }

    return InstallationStep(
      title: map['title'],
      des: map['des'],
      infoVideo: map['info_video'],
      data: dataList,
    );
  }
}
class StepDataItem {
  final String index;
  final int? count;
  final List<String>? images;
  final String? refImage;
  final String? title;
  final String? infoVideo;

  StepDataItem({
    required this.index,
    this.count,
    this.images,
    this.refImage,
    this.title,
    this.infoVideo,
  });

  /// FIXED: Actual valid parser for your current API format
  factory StepDataItem.fromFirebase(Map<String, dynamic> map, String index) {
    // -------------------------
    // 1. Parse IMAGES (List<String>)
    // -------------------------
    List<String> imageUrls = [];

    if (map["images"] != null && map["images"] is List) {
      final rawList = map["images"] as List;
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          final url = item["image"] ?? item["imageUrl"] ?? item["url"];
          if (url != null && url.toString().isNotEmpty) {
            imageUrls.add(url.toString());
          }
        } else if (item is String && item.isNotEmpty) {
          imageUrls.add(item);
        }
      }
    }

    // -------------------------
    // 2. Build model safely
    // -------------------------
    return StepDataItem(
      index: index,
      title: map["title"],
      count: map["count"],
      refImage: map["ref_image"],
      infoVideo: map["info_video"],
      images: imageUrls,
    );
  }
}

