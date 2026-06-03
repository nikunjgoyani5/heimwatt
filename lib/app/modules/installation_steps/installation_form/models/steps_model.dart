class SectionModel {
  final String? title;
  final String? des;
  final String? infoVideo;
  final List<SectionDataModel> data;
   bool isOpen;


  SectionModel({
    this.title,
    this.des,
    this.infoVideo,
    this.isOpen = false,

    required this.data,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      title: json['title'],
      des: json['des'],
      infoVideo: json['info_video'],
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => SectionDataModel.fromJson(e))
          .toList() ??
          [],
    );
  }
}
class SectionDataModel {
  final String? title;
  final String? refImage;
  final int? count;
  final List<String> images;
   bool isFilled;

  SectionDataModel({
    this.title,
    this.refImage,
    this.count,
    required this.images,
     this.isFilled= false,
  });

  factory SectionDataModel.fromJson(Map<String, dynamic> json) {
    return SectionDataModel(
      title: json['title'],
      refImage: json['ref_image'],
      count: json['count'],
      images: _parseImages(json['images']),
    );
  }

  // Support both legacy `List<String>` and new `List<Map>` with `{image, name}`.
  static List<String> _parseImages(dynamic raw) {
    final List<String> result = [];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map<String, dynamic>) {
          final url = item['image'] ?? item['imageUrl'] ?? item['url'];
          if (url != null && url.toString().isNotEmpty) {
            result.add(url.toString());
          }
        } else if (item is String && item.isNotEmpty) {
          result.add(item);
        }
      }
    }
    return result;
  }
}
