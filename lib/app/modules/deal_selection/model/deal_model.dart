// To parse this JSON data, do
//
//     final dealModel = dealModelFromJson(jsonString);

import 'dart:convert';

DealModel dealModelFromJson(String str) => DealModel.fromJson(json.decode(str));

String dealModelToJson(DealModel data) => json.encode(data.toJson());

class DealModel {
  bool? success;
  List<DealData>? data;
  Meta? meta;

  DealModel({
    this.success,
    this.data,
    this.meta,
  });

  factory DealModel.fromJson(Map<String, dynamic> json) => DealModel(
    success: json["success"],
    data: json["data"] == null ? [] : List<DealData>.from(json["data"]!.map((x) => DealData.fromJson(x))),
    meta: json["meta"] == null ? null : Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "meta": meta?.toJson(),
  };
}

class DealData {
  String? id;
  String? name;
  String? stage;
  String? stageLabel;
  String? projectType;
  String? projectTypeLabel;
  Address? address;
  bool? loader;

  DealData({
    this.id,
    this.name,
    this.stage,
    this.stageLabel,
    this.projectType,
    this.projectTypeLabel,
    this.address,
    this.loader = false,
  });

  factory DealData.fromJson(Map<String, dynamic> json) => DealData(
    id: json["id"],
    name: json["name"],
    stage: json["stage"],
    stageLabel: json["stageLabel"],
    projectType: json["projectType"],
    projectTypeLabel: json["projectTypeLabel"],
    address: json["address"] == null ? null : Address.fromJson(json["address"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "stage": stage,
    "stageLabel": stageLabel,
    "projectType": projectType,
    "projectTypeLabel": projectTypeLabel,
    "address": address?.toJson(),
  };
}

class Address {
  String? street;
  String? zip;
  String? city;

  Address({
    this.street,
    this.zip,
    this.city,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    street: json["street"],
    zip: json["zip"],
    city: json["city"],
  );

  Map<String, dynamic> toJson() => {
    "street": street,
    "zip": zip,
    "city": city,
  };
}

class Meta {
  String? correlationId;
  String? timestamp;

  Meta({
    this.correlationId,
    this.timestamp,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    correlationId: json["correlationId"],
    timestamp: json["timestamp"],
  );

  Map<String, dynamic> toJson() => {
    "correlationId": correlationId,
    "timestamp": timestamp,
  };
}
