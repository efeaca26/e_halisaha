class KimlikServisi {
  // --- HAFIZADAKİ KULLANICILAR ---
  // Uygulama kapanınca bunlar silinir (Veritabanı olmadığı için)
  // Ama Admin hesabı hep burada kalacak.
  static final List<Map<String, dynamic>> _kullanicilar = [
    {
      'isim': 'Sistem Yöneticisi',
      'email': 'admin@ehalisaha.com',
      'sifre': 'admin123',
      'isletmeModu': true, // Admin bir işletme sahibidir
    }
  ];

  // --- GİRİŞ YAPMA FONKSİYONU ---
  static Future<bool> girisYap(String email, String sifre) async {
    // Gerçekçilik için 1 saniye bekletelim (İnternet varmış gibi)
    await Future.delayed(const Duration(seconds: 1));

    // Listede bu email ve şifreye sahip biri var mı?
    for (var kullanici in _kullanicilar) {
      if (kullanici['email'] == email && kullanici['sifre'] == sifre) {
        return true; // Giriş Başarılı
      }
    }
    return false; // Hatalı Bilgi
  }

  // --- KAYIT OLMA FONKSİYONU ---
  static Future<bool> kayitOl(String isim, String email, String sifre, bool isletmeModu) async {
    await Future.delayed(const Duration(seconds: 1));

    // Bu email daha önce alınmış mı?
    for (var kullanici in _kullanicilar) {
      if (kullanici['email'] == email) {
        return false; // Zaten kayıtlı
      }
    }

    // Yeni kullanıcıyı listeye ekle
    _kullanicilar.add({
      'isim': isim,
      'email': email,
      'sifre': sifre,
      'isletmeModu': isletmeModu,
    });

    return true; // Kayıt Başarılı
  }
}