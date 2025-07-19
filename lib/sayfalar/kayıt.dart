import 'package:flutter/material.dart';
import 'package:flutter_application_1/sayfalar/giris1.dart';
import 'package:flutter_application_1/services/api_service.dart'; // ApiService import edildi

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterPage(),
    );
  }
}

class RegisterPage extends StatefulWidget { // StatefulWidget'a çevrildi
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final ApiService _apiService = ApiService(); // ApiService instance
  final TextEditingController _nameController = TextEditingController(); // Controller eklendi
  final TextEditingController _emailController = TextEditingController(); // Controller eklendi
  final TextEditingController _passwordController = TextEditingController(); // Controller eklendi
  final TextEditingController _confirmPasswordController = TextEditingController(); // Controller eklendi
  bool _isLoading = false; // Loading state eklendi

  // Kayıt ol fonksiyonu
  Future<void> _register() async {
    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    if (!_emailController.text.isValidEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Geçerli bir e-posta adresi girin')),
      );
      return;
    }

    if (!_passwordController.text.isValidPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Şifre en az 6 karakter olmalıdır')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Şifreler eşleşmiyor')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authResponse = await _apiService.register(
        name: _nameController.text,
        username: _nameController.text.toLowerCase().replaceAll(' ', ''),
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt başarılı!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt hatası: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding:  EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 100, height: 100),
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

              // Ad gir
              TextField(
                controller: _nameController, // Controller eklendi
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Adınızı girin',
                  border:OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),

              // E-posta gir
              TextField(
                controller: _emailController, // Controller eklendi
                decoration: InputDecoration(
                  prefixIcon:Icon(Icons.email),
                  hintText: 'E-posta girin',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),

              // Şifre gir
              TextField(
                controller: _passwordController, // Controller eklendi
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  hintText: 'Şifrenizi girin',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),

              TextField(
                controller: _confirmPasswordController, // Controller eklendi
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon:Icon(Icons.lock),
                  hintText: 'Şifrenizi tekrar giriniz',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),

              // Kayıt ol butonu
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                  ),
                  onPressed: _isLoading ? null : _register, // ApiService kayıt fonksiyonu
                  child: _isLoading 
                    ? CircularProgressIndicator(color: Colors.white) // Loading göstergesi
                    : Text(
                        'Kayıt ol',
                        style: TextStyle(color: Colors.white),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
