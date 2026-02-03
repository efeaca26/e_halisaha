import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServisi {
  // DİKKAT: Buraya kiraladığın sunucunun IP adresini yazmalısın.
  // Örnek: "http://185.123.45.67/api"
  // Eğer sunucuda henüz API yoksa burası çalışmaz.
    } catch (e) {
      print("Sunucuya bağlanılamadı: $e");
      return false;
    }
  }

  // --- KAYIT OLMA FONKSİYONU ---
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
      print("Hata: $e");
      return false;
    }
  }
}