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

  factory SahaModeli.fromMap(Map<String, dynamic> map) {
  return SahaModeli(
    id: map['id'],
    isim: map['isim'],
    fiyat: map['fiyat'],
    kapora: map['kapora'],
    ilce: map['ilce'],
    tamKonum: map['tamKonum'],
    puan: map['puan'],
    resimYolu: map['resimYolu'],
    ozellikler: List<String>.from(map['ozellikler']),
    isletmeSahibiEmail: map['isletmeSahibiEmail'] ?? "",
  );
}
}