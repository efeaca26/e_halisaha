import '../../modeller/saha_modeli.dart';
import 'kimlik_servisi.dart'; // <--- Kimlik servisini ekledik (Kimin yaptığını bilmek için)

class RezervasyonServisi {
  // Tüm rezervasyonların tutulduğu ana havuz
  static final List<Map<String, dynamic>> _rezervasyonlar = [];

  // --- REZERVASYON EKLE (Kullanıcı Bilgisiyle) ---
  static void rezervasyonEkle({
    required SahaModeli saha, 
    required DateTime tarih, 
    required String saat
  }) {
    // Şu an giriş yapmış olan kişiyi bul
    final aktifKullanici = KimlikServisi.aktifKullanici;
    
    // Eğer kimse yoksa (Hata durumu) işlem yapma
    if (aktifKullanici == null) return;

    _rezervasyonlar.add({
      'kullaniciEmail': aktifKullanici['email'], // <--- KİMİN YAPTIĞINI KAYDEDİYORUZ
      'saha': saha,
      'tarih': tarih,
      'saat': saat,
      'ucret': saha.fiyat,
      'durum': 'Onaylandı'
    });
  }

  // --- 1. TÜM REZERVASYONLAR (Takvim Doluluk Kontrolü İçin) ---
  // Burası haritada kırmızı/yeşil göstermek için kullanılır. 
  // Herkesin rezervasyonunu görmeliyiz ki o saat dolu mu bilelim.
  static List<Map<String, dynamic>> get tumRezervasyonlar => _rezervasyonlar;

  // --- 2. KULLANICININ REZERVASYONLARI (Profil İçin) ---
  // Burası sadece "Benim Rezervasyonlarım" ekranı içindir.
  static List<Map<String, dynamic>> get kullaniciRezervasyonlari {
    final aktifKullanici = KimlikServisi.aktifKullanici;
    if (aktifKullanici == null) return [];

    // Sadece benim emailim ile eşleşenleri getir
    return _rezervasyonlar
        .where((rez) => rez['kullaniciEmail'] == aktifKullanici['email'])
        .toList()
        .reversed // En yenisi en üstte olsun
        .toList();
  }
}