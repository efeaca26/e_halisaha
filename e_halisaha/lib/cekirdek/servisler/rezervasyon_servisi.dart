import '../../modeller/saha_modeli.dart';

class RezervasyonServisi {
  // Hafızadaki rezervasyon listesi (Uygulama kapanınca silinir)
  static final List<Map<String, dynamic>> _rezervasyonlar = [];

  // Rezervasyon Ekleme
  static void rezervasyonEkle({
    required SahaModeli saha, 
    required DateTime tarih, 
    required String saat
  }) {
    _rezervasyonlar.add({
      'saha': saha,
      'tarih': tarih,
      'saat': saat,
      'ucret': saha.fiyat,
      'durum': 'Onaylandı'
    });
  }

  // Listeyi Getirme (En son eklenen en üstte görünsün diye ters çeviriyoruz)
  static List<Map<String, dynamic>> get rezervasyonlar => _rezervasyonlar.reversed.toList();
}