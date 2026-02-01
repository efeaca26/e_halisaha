import '../../modeller/saha_modeli.dart';

class SahteVeriServisi {
  // Veriler artık 'final' değil, değiştirilebilir liste
  static final List<SahaModeli> _sahalar = [
    SahaModeli(
      id: "1", // YENİ: ID eklendi
      isim: "Zirve Halı Saha",
      // il: "İstanbul", // SİLİNDİ: Artık modelde yok
      ilce: "Kadıköy",
      tamKonum: "Caferağa Mah. Moda Cad. No:12, İstanbul", // İli buraya ekledik
      fiyat: 1200,
      kapora: 360, // YENİ: Fiyatın %30'u
      puan: 4.8,
      resimYolu: "assets/resimler/saha1.png",
      ozellikler: ["Duş", "Otopark", "Kafeterya", "Wi-Fi"], // YENİ: Özellikler
    ),
    SahaModeli(
      id: "2",
      isim: "Yıldız Spor Tesisleri",
      ilce: "Üsküdar",
      tamKonum: "Mimar Sinan Mah. Sahil Yolu, İstanbul",
      fiyat: 900,
      kapora: 270,
      puan: 4.5,
      resimYolu: "assets/resimler/saha2.png",
      ozellikler: ["Duş", "Otopark"],
    ),
    SahaModeli(
      id: "3",
      isim: "Arena 1907",
      ilce: "Ataşehir",
      tamKonum: "Barbaros Mah. Lale Sok., İstanbul",
      fiyat: 1500,
      kapora: 450,
      puan: 5.0,
      resimYolu: "assets/resimler/saha3.png",
      ozellikler: ["Duş", "Otopark", "Kafeterya", "Tribün"],
    ),
  ];

  // Listeyi Getir
  static List<SahaModeli> sahalariGetir() {
    return _sahalar;
  }

  // --- ADMİN İŞLEMLERİ ---

  // Saha Sil
  static void sahaSil(SahaModeli saha) {
    _sahalar.remove(saha);
  }

  // Saha Güncelle (Fiyat vb.)
  static void sahaGuncelle(SahaModeli eskiSaha, String yeniIsim, double yeniFiyat) {
    int index = _sahalar.indexOf(eskiSaha);
    if (index != -1) {
      _sahalar[index] = SahaModeli(
        id: eskiSaha.id, // YENİ: Eski ID korunur
        isim: yeniIsim, // Güncellenen İsim
        fiyat: yeniFiyat, // Güncellenen Fiyat
        kapora: yeniFiyat * 0.30, // Fiyat değişince kapora da güncellensin
        
        // Diğerleri aynı kalsın
        ilce: eskiSaha.ilce,
        tamKonum: eskiSaha.tamKonum,
        puan: eskiSaha.puan,
        resimYolu: eskiSaha.resimYolu,
        ozellikler: eskiSaha.ozellikler, // YENİ: Eski özellikler korunur
      );
    }
  }
}