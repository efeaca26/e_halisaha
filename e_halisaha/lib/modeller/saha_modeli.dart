class SahaModeli {
  final String id;
  final String isim;
  final String ilce;
  final String tamKonum;
  final double fiyat;
  final double kapora;
  final String resimYolu;
  final double puan;
  final List<String> ozellikler;
  final String? isletmeSahibiEmail;

  SahaModeli({
    required this.id,
    required this.isim,
    required this.ilce,
    required this.tamKonum,
    required this.fiyat,
    required this.kapora,
    required this.resimYolu,
    required this.puan,
    required this.ozellikler,
    this.isletmeSahibiEmail,
  });
}