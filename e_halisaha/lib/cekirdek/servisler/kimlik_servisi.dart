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
      'email': 'acar@gmail.com',
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

  static List<Map<String, dynamic>> get tumKullanicilar => _kullanicilar;

  static void rolDegistir(String email, String yeniRol) {
    for (var u in _kullanicilar) {
      if (u['email'] == email) {
        u['rol'] = yeniRol;
        break;
      }
    }
    if (_aktifKullanici != null && _aktifKullanici!['email'] == email) {
      _aktifKullanici!['rol'] = yeniRol;
    }
  }

  // --- GÜNCELLENEN GİRİŞ MANTIĞI ---
  static Future<bool> girisYap(String email, String sifre, bool isletmeGirisiMi) async {
    await Future.delayed(const Duration(seconds: 1));
    
    for (var kullanici in _kullanicilar) {
      bool emailDogru = kullanici['email'].toString().toLowerCase() == email.toLowerCase();
      bool sifreDogru = kullanici['sifre'] == sifre;

      if (emailDogru && sifreDogru) {
        String rol = kullanici['rol'];

        // 1. Durum: İşletme Sekmesinden Girmeye Çalışıyor
        if (isletmeGirisiMi) {
          // BURASI DEĞİŞTİ: Sadece 'isletme' rolü buradan girebilir.
          // Admin artık buradan GİREMEZ.
          if (rol == 'isletme') {
            _aktifKullanici = kullanici;
            return true;
          } else {
            print("HATA: Bu hesaba İşletme panelinden girilemez!");
            return false;
          }
        } 
        // 2. Durum: Normal (Oyuncu) Sekmesinden Girmeye Çalışıyor
        else {
          // BURASI DEĞİŞTİ: 'oyuncu' VEYA 'admin' buradan girebilir.
          if (rol == 'oyuncu' || rol == 'admin') {
            _aktifKullanici = kullanici;
            return true;
          } else {
            print("HATA: İşletme hesabı normal girişten giremez!");
            return false;
          }
        }
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