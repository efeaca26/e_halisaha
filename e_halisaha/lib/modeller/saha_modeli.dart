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
    id: map['id'].toString(),
    isim: map['name'] ?? "İsimsiz Saha",
    fiyat: double.tryParse(map['price'].toString()) ?? 0.0,
    kapora: double.tryParse(map['deposit']?.toString() ?? "0.0") ?? 0.0,
    ilce: (map['address'] as String?)?.split(',').last.trim() ?? "Merkez",
    tamKonum: map['address'] ?? "Konum belirtilmedi",
    puan: 4.5,
    resimYolu: map['image_url'] ?? "assets/resimler/saha1.png",
    ozellikler: ["Otopark", "Kantin", "Soyunma Odası"],
    isletmeSahibiEmail: map['owner_email'] ?? "",
  );
}
}