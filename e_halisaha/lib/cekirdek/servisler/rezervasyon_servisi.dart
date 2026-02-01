import 'kimlik_servisi.dart';

class RezervasyonServisi {
  // SAHTE VERİTABANI: { "sahaID_tarih_saat": "Durum" }
  // Örnek Anahtar: "1_2023-10-25_19:00"
  // Örnek Değer: "dolu" veya "Rezerve Eden: Ahmet Yılmaz"
  static final Map<String, String> _rezervasyonlar = {
    // Başlangıçta dolu gözüksün diye örnek bir veri
    "1_${_bugunFormat}_21:00": "dolu", 
  };

  static String get _bugunFormat => DateTime.now().toString().substring(0, 10);

  // --- SAAT DURUMUNU GETİR ---
  static String saatDurumuGetir(String sahaId, DateTime tarih, String saat) {
    String tarihStr = tarih.toString().substring(0, 10);
    String key = "${sahaId}_${tarihStr}_$saat";
    
    // Eğer listede varsa durumu döndür, yoksa "bos"tur.
    return _rezervasyonlar.containsKey(key) ? "dolu" : "bos";
  }

  // --- REZERVASYON YAP (VEYA MANUEL EKLE) ---
  static void rezervasyonYap(String sahaId, DateTime tarih, String saat, String not) {
    String tarihStr = tarih.toString().substring(0, 10);
    String key = "${sahaId}_${tarihStr}_$saat";
    
    _rezervasyonlar[key] = not; // "dolu" veya müşteri notu
    print("Rezervasyon Eklendi: $key -> $not");
  }

  // --- REZERVASYON İPTAL ET (SİL) ---
  static void rezervasyonIptal(String sahaId, DateTime tarih, String saat) {
    String tarihStr = tarih.toString().substring(0, 10);
    String key = "${sahaId}_${tarihStr}_$saat";
    
    _rezervasyonlar.remove(key); // Listeden siler, yani "bos" olur
    print("Rezervasyon Silindi: $key");
  }

  // --- KULLANICININ GEÇMİŞ REZERVASYONLARI ---
  static List<Map<String, dynamic>> get kullaniciRezervasyonlari {
    // Burası şimdilik boş, ileride doldurulabilir
    return [];
  }
}