import 'dart:convert';
import 'package:http/http.dart' as http;
import 'kimlik_servisi.dart'; // Kimlik servisi importu şart

class ApiServisi {
  // Emülatör için 10.0.2.2, Port: 5216 (Senin verdiğin)
  static const String _baseUrl = "http://10.0.2.2:5216/api";

  // --- GİRİŞ YAP ---
  Future<bool> girisYap(String email, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/Users/Login');
      
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Token ve kullanıcı bilgilerini telefona kaydet
        await KimlikServisi.girisYapveKaydet(data);
        return true;
      }
      return false;
    } catch (e) {
      print("Giriş Hatası: $e");
      return false;
    }
  }

  // --- KAYIT OL ---
  Future<bool> kayitOl(String adSoyad, String telefon, String sifre, bool isletmeMi) async {
    try {
      final url = Uri.parse('$_baseUrl/Users');
      
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": adSoyad,
          "email": "$telefon@ehali.com", // E-posta yerine telefon formatı
          "passwordHash": sifre,
          "phoneNumber": telefon,
          "role": isletmeMi ? "isletme" : "oyuncu",
          "createdAt": DateTime.now().toIso8601String()
        }),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Kayıt Hatası: $e");
      return false;
    }
  }

  // --- DİĞER METOTLAR ---

  Future<List<dynamic>> sahalariGetir() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/Pitches'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) { print("Saha Hatası: $e"); }
    return [];
  }

  Future<bool> rezervasyonYap(int sahaId, int userId, DateTime tarih, int saat, String notlar) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/Reservations'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "pitchId": sahaId, "userId": userId, "rezDate": tarih.toIso8601String(),
          "rezHour": saat, "note": notlar, "status": 1
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) { return false; }
  }

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
    } catch (e) { print("Saat Hatası: $e"); }
    return [];
  }

  Future<List<dynamic>> randevularimiGetir(int userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/Reservations'));
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        return list.where((r) => r['userId'] == userId).toList();
      }
    } catch (e) { print("Geçmiş Hatası: $e"); }
    return [];
  }

  Future<bool> bilgileriGuncelle(int userId, String ad, String email, String tel, String sifre) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/Users/$userId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId, "fullName": ad, "email": email, "phoneNumber": tel, 
          "passwordHash": sifre, "createdAt": DateTime.now().toIso8601String()
        }),
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<Map<String, dynamic>?> kullaniciGetir(int userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/Users/$userId'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) { print("Kullanıcı Getirme Hatası: $e"); }
    return null;
  }

  // --- YENİ EKLENENLER (ADMİN İÇİN) ---
  Future<List<dynamic>> tumKullanicilariGetir() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/Users'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) { print("Kullanıcı Listesi Hatası: $e"); }
    return [];
  }

  Future<bool> rolGuncelle(int userId, Map<String, dynamic> veriler, String yeniRol) async {
    try {
      veriler['userId'] = userId;
      veriler['role'] = yeniRol;
      final response = await http.put(
        Uri.parse('$_baseUrl/Users/$userId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(veriler),
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) { return false; }
  }
  
  // Kart işlemleri
  Future<List<dynamic>> kartlariGetir(int userId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/SavedCards?userId=$userId'));
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {} return [];
  }
  Future<bool> kartEkle(int userId, String ad, String no) async {
    try {
      final response = await http.post(Uri.parse('$_baseUrl/SavedCards'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"userId": userId, "cardAlias": ad, "cardNumber": no}));
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