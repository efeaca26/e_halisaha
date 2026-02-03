import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServisi {
  // 🔴 ÖNEMLİ: Buraya kiraladığın VDS'in IP adresini yazacaksın.
  // Örnek: "http://195.142.10.20/api"
  // API henüz kurulu olmadığı için burası şimdilik çalışmaz ama hazırlık tamam.
  static const String _baseUrl = "http://SENIN_SUNUCU_IP_ADRESIN/api";

  // --- GİRİŞ YAPMA İŞLEMİ ---
  static Future<bool> girisYap(String email, String sifre, bool isletmeModu) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/giris');
      
      print("İstek gönderiliyor: $url"); // Konsolda görmek için

      final cevap = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "sifre": sifre,
          "rol": isletmeModu ? "isletme" : "oyuncu",
        }),
      );

      print("Sunucu Cevabı: ${cevap.statusCode} - ${cevap.body}");

      if (cevap.statusCode == 200) {
        return true; // Giriş Başarılı
      } else {
        return false; // Şifre yanlış veya kullanıcı yok
      }
    } catch (e) {
      print("Bağlantı Hatası: $e");
      // Sunucu kapalıysa veya internet yoksa buraya düşer
      return false; 
    }
  }

  // --- KAYIT OLMA İŞLEMİ ---
  static Future<bool> kayitOl(String isim, String email, String sifre, bool isletmeModu) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/kayit');
      
      final cevap = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "adSoyad": isim,
          "email": email,
          "sifre": sifre,
          "rol": isletmeModu ? "isletme" : "oyuncu",
        }),
      );

      if (cevap.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Kayıt Hatası: $e");
      return false;
    }
  }
}