class KimlikServisi {
  // --- HAFIZADAKİ KULLANICILAR ---
  static final List<Map<String, dynamic>> _kullanicilar = [
    // 1. ADMIN HESABI (Yönetici)
    {
      'isim': 'Sistem Yöneticisi',
      'email': 'admin@ehalisaha.com',
      'sifre': 'admin123',
      'isletmeModu': true,
      'dogumTarihi': '01.01.1990',
      'telefon': '+90 555 000 00 00',
      'rol': 'admin' // <--- Bu kişi ADMIN
    },
    // 2. EFE ACAR (Normal Kullanıcı)
    {
      'isim': 'Efe Acar',
      'email': 'efe.acar@ademceylantk.com.tr',
      'sifre': 'acftk123',
      'isletmeModu': false,
      'dogumTarihi': '01.01.2005',
      'telefon': '+90 555 123 45 67',
      'rol': 'oyuncu' // <--- Bu kişi OYUNCU (Yetkisiz)
    }
  ];

  // Aktif kullanıcıyı burada tutuyoruz
  static Map<String, dynamic>? _aktifKullanici;

  // Getter: Dışarıdan okumak için
  static Map<String, dynamic>? get aktifKullanici => _aktifKullanici;

  // --- GİRİŞ YAPMA ---
  static Future<bool> girisYap(String email, String sifre) async {
    await Future.delayed(const Duration(seconds: 1)); // Bekleme simülasyonu

    for (var kullanici in _kullanicilar) {
      if (kullanici['email'] == email && kullanici['sifre'] == sifre) {
        _aktifKullanici = kullanici; // Giriş yapanı hafızaya al
        return true;
      }
    }
    return false;
  }

  // --- KAYIT OLMA ---
  static Future<bool> kayitOl(String isim, String email, String sifre, bool isletmeModu) async {
    await Future.delayed(const Duration(seconds: 1));

    // E-posta kontrolü
    for (var kullanici in _kullanicilar) {
      if (kullanici['email'] == email) return false;
    }

    // Yeni kullanıcı (Varsayılan olarak normal oyuncu olur)
    Map<String, dynamic> yeniKullanici = {
      'isim': isim,
      'email': email,
      'sifre': sifre,
      'isletmeModu': isletmeModu,
      'dogumTarihi': 'Belirtilmedi',
      'telefon': '-',
      'rol': 'oyuncu' // Yeni kayıt olanlar admin olamaz
    };

    _kullanicilar.add(yeniKullanici);
    _aktifKullanici = yeniKullanici;
    return true;
  }

  // --- ÇIKIŞ YAPMA ---
  static void cikisYap() {
    _aktifKullanici = null;
  }

  // --- ADMIN KONTROLÜ ---
  // Eğer giriş yapan kişinin rolü 'admin' ise TRUE döner
  static bool get isAdmin => _aktifKullanici != null && _aktifKullanici!['rol'] == 'admin';
}