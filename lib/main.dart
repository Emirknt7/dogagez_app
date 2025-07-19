import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/sayfalar/gecisekrani.dart';
import 'package:flutter_application_1/services/api_service.dart'; // API servisinizin yolu
import 'package:flutter_application_1/sayfalar/giris1.dart'; // Login ekranı
import 'package:flutter_application_1/sayfalar/anasayfa.dart'; // Ana ekran

void main() async {
  // Flutter binding'i başlat
  WidgetsFlutterBinding.ensureInitialized();
  
  // SharedPreferences'i başlat
  await SharedPreferences.getInstance();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter API App',
      
      // Tema ayarları
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        
        // App Bar tema
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        
        // Button tema
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        
        // Input decoration tema
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      
      // Dark tema
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      
      // Tema modu ayarı (user preferences'dan gelecek)
      themeMode: ThemeMode.system,
      
      // Debug banner'ı kaldır
      debugShowCheckedModeBanner: false,
      
      // Ana sayfa - Auth durumunu kontrol eden widget
      home: const AuthWrapper(),
      
      // Route tanımlamaları
      routes: {
        '/login': (context) =>  LoginPage(),
        '/home': (context) =>  HomePage(),
        '/splash': (context) =>  acilisekrani(),
      },
    );
  }
}

// Authentication wrapper - Token durumunu kontrol eder
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  // Authentication durumunu kontrol et
  Future<void> _checkAuthStatus() async {
    try {
      // Sunucu sağlık kontrolü
      final isServerHealthy = await ApiService().checkServerHealth();
      if (!isServerHealthy) {
        setState(() {
          _errorMessage = 'Sunucu bağlantısı kurulamadı';
          _isLoading = false;
        });
        return;
      }

      // Token kontrolü
      final token = await ApiService().getToken();
      if (token != null) {
        try {
          // Token geçerli mi kontrol et
          final user = await ApiService().getCurrentUser();
          if (user.isActive) {
            setState(() {
              _isAuthenticated = true;
              _isLoading = false;
            });
            return;
          }
        } catch (e) {
          // Token geçersiz, temizle
          await ApiService().clearToken();
        }
      }

      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Başlangıç hatası: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Yükleniyor ekranı
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Uygulama başlatılıyor...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // Hata durumu
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _checkAuthStatus();
                },
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    // Authentication durumuna göre sayfa yönlendirme
    if (_isAuthenticated) {
      return const HomePage(); // Kullanıcı giriş yapmış
    } else {
      return  acilisekrani(); // Giriş ekranına yönlendir
    }
  }
}

// Global error handler
class GlobalErrorHandler {
  static void handleError(dynamic error, {VoidCallback? onRetry}) {
    String message = 'Bilinmeyen bir hata oluştu';
    
    if (error is ApiException) {
      message = error.message;
    } else {
      message = error.toString();
    }
    
    // Burada global error handling yapabilirsiniz
    // Örneğin: logging, crash analytics vb.
    debugPrint('Global Error: $message');
  }
}

// App lifecycle observer
class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // App aktif olduğunda
        debugPrint('App resumed');
        break;
      case AppLifecycleState.paused:
        // App arka plana geçtiğinde
        debugPrint('App paused');
        break;
      case AppLifecycleState.detached:
        // App kapatılırken
        debugPrint('App detached');
        break;
      default:
        break;
    }
  }
}

// Usage Examples ve Utility Functions
class AppConstants {
  static const String appName = 'Flutter API App';
  static const String version = '1.0.0';
  
  // API timeout süreleri
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);
  
  // SharedPreferences keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String settingsKey = 'user_settings';
}

// Utility class for common operations
class AppUtils {
  // Snackbar göster
  static void showSnackbar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  
  // Loading dialog göster
  static void showLoadingDialog(BuildContext context, {String message = 'Yükleniyor...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        ),
      ),
    );
  }
  
  // Loading dialog kapat
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}