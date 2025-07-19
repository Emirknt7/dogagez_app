import 'package:flutter/material.dart';
import 'package:flutter_application_1/sayfalar/profil.dart';
import 'package:flutter_application_1/sayfalar/kesfet.dart';
import 'package:flutter_application_1/services/api_service.dart'; // API Service import ekle

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  User? currentUser; // Kullanıcı bilgileri için ekle
  bool isLoading = true; // Yükleme durumu ekle

  final List<Widget> _pages = [HomeContent(), KesfetSayfasi(), ProfilePage()];

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Kullanıcı verilerini yükle
  }

  // Kullanıcı verilerini API'den yükle - ekle
  Future<void> _loadUserData() async {
    try {
      final user = await ApiService().getCurrentUser();
      setState(() {
        currentUser = user;
        isLoading = false;
      });
    } catch (e) {
      print('Kullanıcı bilgileri yüklenirken hata: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black45,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget { // StatelessWidget -> StatefulWidget yap
  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  User? currentUser; // Kullanıcı bilgileri ekle
  bool isLoading = true; // Yükleme durumu ekle

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Profil bilgilerini yükle
  }

  // Kullanıcı profil bilgilerini yükle - ekle
  Future<void> _loadUserProfile() async {
    try {
      final user = await ApiService().getProfile();
      setState(() {
        currentUser = user;
        isLoading = false;
      });
    } catch (e) {
      print('Profil bilgileri yüklenirken hata: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Kullanıcı karşılama mesajı ekle
          if (currentUser != null && !isLoading)
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                "Hoş geldin, ${currentUser!.name}!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.green[800],
                ),
              ),
            ),
          
          Text("Anasayfa",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 30),
          Image.network(
            'https://i.pinimg.com/1200x/0d/f9/8c/0df98c5fc5765eafc77dd7f638bb6d6d.jpg',
            width: 300,
            height: 350,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 50),
          Text(
            'DOĞAYI KEŞFET',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 32,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 40),
          Text(
            'Doğanın güzelliklerini keşfetmeye hazır mısın?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, color: Colors.black54),
          ),

          // Yükleme göstergesi ekle
          if (isLoading)
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
        ],
      ),
    );
  }
}
