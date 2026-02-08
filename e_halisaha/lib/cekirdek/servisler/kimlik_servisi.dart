import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KimlikServisi {
  static const _storage = FlutterSecureStorage();
  
  static Map<String, dynamic>? _aktifKullanici;

  static Map<String, dynamic>? get aktifKullanici => _aktifKullanici;

  // --- GİRİŞ YAPINCA VERİLERİ KAYDET ---
  static Future<void> girisYapveKaydet(Map<String, dynamic> apiCevabi) async {
    // Debug için konsola basalım
    print("API'den Gelen Ham Veri: ${apiCevabi['user']}");
    print("API'den Gelen Rol: ${apiCevabi['user']['role']}");

    // 1. Önce Hafızaya (RAM) al
    // DÜZELTME: Anahtar ismini 'role' (İngilizce) yaptık ki backend ile aynı olsun.
    _aktifKullanici = {
      'id': apiCevabi['user']['id'] ?? apiCevabi['user']['userId'], 
      'isim': apiCevabi['user']['fullName'],
      'telefon': apiCevabi['user']['phoneNumber'] ?? apiCevabi['user']['phone'], 
      'email': apiCevabi['user']['email'] ?? "",
      'role': apiCevabi['user']['role'], // ARTIK 'role' ANAHTARINI KULLANIYORUZ
      'token': apiCevabi['token']
    };

    // 2. Sonra Kalıcı Hafızaya (Disk) Yaz
    if (apiCevabi['token'] != null) {
      await _storage.write(key: 'jwt_token', value: apiCevabi['token']);
      await _storage.write(key: 'user_id', value: _aktifKullanici!['id'].toString());
      await _storage.write(key: 'user_name', value: _aktifKullanici!['isim']);
      await _storage.write(key: 'user_email', value: _aktifKullanici!['email']);
      await _storage.write(key: 'user_phone', value: _aktifKullanici!['telefon'] ?? "");
      // Storage'a kaydederken null kontrolü yapıyoruz
      await _storage.write(key: 'user_role', value: _aktifKullanici!['role'] ?? "oyuncu");
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
        'role': role ?? 'oyuncu', // DÜZELTME: Burada da 'role' kullanıyoruz
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

  // --- GETTERLAR (YETKİ KONTROLLERİ) ---
  
  // Admin kontrolü artık 'role' anahtarına bakıyor
  static bool get isAdmin {
    if (_aktifKullanici == null) return false;
    
    // Hem 'role' hem 'rol' (eski kod kalıntısı varsa) kontrol et, garanti olsun.
    final rolDegeri = _aktifKullanici!['role'] ?? _aktifKullanici!['rol'];
    
    // Küçük harfe çevirip kontrol et
    return rolDegeri?.toString().toLowerCase() == 'admin';
  }

  static bool get isIsletme {
    if (_aktifKullanici == null) return false;
    
    final rolDegeri = _aktifKullanici!['role'] ?? _aktifKullanici!['rol'];
    final rolStr = rolDegeri?.toString().toLowerCase();
    
    return rolStr == 'sahasahibi' || rolStr == 'isletme';
  }
}