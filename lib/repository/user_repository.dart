import 'package:api/models/user_model.dart';
import 'package:api/service/database_service.dart';
import 'package:dio/dio.dart';

class UserRepository {
  // Base URL dari mock API
  final String _baseUrl = "https://686b3968e559eba90871c627.mockapi.io/api/v1";
  late final Dio _dio;
  final DatabaseService _databaseService = DatabaseService.instance;

  UserRepository() {
    _dio = Dio();
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);

    // Add interceptor for logging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('[DIO] $object'),
      ),
    );
  }

  // --- CONNECTION TEST ---
  Future<bool> testConnection() async {
    try {
      print('[TEST] Testing connection to: $_baseUrl/users');
      final response = await _dio.get(
        '$_baseUrl/users',
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
      final response = await _dio.get(
        '$_baseUrl/users',
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
      print('[DATA] Mencoba mengambil data dari API...');
      final response = await _dio.get("$_baseUrl/users");
      final remoteUsers =
          (response.data as List)
              .map((json) => UserModel.fromJson(json))
              .toList();

      print(
        '[DATA] Berhasil! Menyimpan ${remoteUsers.length} data ke DB lokal...',
      );
      await _databaseService.cacheAllUsers(remoteUsers);
      return remoteUsers;
    } catch (e) {
      print('[DATA] Gagal mengambil dari API, mengambil dari DB lokal...');
      final localUsers = await _databaseService.readAllUsers();
      return localUsers;
    }
  }

  // --- READ ONE ---
  Future<UserModel> getUserById(String id) async {
    try {
      final response = await _dio.get('$_baseUrl/users/$id');
      return UserModel.fromJson(response.data);
    } catch (e) {
      print('Failed to get user by ID online, trying offline. Error: $e');

      // Try to get from local database
      final localUser = await _databaseService.getUserById(id);
      if (localUser != null) {
        return localUser;
      }

      throw Exception('Gagal mengambil detail pengguna: $e');
    }
  }

  // Create Users
  Future<UserModel> createUser(String name, String address) async {
    final avatarUrl =
        'https://i.pravatar.cc/150?u=${DateTime.now().millisecondsSinceEpoch}';
    final data = {
      'name': name,
      'address': address,
      'createdAt': DateTime.now().toIso8601String(),
      'avatar': avatarUrl,
    };

    try {
      final response = await _dio.post('$_baseUrl/users', data: data);
      final newUser = UserModel.fromJson(response.data);
      await _databaseService.createUser(newUser);
      return newUser;
    } catch (e) {
      print('Failed to create user online, saving offline. Error: $e');
      final offlineUser = UserModel(
        id: DateTime.now().toIso8601String(), // Use timestamp as ID
        name: name,
        address: address,
        createdAt: DateTime.now(),
        avatar: avatarUrl,
      );
      await _databaseService.createUser(offlineUser);
      return offlineUser;
    }
  }

  Future<UserModel> updateUser(
    String id,
    String newName,
    String newAddress,
  ) async {
    try {
      final data = {'name': newName, 'address': newAddress};

      final response = await _dio.put('$_baseUrl/users/$id', data: data);
      final updatedUser = UserModel.fromJson(response.data);
      await _databaseService.updateUser(updatedUser);
      return updatedUser;
    } catch (e) {
      print('Failed to update user online, updating offline. Error: $e');

      // Get the existing user from local database
      final localUsers = await _databaseService.readAllUsers();
      final existingUser = localUsers.firstWhere((user) => user.id == id);

      // Create updated user with new data
      final offlineUpdatedUser = UserModel(
        id: existingUser.id,
        name: newName,
        address: newAddress,
        createdAt: existingUser.createdAt,
        avatar: existingUser.avatar,
      );

      await _databaseService.updateUser(offlineUpdatedUser);
      return offlineUpdatedUser;
    }
  }

  // --- DELETE ---
  Future<void> deleteUserById(String id) async {
    try {
      await _dio.delete('$_baseUrl/users/$id');
      await _databaseService.deleteUser(id);
    } catch (e) {
      print('Failed to delete user online, deleting offline. Error: $e');
      await _databaseService.deleteUser(id);
    }
  }
}
