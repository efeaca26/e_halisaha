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
  final String? ownerId;

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
    this.ownerId,
  });

  factory SahaModeli.fromMap(Map<String, dynamic> map) {
    return SahaModeli(
      id: map['id'].toString(),
      isim: map['isim'] ?? "İsimsiz Saha",
      fiyat: map['fiyat'] ?? 0.0,
      kapora: map['kapora'] ?? 0.0,
      ilce: map['ilce'] ?? "Merkez",
      tamKonum: map['tamKonum'] ?? "Konum belirtilmedi",
      puan: map['puan'] ?? 4.5,
      resimYolu: map['resimYolu'] ?? "assets/resimler/saha1.png",
      ozellikler: List<String>.from(map['ozellikler'] ?? []),
      isletmeSahibiEmail: map['isletmeSahibiEmail'] ?? "",
      ownerId: map['ownerId']?.toString(),
    );
  }
}