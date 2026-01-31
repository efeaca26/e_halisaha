class OyuncuModeli {
  final String isim;
  final String mevkii; // Kaleci, Defans, Forvet
  final double ucret; // Maç başı istediği para
  final double puan;  // 5 üzerinden yıldız
  final String resimUrl; // Profil fotosu (Varsayılan internetten)

  OyuncuModeli({
    required this.isim,
    required this.mevkii,
    required this.ucret,
    required this.puan,
    required this.resimUrl,
  });
}