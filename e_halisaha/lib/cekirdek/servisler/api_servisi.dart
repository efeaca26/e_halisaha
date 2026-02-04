// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'kimlik_servisi.dart';

class ApiServisi {
  // Karşı tarafın API adresi
  static const String _baseUrl = "http://api.ehalisaha.com.tr"; 

  // --- YARDIMCI: Header Üretici (Token Ekler) ---
  static Future<Map<String, String>> _headerGetir() async {
    String? token = await KimlikServisi.tokenGetir();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token", // İşte "Kutsal" kısım burası!
    };
  }

  // --- GİRİŞ YAP ---
  static Future<bool> girisYap(String girisBilgisi, String sifre) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/login');
      
      // Giriş verisini hazırla
      Map<String, dynamic> bodyVerisi = {"password": sifre};
      if (girisBilgisi.contains('@')) {
        bodyVerisi['email'] = girisBilgisi;
      } else {
        bodyVerisi['phone'] = girisBilgisi;
      }

      final cevap = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(bodyVerisi),
      );

      if (cevap.statusCode == 200) {
        final veri = jsonDecode(cevap.body);
        if (veri['success'] == true) {
          // ✅ YENİ: Token'ı telefona kaydediyoruz
          await KimlikServisi.girisYapveKaydet(veri);
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Giriş Hatası: $e");
      return false;
    }
  }

  // --- KAYIT OL (Değişiklik yok) ---
  static Future<bool> kayitOl(String adSoyad, String telefon, String sifre, bool isletmeModu) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/register');
      final cevap = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": adSoyad,
          "phone": telefon,
          "password": sifre,
          "role": isletmeModu ? "SahaSahibi" : "User"
        }),
      );
      
      if (cevap.statusCode == 201 || cevap.statusCode == 200) {
        final veri = jsonDecode(cevap.body);
        return veri['success'] == true;
      }
      return false;
    } catch (e) {
      print("Kayıt Hatası: $e");
      return false;
    }
  }

  // --- ÖRNEK: PROFİL GETİR (Token Kullanımı) ---
  // İleride profil sayfasını yaparken bunu kullanacaksın
  static Future<Map<String, dynamic>?> profilGetir() async {
    try {
      final url = Uri.parse('$_baseUrl/auth/profile');
      
      // Token'lı header alıyoruz
      final headers = await _headerGetir(); 

      final cevap = await http.get(url, headers: headers);

      if (cevap.statusCode == 200) {
         final veri = jsonDecode(cevap.body);
         return veri['data'];
      }
    } catch (e) {
      print("Profil Hatası: $e");
    }
    return null;
  }
}