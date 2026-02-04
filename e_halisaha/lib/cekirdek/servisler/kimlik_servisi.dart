import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KimlikServisi {
  static const _storage = FlutterSecureStorage();
  
  static Map<String, dynamic>? _aktifKullanici;

  static Map<String, dynamic>? get aktifKullanici => _aktifKullanici;

  static Future<void> girisYapveKaydet(Map<String, dynamic> apiCevabi) async {
    if (apiCevabi['token'] != null) {
      await _storage.write(key: 'jwt_token', value: apiCevabi['token']);
    }

    _aktifKullanici = {
      'id': apiCevabi['user']['id'],
      'isim': apiCevabi['user']['fullName'],
      'telefon': apiCevabi['user']['phone'],
      'email': apiCevabi['user']['email'] ?? "",
      'rol': apiCevabi['user']['role'],
      'token': apiCevabi['token']
    };
  }

  static Future<String?> tokenGetir() async {
    return await _storage.read(key: 'jwt_token');
  }

  static Future<bool> oturumKontrol() async {
    String? token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      _aktifKullanici = {
        'isim': 'Kullanıcı', 
        'rol': 'User', 
        'token': token
      };
      return true;
    }
    return false;
  }

  static Future<void> cikisYap() async {
    await _storage.delete(key: 'jwt_token');
    _aktifKullanici = null;
  }

  static void kullaniciyiKaydet(Map<String, dynamic> gelenVeri) {
    _aktifKullanici = {
      'isim': gelenVeri['fullname'] ?? gelenVeri['adSoyad'] ?? 'Kullanıcı',
      'email': gelenVeri['email'],
      'rol': gelenVeri['role'] ?? gelenVeri['rol'] ?? 'User',
      'token': gelenVeri['token']
    };
  }

  
  static bool get isAdmin {
    if (_aktifKullanici == null) return false;
    final rol = _aktifKullanici!['rol'].toString().toLowerCase();
    return rol == 'admin';
  }

  static bool get isIsletme {
    if (_aktifKullanici == null) return false;
    final rol = _aktifKullanici!['rol'].toString().toLowerCase();
    return rol == 'sahasahibi' || rol == 'isletme';
  }

  static final List<Map<String, dynamic>> _mockKullanicilar = [
    {'isim': 'Sistem Yöneticisi', 'email': 'admin@ehalisaha.com', 'rol': 'admin'},
    {'isim': 'Ahmet Yılmaz', 'email': 'oyuncu@ehalisaha.com', 'rol': 'oyuncu'},
    {'isim': 'Mega Halı Saha', 'email': 'isletme@ehalisaha.com', 'rol': 'isletme'},
  ];

  static List<Map<String, dynamic>> get tumKullanicilar => _mockKullanicilar;

  static void rolDegistir(String email, String yeniRol) {
    for (var u in _mockKullanicilar) {
      if (u['email'] == email) {
        u['rol'] = yeniRol;
        break;
      }
    }
  }
}