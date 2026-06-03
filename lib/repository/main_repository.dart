import 'dart:typed_data';
import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:heimwatt/app/services/api_services.dart';
import 'package:heimwatt/app/theme/api_endpoints.dart';

abstract class BaseRepository {
  final ApiClient apiClient;

  BaseRepository({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();
}

class MainRepository extends BaseRepository {
  MainRepository({super.apiClient});

  Future<void> updateLocationById({
    Function(dynamic data)? onSuccess,
    Function(dynamic error)? onError,
    required String dealId,
    required Map<String, dynamic> body,
  }) async {
    await apiClient.request(
      url: ApiEndpoints.updateLocation(dealId),
      type: RequestType.patch,
      onSuccess: onSuccess,
      onError: onError,
      body: body,
    );
  }

  Future<void> getDealById({
    Function(dynamic data)? onSuccess,
    Function(dynamic error)? onError,
    required String dealId,
  }) async {
    await apiClient.request(
      url: ApiEndpoints.getDealById(dealId),
      type: RequestType.get,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> getContactById({
    Function(dynamic data)? onSuccess,
    Function(dynamic error)? onError,
    required String contactId,
  }) async {
    await apiClient.request(
      url: ApiEndpoints.getContactDetailsBy(contactId),
      type: RequestType.get,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> dealSearch({
    Function(dynamic data)? onSuccess,
    Function(dynamic error)? onError,

  }) async {
    await apiClient.request(
      url: ApiEndpoints.dealSearch,
      type: RequestType.get,
      onSuccess: onSuccess,
      onError: onError,

    );
  }

  Future<void> uploadPdfBytes({
    Function(dynamic data)? onSuccess,
    Function(dynamic error)? onError,
    required Map<String, dynamic> body,
       Uint8List? pdfBytes,
    String fileName = "document.pdf",
  }) async
  {
    // Convert nested objects to JSON strings for form data
    final formDataMap = <String, dynamic>{};
    
    for (var entry in body.entries) {
      if (entry.value is Map) {
        // Convert nested Map to JSON string (as required by HubSpot API)
        formDataMap[entry.key] = jsonEncode(entry.value);
      } else {
        formDataMap[entry.key] = entry.value;
      }
    }
    
    final formData = dio.FormData.fromMap(formDataMap);

    if (pdfBytes != null) {
      formData.files.add(
        MapEntry(
          'file',
          dio.MultipartFile.fromBytes(
            pdfBytes,
            filename: fileName,
            contentType: dio.DioMediaType.parse('application/pdf'),
          ),
        ),
      );
    }

    await apiClient.request(
      url: ApiEndpoints.uploadFile,
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
      body: body,
      formData: formData,
    );
  }


  Future<void> createNote({
    Function(dynamic data)? onSuccess,
    Function(dynamic error)? onError,
    required Map<String, dynamic> body,
  }) async {
    await apiClient.request(
      url: ApiEndpoints.createNote,
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
      body: body,
    );
  }

  Future<void> linkFileToProperty({
    Function(dynamic data)? onSuccess,
    Function(dynamic error)? onError,
    required Map<String, dynamic> body,
    required String dealId,
  }) async {
    await apiClient.request(
      url: ApiEndpoints.linkFileToProperty(dealId),
      type: RequestType.patch,
      onSuccess: onSuccess,
      onError: onError,
      body: body,
    );
  }

  Future<void> uploadDoc({
    Function(dynamic data)? onSuccess,
    Function(dynamic error)? onError,
    required Map<String, dynamic> body,    required String dealId,

  }) async {
    await apiClient.request(
      url: ApiEndpoints.uploadDocument(dealId),
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
      body: body,
    );
  }
}
