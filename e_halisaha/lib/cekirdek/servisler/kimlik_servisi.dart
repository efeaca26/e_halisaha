import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KimlikServisi {
  static const _storage = FlutterSecureStorage();
  
  static Map<String, dynamic>? _aktifKullanici;

  // Getter: RAM'deki veriyi okur
  static Map<String, dynamic>? get aktifKullanici => _aktifKullanici;

  // --- GİRİŞ YAPINCA VERİLERİ KAYDET ---
  static Future<void> girisYapveKaydet(Map<String, dynamic> apiCevabi) async {
    print("API'den Gelen Ham Veri: ${apiCevabi['user']}");
    print("API'den Gelen Rol: ${apiCevabi['user']['role']}");

    // 1. Önce Hafızaya (RAM) al
    _aktifKullanici = {
      'id': apiCevabi['user']['id'] ?? apiCevabi['user']['userId'], 
      'userId': apiCevabi['user']['id'] ?? apiCevabi['user']['userId'], // userId anahtarını da ekleyelim, erişim kolay olsun
      'fullName': apiCevabi['user']['fullName'], // İsim uyumluluğu için
      'isim': apiCevabi['user']['fullName'],
      'telefon': apiCevabi['user']['phoneNumber'] ?? apiCevabi['user']['phone'],
      'phoneNumber': apiCevabi['user']['phoneNumber'] ?? apiCevabi['user']['phone'],
      'email': apiCevabi['user']['email'] ?? "",
      'role': apiCevabi['user']['role'], 
      'token': apiCevabi['token']
    };

    // 2. Sonra Kalıcı Hafızaya (Disk) Yaz
    if (apiCevabi['token'] != null) {
      await _storage.write(key: 'jwt_token', value: apiCevabi['token']);
      await _storage.write(key: 'user_id', value: _aktifKullanici!['id'].toString());
      await _storage.write(key: 'user_name', value: _aktifKullanici!['isim']);
      await _storage.write(key: 'user_email', value: _aktifKullanici!['email']);
      await _storage.write(key: 'user_phone', value: _aktifKullanici!['telefon'] ?? "");
      await _storage.write(key: 'user_role', value: _aktifKullanici!['role'] ?? "oyuncu");
    }
  }

  // --- EKSİK OLAN METOT BU: KULLANICIYI GETİR ---
  // Giriş ekranında yönlendirme yapmak için bu metoda ihtiyacımız var.
  static Future<Map<String, dynamic>?> kullaniciGetir() async {
    // 1. Eğer RAM'de varsa direkt onu döndür (Hızlıdır)
    if (_aktifKullanici != null) {
      return _aktifKullanici;
    }

    // 2. RAM boşsa (Uygulama yeni açıldıysa), Diskten oku
    String? token = await _storage.read(key: 'jwt_token');
    String? idStr = await _storage.read(key: 'user_id');
    String? name = await _storage.read(key: 'user_name');
    String? email = await _storage.read(key: 'user_email');
    String? phone = await _storage.read(key: 'user_phone');
    String? role = await _storage.read(key: 'user_role');

    // Veriler eksiksizse objeyi oluştur
    if (token != null && idStr != null) {
      _aktifKullanici = {
        'id': int.tryParse(idStr) ?? 0,
        'userId': int.tryParse(idStr) ?? 0,
        'isim': name,
        'fullName': name, // İki türlü de erişilebilsin
        'email': email,
        'telefon': phone,
        'phoneNumber': phone,
        'role': role,
        'token': token
      };
      return _aktifKullanici;
    }

    return null; // Kullanıcı giriş yapmamış
  }

  static Future<String?> tokenGetir() async {
    return await _storage.read(key: 'jwt_token');
  }

  // --- UYGULAMA AÇILINCA VERİLERİ GERİ YÜKLE ---
  static Future<bool> oturumKontrol() async {
    var user = await kullaniciGetir(); // Yukarıdaki fonksiyonu kullanıyoruz
    return user != null;
  }

  static Future<void> cikisYap() async {
    await _storage.deleteAll();
    _aktifKullanici = null;
  }

  // --- GETTERLAR (YETKİ KONTROLLERİ) ---
  static bool get isAdmin {
    if (_aktifKullanici == null) return false;
    final rolDegeri = _aktifKullanici!['role'];
    return rolDegeri?.toString().toLowerCase() == 'admin';
  }

  static bool get isIsletme {
    if (_aktifKullanici == null) return false;
    final rolDegeri = _aktifKullanici!['role'];
    final rolStr = rolDegeri?.toString().toLowerCase();
    return rolStr == 'sahasahibi' || rolStr == 'isletme';
  }
}