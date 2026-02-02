import '../../modeller/saha_modeli.dart';

class SahteVeriServisi {
  static final List<SahaModeli> _sahalar = [
    SahaModeli(
      id: "1",
      isim: "Zirve Halı Saha",
      ilce: "Kadıköy",
      tamKonum: "Caferağa Mah. Moda Cad., İstanbul",
      fiyat: 1200,
      kapora: 360,
      puan: 4.8,
      resimYolu: "assets/resimler/saha1.png",
      ozellikler: ["Duş", "Otopark"],
      isletmeSahibiEmail: "admin@ehalisaha.com",
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
      ozellikler: ["Duş", "Kafeterya"],
      isletmeSahibiEmail: "yildizspor@ehalisaha.com",
    ),
    SahaModeli(
      id: "3",
      isim: "Arena 1907",
      ilce: "Ataşehir",
      tamKonum: "Barbaros Mah., İstanbul",
      fiyat: 1500,
      kapora: 450,
      puan: 5.0,
      resimYolu: "assets/resimler/saha3.png",
      ozellikler: ["Otopark", "Tribün"],
      isletmeSahibiEmail: "admin@ehalisaha.com",
    ),
  ];

  static List<SahaModeli> sahalariGetir() { return _sahalar; }

  
  static void sahaEkle(SahaModeli yeniSaha) {
    _sahalar.add(yeniSaha);
  }

  static void sahaSil(SahaModeli saha) { _sahalar.remove(saha); }

  static void sahaGuncelle(SahaModeli eskiSaha, String yeniIsim, double yeniFiyat) {
    int index = _sahalar.indexOf(eskiSaha);
    if (index != -1) {
      _sahalar[index] = SahaModeli(
        id: eskiSaha.id,
        isim: yeniIsim,
        fiyat: yeniFiyat,
        kapora: yeniFiyat * 0.30,
        ilce: eskiSaha.ilce,
        tamKonum: eskiSaha.tamKonum,
        puan: eskiSaha.puan,
        resimYolu: eskiSaha.resimYolu,
        ozellikler: eskiSaha.ozellikler,
        isletmeSahibiEmail: eskiSaha.isletmeSahibiEmail, // Sahibi değişmez
      );
    }
  }
}