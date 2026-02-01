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

  // --- GÜNCELLENEN GİRİŞ FONKSİYONU ---
  // Artık 'isletmeGirisiMi' diye bir parametre alıyor
  static Future<bool> girisYap(String email, String sifre, bool isletmeGirisiMi) async {
    await Future.delayed(const Duration(seconds: 1));
    
    for (var kullanici in _kullanicilar) {
      bool emailDogru = kullanici['email'].toString().toLowerCase() == email.toLowerCase();
      bool sifreDogru = kullanici['sifre'] == sifre;

      if (emailDogru && sifreDogru) {
        // KULLANICI BULUNDU, ŞİMDİ ROL KONTROLÜ YAPALIM
        String rol = kullanici['rol'];

        // 1. Durum: İşletme Kapısından Girmeye Çalışıyor
        if (isletmeGirisiMi) {
          // Sadece 'admin' ve 'isletme' girebilir
          if (rol == 'admin' || rol == 'isletme') {
            _aktifKullanici = kullanici;
            return true;
          } else {
            print("HATA: Oyuncu hesabı işletme panelinden giremez!");
            return false;
          }
        } 
        // 2. Durum: Oyuncu Kapısından Girmeye Çalışıyor
        else {
          // Sadece 'oyuncu' girebilir (Adminler oyuncu tarafından giremez diyelim veya girebilsin istersen burayı açabiliriz)
          if (rol == 'oyuncu') {
            _aktifKullanici = kullanici;
            return true;
          } else {
            print("HATA: İşletme hesabı oyuncu panelinden giremez!");
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