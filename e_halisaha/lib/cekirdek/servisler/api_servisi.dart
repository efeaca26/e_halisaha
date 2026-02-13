import 'dart:convert';
import 'package:flutter/foundation.dart'; // debugPrint için
import 'package:http/http.dart' as http;
import 'kimlik_servisi.dart';

class ApiServisi {
  static const String _baseUrl = "https://api.ehalisaha.com.tr/api";

  // ===========================================================================
  // 1. GİRİŞ & KAYIT (GÜNCEL)
  // ===========================================================================

  Future<Map<String, dynamic>?> girisYap(String girisBilgisi, String password) async {
    try {
      final url = Uri.parse("$_baseUrl/Users/Login");
      debugPrint("GİRİŞ DENEMESİ: $url");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "identifier": girisBilgisi,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['user'] == null) return null;

        await KimlikServisi.girisYapveKaydet(data);
        return data; 
      }
      return null;
    } catch (e) {
      debugPrint("Bağlantı Hatası: $e");
      return null;
    }
  }

  Future<bool> kayitOl(String fullName, String email, String password, bool isBusiness, {String? phoneNumber, String? pitchName, String? location}) async {
    try {
      final url = Uri.parse('$_baseUrl/Users');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": fullName,
          "email": email,
          "phoneNumber": (phoneNumber != null && phoneNumber.isNotEmpty) ? phoneNumber : null,
          "password": password,
          "role": isBusiness ? "isletme" : "oyuncu",
          "pitchName": pitchName,
          "location": location,
          "createdAt": DateTime.now().toIso8601String()
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ===========================================================================
  // 2. ESKİ KODLARLA UYUMLULUK (BRIDGE METODLARI) 🛠️
  // Bu bölüm "undefined_method" hatalarını çözer.
  // ===========================================================================

  // Admin Paneli ve Kullanıcı Yönetimi için gerekli
  Future<bool> rolGuncelle(int userId, Map<String, dynamic> ignored, String yeniRol) async {
    return await kullaniciRoluGuncelle(userId, yeniRol);
  }

  // Profil ekranı için gerekli
  Future<bool> bilgileriGuncelle(int userId, String ad, String email, String tel, String sifre) async {
    return await kullaniciBilgileriniGuncelle(userId, {
      "fullName": ad,
      "email": email,
      "phoneNumber": tel
    });
  }

  // Ödeme ve Saha Detay ekranı için gerekli
  Future<bool> rezervasyonYap(int sahaId, int userId, DateTime tarih, int saat, String notlar) async {
    return await randevuOlustur({
      "pitchId": sahaId,
      "userId": userId,
      "rezDate": tarih.toIso8601String(),
      "rezHour": saat,
      "note": notlar,
      "status": 1
    });
  }

  // Eski adlandırma ile çağıran yerler için alias
  Future<List<dynamic>> sahalariGetir() async {
    return await tumSahalariGetir();
  }

  // ===========================================================================
  // 3. ASIL FONKSİYONLAR (MODERN)
  // ===========================================================================

  Future<List<dynamic>> tumSahalariGetir() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/Pitches')); 
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) { return []; }
  }

  Future<bool> randevuOlustur(Map<String, dynamic> randevuVerisi) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/Reservations'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(randevuVerisi),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<bool> kullaniciBilgileriniGuncelle(int id, Map<String, dynamic> veriler) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/Users/AdminUpdate/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(veriler),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) { return false; }
  }

  Future<bool> kullaniciRoluGuncelle(int userId, String yeniRol) async {
    return await kullaniciBilgileriniGuncelle(userId, {"role": yeniRol});
  }

  // --- DİĞER FONKSİYONLAR ---

  Future<List<int>> doluSaatleriGetir(int sahaId, DateTime tarih) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/Reservations'));
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        String tarihStr = tarih.toIso8601String().split('T')[0];
        return list
            .where((r) => r['pitchId'] == sahaId && r['rezDate'].toString().startsWith(tarihStr))
            .map<int>((r) => r['rezHour'] as int)
            .toList();
      }
    } catch (e) {} return [];
  }

  Future<List<dynamic>> randevularimiGetir(int userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/Reservations'));
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        return list.where((r) => r['userId'] == userId).toList();
      }
    } catch (e) {} return [];
  }

  Future<Map<String, dynamic>?> kullaniciGetir(int userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/Users/$userId'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {} return null;
  }
  
  // Admin Metodları
  Future<List<dynamic>> tumKullanicilariGetir() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/Users'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) { return []; }
  }

  Future<List<dynamic>> tumRezervasyonlariGetir() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/Reservations'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) { return []; }
  }

  Future<List<dynamic>> sahaRandevulariniGetir(String sahaId) async {
    try {
      final tumRezervasyonlar = await tumRezervasyonlariGetir();
      return tumRezervasyonlar.where((rez) => rez['pitchId'].toString() == sahaId.toString()).toList();
    } catch (e) { return []; }
  }

  // Silme İşlemleri
  Future<bool> kullaniciSil(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/Users/$id'));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<bool> sahaSil(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/Pitches/$id'));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<bool> rezervasyonSil(int id) async {
      try {
      final response = await http.delete(Uri.parse('$_baseUrl/Reservations/$id'));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<bool> hesabiSil(int userId) async {
    return await kullaniciSil(userId);
  }

  Future<bool> kullaniciyiOnayla(int userId) async {
    return await kullaniciBilgileriniGuncelle(userId, {"isApproved": true});
  }

  // Kart İşlemleri
  Future<List<dynamic>> kartlariGetir(int userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/SavedCards?userId=$userId'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {} return [];
  }
  
  Future<bool> kartEkle(int userId, String ad, String no) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/SavedCards'), 
        headers: {"Content-Type": "application/json"}, 
        body: jsonEncode({"userId": userId, "cardAlias": ad, "cardNumber": no})
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {} return false;
  }
  
  Future<bool> kartSil(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/SavedCards/$id'));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {} return false;
  }
}