import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KimlikServisi {
  static const _storage = FlutterSecureStorage();
  
  static Map<String, dynamic>? _aktifKullanici;

  static Map<String, dynamic>? get aktifKullanici => _aktifKullanici;

  // --- GİRİŞ YAPINCA VERİLERİ KAYDET ---
  static Future<void> girisYapveKaydet(Map<String, dynamic> apiCevabi) async {
    // 1. Önce Hafızaya (RAM) al
    _aktifKullanici = {
      'id': apiCevabi['user']['id'] ?? apiCevabi['user']['userId'], // API bazen farklı dönebilir garantiye alalım
      'isim': apiCevabi['user']['fullName'],
      'telefon': apiCevabi['user']['phoneNumber'] ?? apiCevabi['user']['phone'], // API uyumu
      'email': apiCevabi['user']['email'] ?? "",
      'rol': apiCevabi['user']['role'],
      'token': apiCevabi['token']
    };

    // 2. Sonra Kalıcı Hafızaya (Disk) Yaz
    if (apiCevabi['token'] != null) {
      await _storage.write(key: 'jwt_token', value: apiCevabi['token']);
      await _storage.write(key: 'user_id', value: _aktifKullanici!['id'].toString());
      await _storage.write(key: 'user_name', value: _aktifKullanici!['isim']);
      await _storage.write(key: 'user_email', value: _aktifKullanici!['email']);
      await _storage.write(key: 'user_phone', value: _aktifKullanici!['telefon'] ?? "");
      await _storage.write(key: 'user_role', value: _aktifKullanici!['rol'] ?? "User");
    }
  }

  static Future<String?> tokenGetir() async {
    return await _storage.read(key: 'jwt_token');
  }

  // --- UYGULAMA AÇILINCA VERİLERİ GERİ YÜKLE ---
  static Future<bool> oturumKontrol() async {
    String? token = await _storage.read(key: 'jwt_token');
    String? idStr = await _storage.read(key: 'user_id');
    String? name = await _storage.read(key: 'user_name');
    String? email = await _storage.read(key: 'user_email');
    String? phone = await _storage.read(key: 'user_phone');
    String? role = await _storage.read(key: 'user_role');

    if (token != null && idStr != null) {
      // Verileri hafızaya geri yükle
      _aktifKullanici = {
        'id': int.parse(idStr),
        'isim': name ?? 'Kullanıcı', 
        'email': email ?? '',
        'telefon': phone ?? '',
        'rol': role ?? 'User', 
        'token': token
      };
      return true;
    }
    return false;
  }

  static Future<void> cikisYap() async {
    // Hepsini sil
    await _storage.deleteAll();
    _aktifKullanici = null;
  }

  // Getterlar
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
}