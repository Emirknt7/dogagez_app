import 'package:flutter/material.dart';
import 'package:flutter_application_1/sayfalar/kayıt.dart';
import 'package:flutter_application_1/sayfalar/anasayfa.dart';
import 'package:flutter_application_1/sayfalar/sifreunut.dart';
import 'package:flutter_application_1/services/api_service.dart'; // ApiService import edildi

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DOĞAGEZ',
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget { // StatefulWidget'a çevrildi
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final ApiService _apiService = ApiService(); // ApiService instance
  final TextEditingController _usernameController = TextEditingController(); // Controller eklendi
  final TextEditingController _emailController = TextEditingController(); // Controller eklendi
  final TextEditingController _passwordController = TextEditingController(); // Controller eklendi
  bool _isLoading = false; // Loading state eklendi

  // Giriş yap fonksiyonu
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
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

    setState(() {
      _isLoading = true;
    });

    try {
      final authResponse = await _apiService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giriş hatası: $e')),
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
        child:SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map, size: 60, color: Colors.green),
              SizedBox(height: 10),
              Text(
                "DOĞAGEZ",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 30),

              TextField(
                controller: _usernameController, // Controller eklendi
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: "kullanıcı adı",
                  hintText: 'Kullanıcı adınızı girin',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),

              TextField(
                controller: _emailController, // Controller eklendi
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: "E-posta",
                  hintText: 'E-posta adresini girin',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),

              TextField(
                controller: _passwordController, // Controller eklendi
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: "Şifrenizi girin",
                  hintText: 'Şifreniz',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 25),

              Container(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login, // ApiService giriş fonksiyonu
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[900],
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          child: _isLoading 
                            ? CircularProgressIndicator(color: Colors.white) // Loading göstergesi
                            : Text(
                                'Giriş Yap',
                                style: TextStyle(color: Colors.white),
                              ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterPage(),
                              ),
                            );

                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[900],
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Kayıt Ol',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Sifreunut(),
                          ),
                        );
                      },
                      child:Text(
                        'şifremi unuttum',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}