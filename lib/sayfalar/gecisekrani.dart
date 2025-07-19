import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_application_1/sayfalar/giris1.dart';
import 'package:flutter_application_1/services/api_service.dart'; // API Service import ekle

class acilisekrani extends StatefulWidget {
  @override
  _acilisekraniState createState() => _acilisekraniState();
}

class _acilisekraniState extends State<acilisekrani> {
  bool isConnected = false; // Bağlantı durumu ekle

  @override
  void initState() {
    super.initState();
    _checkConnectionAndNavigate(); // Bağlantı kontrolü ekle
  }

  // Bağlantı kontrolü ve navigasyon - ekle
  Future<void> _checkConnectionAndNavigate() async {
    // API bağlantısını kontrol et
    try {
      final serverHealth = await ApiService().checkServerHealth();
      setState(() {
        isConnected = serverHealth;
      });
    } catch (e) {
      setState(() {
        isConnected = false;
      });
    }

    // 2 saniye bekle ve login sayfasına git
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 250, height: 250),
              SizedBox(height: 10),
              
              // Bağlantı durumu göstergesi ekle
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isConnected ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      isConnected ? 'Bağlandı' : 'Bağlanıyor...',
                      style: TextStyle(
                        color: isConnected ? Colors.green[800] : Colors.orange[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Yükleme göstergesi ekle
              SizedBox(height: 20),
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
