import 'api_servisi.dart';

class KimlikServisi {
  // --- 1. OTURUM YÖNETİMİ (Giriş Yapan Kişi) ---
  static Map<String, dynamic>? _aktifKullanici;
  static Map<String, dynamic>? get aktifKullanici => _aktifKullanici;

  // --- 2. ADMIN PANELİ İÇİN GEREKLİ VERİLER (Hataları Çözmek İçin) ---
  // Admin paneli bu listeyi arıyor. Şimdilik manuel liste tutalım.
  static final List<Map<String, dynamic>> _kullanicilar = [
    {'isim': 'Sistem Yöneticisi', 'email': 'admin@ehalisaha.com', 'rol': 'admin'},
    {'isim': 'Örnek Oyuncu', 'email': 'oyuncu@ehalisaha.com', 'rol': 'oyuncu'},
    {'isim': 'Örnek İşletme', 'email': 'isletme@ehalisaha.com', 'rol': 'isletme'},
  ];

  // Admin ekranının çağırdığı "Tüm Kullanıcıları Getir" komutu
  static List<Map<String, dynamic>> get tumKullanicilar => _kullanicilar;

  // Admin ekranının çağırdığı "Rol Değiştir" komutu
  static void rolDegistir(String email, String yeniRol) {
    for (var u in _kullanicilar) {
      if (u['email'] == email) {
        u['rol'] = yeniRol;
        break;
      }
    }
  }
  // -------------------------------------------------------------

  // --- 3. API İLE GİRİŞ & KAYIT ---
  static Future<bool> girisYap(String email, String sifre, bool isletmeModu) async {
    // Sunucuya sor
    bool basarili = await ApiServisi.girisYap(email, sifre, isletmeModu);

    if (basarili) {
      // Başarılıysa hafızaya al (Uygulama içinde kullanmak için)
      _aktifKullanici = {
        'email': email,
        'rol': isletmeModu ? 'isletme' : 'oyuncu',
        // Eğer 'admin@ehalisaha.com' ile girildiyse rolü admin yap (Test için)
        'isim': email.split('@')[0],
      };
      
      // Admin girişi testi (Eğer e-posta admin ise yetki ver)
      if (email == 'admin@ehalisaha.com') {
        _aktifKullanici!['rol'] = 'admin';
      }

      return true;
    } else {
      return false;
    }
  }

  static Future<bool> kayitOl(String isim, String email, String sifre, bool isletmeModu) async {
    return await ApiServisi.kayitOl(isim, email, sifre, isletmeModu);
  }

  static void cikisYap() {
    _aktifKullanici = null;
  }

  // --- 4. YARDIMCI KONTROLLER ---
  static bool get isAdmin => _aktifKullanici != null && _aktifKullanici!['rol'] == 'admin';
  static bool get isIsletme => _aktifKullanici != null && _aktifKullanici!['rol'] == 'isletme';
}