class KimlikServisi {
  // --- HAFIZADAKİ KULLANICILAR ---
  static final List<Map<String, dynamic>> _kullanicilar = [
    {
      'isim': 'Sistem Yöneticisi',
      'email': 'admin@ehalisaha.com',
      'sifre': 'admin123',
      'isletmeModu': true,
      'dogumTarihi': '01.01.1990',
      'telefon': '+90 555 000 00 00'
    }
  ];

  // *** YENİ: Şu an giriş yapmış olan kullanıcıyı burada tutacağız ***
  static Map<String, dynamic>? aktifKullanici;

  // --- GİRİŞ YAPMA ---
  static Future<bool> girisYap(String email, String sifre) async {
    await Future.delayed(const Duration(seconds: 1));

    for (var kullanici in _kullanicilar) {
      if (kullanici['email'] == email && kullanici['sifre'] == sifre) {
        aktifKullanici = kullanici; // <--- Giriş yapanı hafızaya al
        return true;
      }
    }
    return false;
  }

  // --- KAYIT OLMA ---
  static Future<bool> kayitOl(String isim, String email, String sifre, bool isletmeModu) async {
    await Future.delayed(const Duration(seconds: 1));

    for (var kullanici in _kullanicilar) {
      if (kullanici['email'] == email) return false;
    }

    // Yeni kullanıcı oluştur
    Map<String, dynamic> yeniKullanici = {
      'isim': isim,
      'email': email,
      'sifre': sifre,
      'isletmeModu': isletmeModu,
      'dogumTarihi': 'Belirtilmedi', // Başlangıçta boş
      'telefon': '+90 5XX XXX XX XX'
    };

    _kullanicilar.add(yeniKullanici);
    aktifKullanici = yeniKullanici; // <--- Kayıt olanı direkt içeri al
    return true;
  }

  // --- ÇIKIŞ YAPMA ---
  static void cikisYap() {
    aktifKullanici = null;
  }
}