import 'package:flutter/material.dart';
import 'package:flutter_application_1/sayfalar/kayıt.dart';
import 'package:flutter_application_1/sayfalar/giris1.dart';
import 'package:flutter_application_1/services/api_service.dart'; 

class AyarlarSayfasi extends StatefulWidget {
  const AyarlarSayfasi({Key? key}) : super(key: key);

  @override
  State<AyarlarSayfasi> createState() => _AyarlarSayfasiState();
}

class _AyarlarSayfasiState extends State<AyarlarSayfasi> {
  bool bildirimler = true;
  bool karanlikMod = false;
  final ApiService _apiService = ApiService(); // ApiService instance

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Ayarları yükle
  }

  // Ayarları backend'den yükle
  Future<void> _loadSettings() async {
    try {
      final settings = await _apiService.getSettings();
      setState(() {
        bildirimler = settings.notifications;
        karanlikMod = settings.darkMode;
      });
    } catch (e) {
      print('Ayarlar yüklenirken hata: $e');
    }
  }

  // Ayarları güncelle
  Future<void> _updateSettings() async {
    try {
      await _apiService.updateSettings(
        notifications: bildirimler,
        darkMode: karanlikMod,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ayarlar güncellendi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ayarlar güncellenirken hata: $e')),
      );
    }
  }

  // Çıkış yap
  Future<void> _logout() async {
    try {
      await _apiService.logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Çıkış yapılırken hata: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings, size: 28),
                  SizedBox(width: 10),
                  Text(
                    "Ayarlar",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 100),
            Container(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Icon(Icons.notifications,size: 32,),
                    title: Text(
                      "Bildirimler",
                      style: TextStyle( fontSize: 18),
                    ),
                    value: bildirimler,
                    activeColor: Colors.blue,
                    onChanged: (value) {
                      setState(() {
                        bildirimler = value;
                      });
                      _updateSettings(); // Ayarları güncelle
                    },
                  ),
                  SwitchListTile(
                    secondary: Icon(Icons.nightlight_round,size: 32,),
                    title: Text("Karanlık Mod",
                      style: TextStyle( fontSize: 18),
                    ),
                    value: karanlikMod,
                    activeColor: Colors.blue,
                    onChanged: (value) {
                      setState(() {
                        karanlikMod = value;
                      });
                      _updateSettings(); // Ayarları güncelle
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.security,size: 32,),
                    title: Text("Güvenlik Ayarları",
                      style: TextStyle( fontSize: 18),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.exit_to_app,size: 32,color: Colors.red,),
                    title: Text("Çıkış Yap",
                      style: TextStyle( color: Colors.red,fontSize: 18),
                    ),
                    onTap: _logout, // ApiService çıkış fonksiyonu
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}