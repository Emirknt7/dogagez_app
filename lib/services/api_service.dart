import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Backend URL'ini buraya yazın
  // Android emülatör için 10.0.2.2 kullanın, gerçek cihaz için bilgisayarınızın IP'sini
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android emülatör için
  // static const String baseUrl = 'http://192.168.1.100:5000/api'; // Gerçek cihaz için (IP'nizi yazın)
  // static const String baseUrl = 'https://your-domain.com/api'; // Production için
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Token yönetimi
  String? _token;
  
  // Token'ı alır
  Future<String?> getToken() async {
    if (_token != null) return _token;
    
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  // Token'ı kaydeder
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Token'ı siler
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // HTTP headers
  Future<Map<String, String>> get headers async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Genel HTTP istekleri
  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? customHeaders,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final requestHeaders = customHeaders ?? await headers;
      
      // Debug için URL'yi yazdır
      print('API Request: $method $url');
      if (body != null) print('Request Body: $body');
      
      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: requestHeaders).timeout(
            const Duration(seconds: 30),
          );
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: requestHeaders,
            body: body != null ? json.encode(body) : null,
          ).timeout(const Duration(seconds: 30));
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: requestHeaders,
            body: body != null ? json.encode(body) : null,
          ).timeout(const Duration(seconds: 30));
          break;
        case 'DELETE':
          response = await http.delete(url, headers: requestHeaders).timeout(
            const Duration(seconds: 30),
          );
          break;
        default:
          throw Exception('Desteklenmeyen HTTP metodu: $method');
      }

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw ApiException(
          message: responseData['message'] ?? 'Bilinmeyen hata',
          statusCode: response.statusCode,
          errors: responseData['errors'],
        );
      }
    } on SocketException catch (e) {
      print('Socket Exception: $e');
      throw ApiException(
        message: 'Sunucuya bağlanılamıyor. Lütfen internet bağlantınızı kontrol edin.',
        statusCode: 0,
      );
    } on HttpException catch (e) {
      print('HTTP Exception: $e');
      throw ApiException(
        message: 'HTTP hatası: ${e.message}',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      print('Format Exception: $e');
      throw ApiException(
        message: 'Sunucu yanıtı işlenirken hata oluştu',
        statusCode: 0,
      );
    } catch (e) {
      print('General Exception: $e');
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Beklenmeyen hata: ${e.toString()}',
        statusCode: 0,
      );
    }
  }

  // =================== AUTH ENDPOINTS ===================
  
  // Kullanıcı kaydı
  Future<AuthResponse> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _makeRequest('POST', '/auth/register', body: {
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    });

    final authResponse = AuthResponse.fromJson(response);
    await setToken(authResponse.token);
    return authResponse;
  }

  // Kullanıcı girişi
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _makeRequest('POST', '/auth/login', body: {
      'email': email,
      'password': password,
    });

    final authResponse = AuthResponse.fromJson(response);
    await setToken(authResponse.token);
    return authResponse;
  }

  // Şifre sıfırlama isteği
  Future<String> forgotPassword({required String email}) async {
    final response = await _makeRequest('POST', '/auth/forgot-password', body: {
      'email': email,
    });

    return response['message'] ?? 'Şifre sıfırlama bağlantısı gönderildi';
  }

  // Şifre sıfırlama
  Future<AuthResponse> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _makeRequest('POST', '/auth/reset-password/$token', body: {
      'password': password,
      'confirmPassword': confirmPassword,
    });

    final authResponse = AuthResponse.fromJson(response);
    await setToken(authResponse.token);
    return authResponse;
  }

  // Mevcut kullanıcı bilgilerini getir
  Future<User> getCurrentUser() async {
    final response = await _makeRequest('GET', '/auth/me');
    return User.fromJson(response['data']);
  }

  // Çıkış yap
  Future<void> logout() async {
    await _makeRequest('POST', '/auth/logout');
    await clearToken();
  }

  // =================== USER ENDPOINTS ===================

  // Profil bilgilerini getir
  Future<User> getProfile() async {
    final response = await _makeRequest('GET', '/users/profile');
    return User.fromJson(response['data']);
  }

  // Profil bilgilerini güncelle
  Future<User> updateProfile({
    String? name,
    String? username,
    String? email,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (username != null) body['username'] = username;
    if (email != null) body['email'] = email;

    final response = await _makeRequest('PUT', '/users/profile', body: body);
    return User.fromJson(response['data']);
  }

  // Şifre güncelle
  Future<String> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _makeRequest('PUT', '/users/password', body: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });

    return response['message'] ?? 'Şifre başarıyla güncellendi';
  }

  // Kullanıcı ayarlarını getir
  Future<UserPreferences> getSettings() async {
    final response = await _makeRequest('GET', '/users/settings');
    return UserPreferences.fromJson(response['data']);
  }

  // Kullanıcı ayarlarını güncelle
  Future<UserPreferences> updateSettings({
    bool? notifications,
    bool? darkMode,
  }) async {
    final body = <String, dynamic>{};
    if (notifications != null) body['notifications'] = notifications;
    if (darkMode != null) body['darkMode'] = darkMode;

    final response = await _makeRequest('PUT', '/users/settings', body: body);
    return UserPreferences.fromJson(response['data']);
  }

  // Hesabı deaktif et
  Future<String> deactivateAccount() async {
    final response = await _makeRequest('DELETE', '/users/account');
    await clearToken();
    return response['message'] ?? 'Hesap başarıyla deaktif edildi';
  }

  // =================== HEALTH CHECK ===================
  
  // Sunucu durumunu kontrol et
  Future<bool> checkServerHealth() async {
    try {
      final healthUrl = baseUrl.replaceAll('/api', '/health');
      print('Health check URL: $healthUrl');
      
      final response = await http.get(
        Uri.parse(healthUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      print('Health check response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Health check error: $e');
      return false;
    }
  }

  // Basit bağlantı testi
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/test'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200 || response.statusCode == 404; // 404 da OK, en azından sunucuya ulaşıyor
    } catch (e) {
      print('Connection test error: $e');
      return false;
    }
  }
}

// =================== MODEL CLASSES ===================

// User Model
class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final String profileImage;
  final UserPreferences preferences;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.profileImage,
    required this.preferences,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'] ?? 'https://i.pravatar.cc/150?img=47',
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'username': username,
      'email': email,
      'profileImage': profileImage,
      'preferences': preferences.toJson(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// User Preferences Model
class UserPreferences {
  final bool notifications;
  final bool darkMode;

  UserPreferences({
    required this.notifications,
    required this.darkMode,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      notifications: json['notifications'] ?? true,
      darkMode: json['darkMode'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications,
      'darkMode': darkMode,
    };
  }
}

// Auth Response Model
class AuthResponse {
  final User user;
  final String token;
  final String message;

  AuthResponse({
    required this.user,
    required this.token,
    required this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['data']['user']),
      token: json['data']['token'],
      message: json['message'] ?? '',
    );
  }
}

// API Exception Class
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic errors;

  ApiException({
    required this.message,
    required this.statusCode,
    this.errors,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }
}

// =================== EXTENSION METHODS ===================

// String extension for validation
extension StringValidation on String {
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);
  }

  bool get isValidPassword {
    return length >= 6;
  }

  bool get isValidUsername {
    return length >= 3 && length <= 20 && RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(this);
  }
}