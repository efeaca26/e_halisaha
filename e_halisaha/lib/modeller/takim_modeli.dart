class TakimModeli {
  final String isim;
  final String kaptan;
  final double seviye; // 5 üzerinden yıldız
  final String logoUrl; // Takım logosu
  final int oyuncuSayisi; // 7v7, 11v11 tercihi

  TakimModeli({
    required this.isim,
    required this.kaptan,
    required this.seviye,
    required this.logoUrl,
    required this.oyuncuSayisi,
  });
}