import 'package:flutter/material.dart';
import 'package:flutter_application_1/sayfalar/giris1.dart';
import 'package:flutter_application_1/services/api_service.dart'; // ApiService import

class Sifreunut extends StatefulWidget {
  const Sifreunut({super.key});

  @override
  State<Sifreunut> createState() => _SifreunutState();
}

class _SifreunutState extends State<Sifreunut> {
  final ApiService _apiService = ApiService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isResetMode = false; // false: forgot password, true: reset password
  String? _resetToken;

  Future<void> _sendResetEmail() async {
    if (_emailController.text.isEmpty) {
      _showErrorSnackBar('Lütfen e-posta adresinizi girin');
      return;
    }

    if (!_emailController.text.isValidEmail) {
      _showErrorSnackBar('Geçerli bir e-posta adresi girin');
      return;
    }

    try {
      setState(() => _isLoading = true);
      
      final message = await _apiService.forgotPassword(
        email: _emailController.text,
      );
      
      _showSuccessSnackBar(message);
      
      // Gerçek uygulamada bu kısmı kaldırın - sadece demo için
      _showResetTokenDialog();
      
    } catch (e) {
      if (e is ApiException) {
        _showErrorSnackBar('Hata: ${e.message}');
      } else {
        _showErrorSnackBar('Beklenmeyen hata: ${e.toString()}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Demo için reset token girişi - gerçek uygulamada kaldırılacak
  void _showResetTokenDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final tokenController = TextEditingController();
        return AlertDialog(
          title: Text('Reset Token'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('E-postanıza gönderilen reset token\'ı girin:'),
              SizedBox(height: 10),
              TextField(
                controller: tokenController,
                decoration: InputDecoration(
                  hintText: 'Reset Token',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                if (tokenController.text.isNotEmpty) {
                  setState(() {
                    _resetToken = tokenController.text;
                    _isResetMode = true;
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Devam Et'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetPassword() async {
    if (_passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      _showErrorSnackBar('Lütfen tüm alanları doldurun');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('Şifreler eşleşmiyor');
      return;
    }

    if (!_passwordController.text.isValidPassword) {
      _showErrorSnackBar('Şifre en az 6 karakter olmalıdır');
      return;
    }

    if (_resetToken == null) {
      _showErrorSnackBar('Reset token bulunamadı');
      return;
    }

    try {
      setState(() => _isLoading = true);
      
      final authResponse = await _apiService.resetPassword(
        token: _resetToken!,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      
      _showSuccessSnackBar('Şifre başarıyla yenilendi');
      
      // Giriş sayfasına yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      
    } catch (e) {
      if (e is ApiException) {
        _showErrorSnackBar('Hata: ${e.message}');
      } else {
        _showErrorSnackBar('Beklenmeyen hata: ${e.toString()}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isResetMode ? 'Şifre Yenile' : 'Şifremi Unuttum'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/logo.png', width: 175, height: 175),
                      SizedBox(height: 10),
                      Text(
                        'DOĞAYI KEŞFET',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 30),
                      
                      if (!_isResetMode) ...[
                        // Şifre sıfırlama e-postası gönderme
                        Text(
                          'Şifrenizi sıfırlamak için e-posta adresinizi girin:',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 20),
                        
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            hintText: 'E-posta adresinizi girin',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 30),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[800],
                            ),
                            onPressed: _isLoading ? null : _sendResetEmail,
                            child: Text(
                              'Sıfırlama E-postası Gönder',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Şifre yenileme formu
                        Text(
                          'Yeni şifrenizi girin:',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 20),
                        
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            hintText: 'Yeni şifrenizi girin',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 15),
                        
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            hintText: 'Yeni şifrenizi tekrar girin',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 30),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[800],
                            ),
                            onPressed: _isLoading ? null : _resetPassword,
                            child: Text(
                              'Şifre Yenile',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                      
                      SizedBox(height: 20),
                      
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                        child: Text(
                          'Giriş sayfasına dön',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}