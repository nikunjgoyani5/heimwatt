import 'dart:developer';
import 'package:dio/dio.dart' as dio;
import 'package:heimwatt/app/exception/app_exception.dart';
import 'package:heimwatt/app/utils/pref_service.dart';

import '../utils/app_functions.dart';

enum RequestType { get, post, put, patch, delete }

class ApiClient {
  final dio.Dio _dio;

  ApiClient({dio.BaseOptions? options})
    : _dio = dio.Dio(
        options ??
            dio.BaseOptions(
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              headers: {'Content-Type': 'application/json'},
            ),
      );

  Future request({
    required String url,
    required RequestType type,
    Map<String, dynamic>? body,
    dio.FormData? formData,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Function(dynamic data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    log("URL: $url");
    if (body != null) {
      log("Request: $body");
    }
    if (formData != null) {
      log("Request: $formData");
    }
    if (queryParams != null) {
      log("queryParams: $queryParams");
    }

    try {
      final token = PrefService.getString(PrefService.accessToken);
        if (token.isNotEmpty) {
        log("Token:\n$token");
      }

      final requestHeaders = <String, String>{
        'Content-Type': formData == null ? 'application/json' : 'multipart/form-data',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        ...?headers,
      };

      _dio.options.headers.clear();
      _dio.options.headers.addAll(requestHeaders);

      dio.Response response;

      switch (type) {
        case RequestType.get:
          response = await _dio.get(url, queryParameters: queryParams);
          break;
        case RequestType.post:
          response = await _dio.post(url, data: formData ?? body, queryParameters: queryParams);
          break;
        case RequestType.put:
          response = await _dio.put(url, data: formData ?? body, queryParameters: queryParams);
          break;
        case RequestType.patch:
          response = await _dio.patch(url, data: body, queryParameters: queryParams);
          break;
        case RequestType.delete:
          response = await _dio.delete(url, data: body, queryParameters: queryParams);
          break;
      }

      log("Response: ${response.data}");
      log("Status Code: ${response.statusCode}");

      final statusCode = response.statusCode ?? 0;

      if (statusCode >= 200 && statusCode < 300) {
        onSuccess?.call(response.data);
      } else {
        log("HTTP Error Status: $statusCode");
        onError?.call(AppException(message: 'done'));
      }
    } on dio.DioException catch (e) {
      AppException exception = ExceptionHandler.handleDioException(e);
      log("Original error: ${e.toString()}");
      // AppFunctions.showToast(message: 'Something went wrong');
      onError?.call(exception);
    } catch (e) {
      AppException exception = ExceptionHandler.handleGenericException(e);
      log("Original error11: ${e.toString()}");
      onError?.call(exception);
    }
  }
}
