class TakimModeli {
  final String id;
  final String isim;
  final String seviye; // Örn: "Amatör", "Dişli", "Pro"
  final double yildiz; // 1-5 arası puan
  final String kaptanId;

  TakimModeli({
    required this.id,
    required this.isim,
    required this.seviye,
    required this.yildiz,
    required this.kaptanId,
  });
}