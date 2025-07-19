import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/sayfalar/ayarlar.dart';
import 'package:flutter_application_1/sayfalar/profile_edit.dart';
import 'package:flutter_application_1/services/api_service.dart'; // API servis import
import 'package:flutter_application_1/sayfalar/giris1.dart'; // Login sayfası import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? currentUser;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Kullanıcı profilini yükle
  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final user = await ApiService().getProfile();

      setState(() {
        currentUser = user;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        if (e is ApiException) {
          errorMessage = e.message;
          // Token geçersizse login sayfasına yönlendir
          if (e.statusCode == 401) {
            _redirectToLogin();
          }
        } else {
          errorMessage = 'Profil yüklenirken hata oluştu';
        }
      });
    }
  }

  // Login sayfasına yönlendir
  void _redirectToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  // Çıkış yap fonksiyonu
  Future<void> _logout() async {
    try {
      // Onay dialogu göster
      final shouldLogout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Çıkış Yap'),
          content: Text('Çıkış yapmak istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (shouldLogout == true) {
        // Loading göster
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: CircularProgressIndicator(),
          ),
        );

        await ApiService().logout();

        // Loading kapat ve login sayfasına yönlendir
        Navigator.of(context).pop(); // Loading dialog'unu kapat
        _redirectToLogin();
      }
    } catch (e) {
      // Loading dialog'unu kapat
      Navigator.of(context).pop();

      String message = 'Çıkış yapılırken hata oluştu';
      if (e is ApiException) {
        message = e.message;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //profil fotosu
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Profil yükleniyor...'),
                  ],
                ),
              )
            : errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadUserProfile,
                          child: Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadUserProfile,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 20),

                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 90,
                                    backgroundColor: Colors.grey.shade300,
                                    backgroundImage: _image != null
                                        ? FileImage(_image!)
                                        : AssetImage('assets/profil.jpeg')
                                            as ImageProvider,
                                    onBackgroundImageError:
                                        (exception, stackTrace) {
                                      print(
                                          'Profil resmi yüklenemedi: $exception');
                                    },
                                    child: currentUser?.profileImage == null
                                        ? Icon(Icons.person, size: 50)
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 120,
                                    child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: pickImage,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                        ),
                                        child: Icon(Icons.edit,
                                            size: 32, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),

                              // Kullanıcı adı
                              Text(
                                currentUser?.name ?? 'Kullanıcı',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),

                              // Email
                              Text(
                                currentUser?.email ?? 'email@example.com',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 5),

                              // Username
                              Text(
                                '@${currentUser?.username ?? 'username'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),

                              SizedBox(height: 30),

                              // Profili düzenle
                              ListTile(
                                leading: Icon(Icons.person),
                                title: Text('Profili düzenle'),
                                trailing:
                                    Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfilePageEdit(),
                                    ),
                                  );

                                  // Profil düzenleme sayfasından dönünce profili yenile
                                  if (result == true) {
                                    _loadUserProfile();
                                  }
                                },
                              ),

                              // Ayarlar
                              ListTile(
                                leading: Icon(Icons.settings),
                                title: Text('Ayarlar'),
                                trailing:
                                    Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AyarlarSayfasi(),
                                    ),
                                  );
                                },
                              ),

                              // Hesap bilgileri
                              ListTile(
                                leading: Icon(Icons.info_outline),
                                title: Text('Hesap Bilgileri'),
                                trailing:
                                    Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  _showAccountInfo();
                                },
                              ),

                              Divider(height: 32),

                              // Çıkış yap
                              ListTile(
                                leading: Icon(Icons.logout, color: Colors.red),
                                title: Text(
                                  'Çıkış Yap',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onTap: _logout,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  // Hesap bilgilerini göster
  void _showAccountInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hesap Bilgileri'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Ad', currentUser?.name ?? ''),
            _buildInfoRow('Kullanıcı Adı', currentUser?.username ?? ''),
            _buildInfoRow('E-posta', currentUser?.email ?? ''),
            _buildInfoRow('Hesap Durumu',
                currentUser?.isActive == true ? 'Aktif' : 'Pasif'),
            _buildInfoRow('Üyelik Tarihi',
                currentUser?.createdAt.toString().split(' ')[0] ?? ''),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
