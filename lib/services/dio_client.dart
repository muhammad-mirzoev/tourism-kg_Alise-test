import 'package:dio/dio.dart';

class DioClient {
  static const String baseUrl = "http://127.0.0.1:8000/places";
  static final Dio nn_dio = _createDio();
  static Dio _createDio() {
    Dio dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print(
            "--> [DIO] REQUEST[${options.method}] => PATH: ${options.path}",
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            "<-- [DIO] RESPONSE[${response.statusCode}] => PATH: "
            "${response.requestOptions.path}",
          );
          return handler.next(response);
        },
        onError: (DioException dio_ex, handler) {
          print(
            "[DIO] ERROR[${dio_ex.response?.statusCode}] => MESSAGE: ${dio_ex.message}",
          );
          return handler.next(dio_ex);
        },
      ),
    );
    return dio;
  }

  static Dio get instance => nn_dio;
  static Dio getDio() => nn_dio;
}
