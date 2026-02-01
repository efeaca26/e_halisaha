class KimlikServisi {
  static final List<Map<String, dynamic>> _kullanicilar = [
    {
      'isim': 'Sistem Yöneticisi',
      'email': 'admin@ehalisaha.com',
      'sifre': 'admin123',
      'isletmeModu': true,
      'rol': 'admin'
    },
    {
      'isim': 'Efe Acar',
      'email': 'efe.acar@ademceylantk.com.tr',
      'sifre': 'acftk123',
      'isletmeModu': false,
      'rol': 'oyuncu'
    },
    {
      'isim': 'Yıldız Spor Yönetim',
      'email': 'isletme@yildizspor.com',
      'sifre': 'yildiz123',
      'isletmeModu': true,
      'rol': 'isletme'
    }
  ];

  static Map<String, dynamic>? _aktifKullanici;
  static Map<String, dynamic>? get aktifKullanici => _aktifKullanici;

  // --- EKSİK OLAN KISIMLAR EKLENDİ ---
  
  // Tüm kullanıcıları dışarıya aç
  static List<Map<String, dynamic>> get tumKullanicilar => _kullanicilar;

  // Rol Değiştirme Fonksiyonu
  static void rolDegistir(String email, String yeniRol) {
    for (var u in _kullanicilar) {
      if (u['email'] == email) {
        u['rol'] = yeniRol;
        break;
      }
    }
    // Eğer kendi rolümüzü değiştirdiysek oturumu güncelle
    if (_aktifKullanici != null && _aktifKullanici!['email'] == email) {
      _aktifKullanici!['rol'] = yeniRol;
    }
  }
  // -----------------------------------

  static Future<bool> girisYap(String email, String sifre) async {
    await Future.delayed(const Duration(seconds: 1));
    for (var kullanici in _kullanicilar) {
      if (kullanici['email'] == email && kullanici['sifre'] == sifre) {
        _aktifKullanici = kullanici;
        return true;
      }
    }
    return false;
  }

  static Future<bool> kayitOl(String isim, String email, String sifre, bool isletmeModu) async {
    await Future.delayed(const Duration(seconds: 1));
    for (var kullanici in _kullanicilar) {
      if (kullanici['email'] == email) return false;
    }
    Map<String, dynamic> yeniKullanici = {
      'isim': isim,
      'email': email,
      'sifre': sifre,
      'isletmeModu': isletmeModu,
      'rol': isletmeModu ? 'isletme' : 'oyuncu'
    };
    _kullanicilar.add(yeniKullanici);
    _aktifKullanici = yeniKullanici;
    return true;
  }

  static void cikisYap() { _aktifKullanici = null; }

  static bool get isAdmin => _aktifKullanici != null && _aktifKullanici!['rol'] == 'admin';
  static bool get isIsletme => _aktifKullanici != null && _aktifKullanici!['rol'] == 'isletme';
}