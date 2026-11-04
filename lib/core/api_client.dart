import 'package:dio/dio.dart';
import 'token_storage.dart';

/// Central REST API Client powered by Dio with automatic JWT Bearer token attachment,
/// timeout handling, and unified error handling.
class ApiClient {
  static const String defaultBaseUrl = 'https://dummyjson.com';

  final Dio dio;
  final TokenStorage tokenStorage;
  final String baseUrl;

  ApiClient({
    TokenStorage? tokenStorage,
    String? baseUrl,
  })  : tokenStorage = tokenStorage ?? TokenStorage(),
        baseUrl = baseUrl ?? defaultBaseUrl,
        dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? defaultBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach JWT token to Authorization header if present
          final token = await tokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          // If 401 Unauthorized, token might be invalid or expired
          if (error.response?.statusCode == 401) {
            // Can clear token or trigger session expiry notification
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Perform GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Perform POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Perform PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Perform DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Convert DioException into friendly ApiException
  ApiException _parseDioError(DioException error) {
    String message = 'An unexpected error occurred. Please try again.';
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timed out. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        final responseData = error.response?.data;
        if (responseData is Map && responseData['message'] != null) {
          message = responseData['message'].toString();
        } else if (responseData is String && responseData.isNotEmpty) {
          message = responseData;
        } else {
          switch (statusCode) {
            case 400:
              message = 'Bad request. Please verify your data.';
              break;
            case 401:
              message = 'Invalid credentials or session expired. Please log in again.';
              break;
            case 403:
              message = 'Access forbidden. You do not have permission.';
              break;
            case 404:
              message = 'Resource not found.';
              break;
            case 500:
              message = 'Server error. Please try again later.';
              break;
            default:
              message = 'Server returned error status code: $statusCode';
          }
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'Cannot connect to server. Please check your internet connection.';
        break;
      default:
        if (error.message != null && error.message!.isNotEmpty) {
          message = error.message!;
        }
    }

    return ApiException(message: message, statusCode: statusCode);
  }
}

/// Custom Exception class for unified error handling
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

