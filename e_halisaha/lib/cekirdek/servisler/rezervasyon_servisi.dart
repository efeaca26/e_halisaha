class RezervasyonServisi {
  // FORMAT: "sahaID_tarih_saat": "DURUM | NOT"
  static final Map<String, String> _rezervasyonlar = {
    "1_${_bugunFormat}_22:00": "dolu | Örnek Dolu Kayıt",
  };

  static String get _bugunFormat => DateTime.now().toString().substring(0, 10);

  // --- DURUM SORGULA ---
  static String saatDurumuGetir(String sahaId, DateTime tarih, String saat) {
    String tarihStr = tarih.toString().substring(0, 10);
    String key = "${sahaId}_${tarihStr}_$saat";
    
    if (!_rezervasyonlar.containsKey(key)) return "bos";

    String veri = _rezervasyonlar[key]!;
    if (veri.startsWith("beklemede")) return "beklemede";
    return "dolu";
  }

  // --- REZERVASYON YAP ---
  static void rezervasyonYap(String sahaId, DateTime tarih, String saat, String not, {bool beklemede = false}) {
    String tarihStr = tarih.toString().substring(0, 10);
    String key = "${sahaId}_${tarihStr}_$saat";
    
    String prefix = beklemede ? "beklemede" : "dolu";
    _rezervasyonlar[key] = "$prefix | $not";
  }

  // --- ONAYLA ---
  static void rezervasyonuOnayla(String sahaId, DateTime tarih, String saat) {
    String tarihStr = tarih.toString().substring(0, 10);
    String key = "${sahaId}_${tarihStr}_$saat";
    
    if (_rezervasyonlar.containsKey(key)) {
      String mevcutNot = _rezervasyonlar[key]!.split('|').last.trim();
      _rezervasyonlar[key] = "dolu | $mevcutNot (Onaylandı)";
    }
  }

  // --- SİL / İPTAL ---
  static void rezervasyonIptal(String sahaId, DateTime tarih, String saat) {
    String tarihStr = tarih.toString().substring(0, 10);
    String key = "${sahaId}_${tarihStr}_$saat";
    _rezervasyonlar.remove(key);
  }

  // --- EKSİK OLAN GETTER BURAYA EKLENDİ ---
  // Profil sayfasında "Geçmiş Maçlar" listesi için gerekli
  static List<Map<String, dynamic>> get kullaniciRezervasyonlari {
    List<Map<String, dynamic>> liste = []; 
    
    _rezervasyonlar.forEach((key, value) {
      // Key formatı: "1_2023-10-25_19:00"
      List<String> parcalar = key.split('_');
      if (parcalar.length == 3) {
        String sahaId = parcalar[0];
        String tarih = parcalar[1];
        String saat = parcalar[2];
        
        // Value formatı: "dolu | Not..."
        List<String> detaylar = value.split('|');
        String durumKod = detaylar[0].trim();
        
        liste.add({
          'sahaId': sahaId,
          'sahaAd': "Saha $sahaId", // Şimdilik ID yazıyoruz, ileride gerçek ismi çekeriz
          'tarih': tarih,
          'saat': saat,
          'durum': durumKod == 'beklemede' ? 'Onay Bekliyor' : 'Onaylandı',
          'ucret': 0, 
        });
      }
    });
    
    return liste;
  }
}