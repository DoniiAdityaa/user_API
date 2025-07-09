import 'package:api/models/user_model.dart';
import 'package:dio/dio.dart';

class UserRepository {
  // Base URL dari mock API
  final String _baseUrl = "https://686b3968e559eba90871c627.mockapi.io/api/v1";
  late final Dio _dio;

  UserRepository() {
    _dio = Dio();
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);
    
    // Add interceptor for logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => print('[DIO] $object'),
    ));
  }

  // --- CONNECTION TEST ---
  Future<bool> testConnection() async {
    try {
      print('[TEST] Testing connection to: $_baseUrl/users');
      final response = await _dio.get('$_baseUrl/users', 
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      print('[TEST] Connection successful: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('[TEST] Connection failed: $e');
      if (e is DioException) {
        print('[TEST] DioException type: ${e.type}');
        print('[TEST] DioException message: ${e.message}');
        print('[TEST] DioException error: ${e.error}');
      }
      return false;
    }
  }

  // --- ALTERNATIVE CONNECTION TEST WITH FALLBACK ---
  Future<void> testConnectionDetails() async {
    print('[DEBUG] Starting detailed connection test...');
    
    try {
      // Test with original URL
      final response = await _dio.get('$_baseUrl/users',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      print('[DEBUG] Original URL success: ${response.statusCode}');
    } catch (e) {
      print('[DEBUG] Original URL failed: $e');
      
      // Try with different test APIs
      final testUrls = [
        'https://httpbin.org/get',
        'https://jsonplaceholder.typicode.com/posts/1',
        'https://api.github.com',
        'https://mockapi.io',
      ];
      
      for (final url in testUrls) {
        try {
          final testResponse = await _dio.get(url);
          print('[DEBUG] $url reachable: ${testResponse.statusCode}');
          break;
        } catch (e2) {
          print('[DEBUG] $url failed: $e2');
        }
      }
    }
  }

  // --- READ ALL ---
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _dio.get("$_baseUrl/users");
      // Mapping dari List<dynamic> menjadi List<UserModel>
      return (response.data as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            throw Exception('Connection timeout - please check your internet connection');
          case DioExceptionType.receiveTimeout:
            throw Exception('Receive timeout - server is taking too long to respond');
          case DioExceptionType.connectionError:
            throw Exception('Connection error - please check your internet connection');
          case DioExceptionType.badResponse:
            throw Exception('Server error: ${e.response?.statusCode}');
          default:
            throw Exception('Network error: ${e.message}');
        }
      }
      throw Exception('Failed to retrieve user data: $e');
    }
  }

  // --- READ ONE ---
  Future<UserModel> getUserById(String id) async {
    try {
      final response = await _dio.get('$_baseUrl/users/$id');
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Gagal mengambil detail pengguna: $e');
    }
  }

  // --- CREATE ---
  Future<UserModel> createUser(String name, String address) async {
    try {
      // Siapkan data yang akan dikirim
      final data = {
        'name': name,
        'address': address,
        // API biasanya akan membuat createdAt dan avatar otomatis
        'createdAt': DateTime.now().toIso8601String(),
        'avatar':
            'https://i.pravatar.cc/150?u=${DateTime.now().millisecondsSinceEpoch}',
      };

      // Mengirim request POST untuk membuat data baru
      final response = await _dio.post('$_baseUrl/users', data: data);

      // Kembalikan data user baru dari respons server
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Gagal membuat pengguna: $e');
    }
  }

  // --- UPDATE ---
  Future<UserModel> updateUser(
    String id,
    String newName,
    String newAddress,
  ) async {
    try {
      final data = {'name': newName, 'address': newAddress};

      // Mengirim request PUT untuk memperbarui data
      final response = await _dio.put('$_baseUrl/users/$id', data: data);

      // Kembalikan data user yang sudah diupdate dari respons server
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Gagal memperbarui pengguna: $e');
    }
  }

  // --- DELETE ---
  Future<void> deleteUserById(String id) async {
    try {
      // Mengirim request DELETE untuk menghapus data
      final response = await _dio.delete('$_baseUrl/users/$id');

      // Cek jika status code tidak sukses
      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus pengguna.');
      }
    } catch (e) {
      throw Exception('Gagal menghapus pengguna: $e');
    }
  }
}
