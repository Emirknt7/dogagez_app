import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart'; // ApiService import

class ProfilePageEdit extends StatefulWidget {
  const ProfilePageEdit({Key? key}) : super(key: key);

  @override
  State<ProfilePageEdit> createState() => _ProfilePageEditState();
}

class _ProfilePageEditState extends State<ProfilePageEdit> {
  final ApiService _apiService = ApiService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      setState(() => _isLoading = true);
      final user = await _apiService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _usernameController.text = user.username;
        _emailController.text = user.email;
      });
    } catch (e) {
      _showErrorSnackBar('Kullanıcı bilgileri yüklenemedi: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_usernameController.text.isEmpty || _emailController.text.isEmpty) {
      _showErrorSnackBar('Lütfen tüm alanları doldurun');
      return;
    }

    try {
      setState(() => _isLoading = true);
      final updatedUser = await _apiService.updateProfile(
        username: _usernameController.text,
        email: _emailController.text,
      );
      
      setState(() => _currentUser = updatedUser);
      _showSuccessSnackBar('Profil başarıyla güncellendi');
    } catch (e) {
      if (e is ApiException) {
        _showErrorSnackBar('Profil güncelleme hatası: ${e.message}');
      } else {
        _showErrorSnackBar('Beklenmeyen hata: ${e.toString()}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updatePassword() async {
    if (_currentPasswordController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      _showErrorSnackBar('Lütfen tüm şifre alanlarını doldurun');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('Yeni şifreler eşleşmiyor');
      return;
    }

    if (!_passwordController.text.isValidPassword) {
      _showErrorSnackBar('Şifre en az 6 karakter olmalıdır');
      return;
    }

    try {
      setState(() => _isLoading = true);
      final message = await _apiService.updatePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      
      _showSuccessSnackBar(message);
      _currentPasswordController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      if (e is ApiException) {
        _showErrorSnackBar('Şifre güncelleme hatası: ${e.message}');
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
        title: Text('Profili Düzenle'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              margin: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    
                    // Kullanıcı Adı Güncelleme
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: "Kullanıcı Adı",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    
                    // E-posta Güncelleme
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        labelText: "E-posta",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    
                    // Profil Güncelleme Butonu
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[900],
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Profili Kaydet',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    
                    SizedBox(height: 30),
                    Divider(),
                    SizedBox(height: 20),
                    
                    // Şifre Güncelleme Bölümü
                    Text(
                      'Şifre Güncelle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    
                    // Mevcut Şifre
                    TextField(
                      controller: _currentPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        labelText: "Mevcut Şifre",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    
                    // Yeni Şifre
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        labelText: "Yeni Şifre",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    
                    // Yeni Şifre Tekrar
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        labelText: "Yeni Şifre Tekrar",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    
                    // Şifre Güncelleme Butonu
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[900],
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Şifreyi Kaydet',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _currentPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}