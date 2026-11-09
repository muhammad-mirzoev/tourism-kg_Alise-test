import 'package:dio/dio.dart';

import 'dio_client.dart';

class HotelApiService {
  final Dio _dio = DioClient.getDio();

  Future<List<dynamic>> getAllHotels() async {
    try {
      final response = await _dio.get('/places');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to fetch data: $e");
    }
  }
}
