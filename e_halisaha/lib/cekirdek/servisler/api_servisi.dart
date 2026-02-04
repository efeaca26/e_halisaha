// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServisi {
  static const String _baseUrl = "http://185.157.46.167/api"; 

  // --- GİRİŞ YAP ---
  static Future<bool> girisYap(String email, String sifre, bool isletmeModu) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/giris'); 
      
      print("İstek gönderiliyor: $url"); 

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
        return true; 
      } else {
        return false; 
      }
    } catch (e) {
      print("Bağlantı Hatası: $e");
      return false; 
    }
  }

  // --- KAYIT OL ---
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
        print("Kayıt Hatası: ${cevap.body}");
        return false;
      }
    } catch (e) {
      print("Kayıt Bağlantı Hatası: $e");
      return false;
    }
  }
}