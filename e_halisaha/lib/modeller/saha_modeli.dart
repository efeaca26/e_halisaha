class SahaModeli {
  final String id;
  final String isim;
  final double fiyat;
  final double kapora;
  final String ilce;
  final String tamKonum;
  final double puan;
  final String resimYolu;
  final List<String> ozellikler;
  final String isletmeSahibiEmail;

  SahaModeli({
    required this.id,
    required this.isim,
    required this.fiyat,
    required this.kapora,
    required this.ilce,
    required this.tamKonum,
    required this.puan,
    required this.resimYolu,
    required this.ozellikler,
    required this.isletmeSahibiEmail,
  });

  factory SahaModeli.fromJson(Map<String, dynamic> json) {
    return SahaModeli(
      id: json['pitchId'].toString(),
      isim: json['pitchName'] ?? "İsimsiz Saha",
      fiyat: double.tryParse(json['pricePerHour'].toString()) ?? 0.0,
      kapora: (double.tryParse(json['pricePerHour'].toString()) ?? 0.0) * 0.3, // %30 Kapora
      ilce: json['location'] ?? "Belirtilmedi",
      tamKonum: json['location'] ?? "Konum Yok",
      puan: 4.5, 
      resimYolu: "assets/resimler/saha1.png", 
      ozellikler: ["Otopark", "Duş", "Kafeterya"], 
      isletmeSahibiEmail: "",
    );
  }
}