import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/api_service.dart'; // API Service import ekle

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: KesfetSayfasi(),
  ));
}

class KesfetSayfasi extends StatefulWidget { // StatelessWidget -> StatefulWidget yap
  const KesfetSayfasi({super.key});

  @override
  State<KesfetSayfasi> createState() => _KesfetSayfasiState();
}

class _KesfetSayfasiState extends State<KesfetSayfasi> {
  User? currentUser; // Kullanıcı bilgileri için ekle
  bool isLoading = true; // Yükleme durumu ekle
  TextEditingController searchController = TextEditingController(); // Arama controller'ı ekle

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

  // Arama işlevi ekle
  void _performSearch(String query) {
    if (query.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$query aranıyor...')),
      );
      // Burada API'ye arama isteği gönderebilirsiniz
    }
  }

  @override
  void dispose() {
    searchController.dispose(); // Controller'ı temizle
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                SizedBox(height: 10),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    Icon(Icons.eco, size: 40, color: Colors.green),

                    Text(
                      "KEŞFET",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    
                    // Kullanıcı karşılama mesajı ekle
                    if (currentUser != null && !isLoading)
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          "Merhaba ${currentUser!.name}, ne keşfetmek istiyorsun?",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 20),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: searchController, // Controller ekle
                          decoration: InputDecoration(
                            hintText: 'Ara',
                            border: InputBorder.none,
                          ),
                          onSubmitted: _performSearch, // Arama işlevi ekle
                        ),
                      ),
                      // Arama butonu ekle
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.green),
                        onPressed: () {
                          _performSearch(searchController.text);
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                
                // Yükleme durumu ekle
                if (isLoading)
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView(
                      children: [
                        _buildItem(
                          context,
                          "https://st3.depositphotos.com/14847044/17840/i/450/depositphotos_178406622-stock-photo-beautiful-landscape-view-mountains-lake.jpg",
                          "Doğa Bilgisi",
                        ),
                        _buildItem(
                          context,
                          "https://blog-images.hediyesepeti.com/2020/01/tarihi-yerler.jpg",
                          "Tarihi Mekanlar",
                        ),
                        _buildItem(
                          context,
                          "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Parcae.jpg/500px-Parcae.jpg",
                          "Hayvanlar Alemi",
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildItem(BuildContext context, String imageUrl, String title) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title tıklandı')),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 100,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}