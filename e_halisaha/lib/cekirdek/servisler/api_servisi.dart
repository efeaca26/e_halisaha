import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'kimlik_servisi.dart';

class ApiServisi {
  static const String _baseUrl = "http://ehalisaha.com.tr:3000/api";

  Future<Map<String, String>> _headers() async {
    String? token = await KimlikServisi.tokenGetir();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  Future<Map<String, dynamic>?> girisYap(String email, String password) async {
    try {
      final url = Uri.parse("$_baseUrl/auth/login");
      print("İstek atılan adres: $url"); // Hangi URL'ye gidiyoruz?

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("Sunucu Yanıt Kodu: ${response.statusCode}");
      print("Sunucu Yanıt İçeriği: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await KimlikServisi.girisYapveKaydet(data);
        return data;
      }
      return null;
    } catch (e) { 
      print("API Servis Hatası: $e");
      return null; 
    }
  }

  Future<List<dynamic>> tumSahalariGetir() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/pitches'));
      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        List<dynamic> sahalar = resData['data'] ?? [];
        return sahalar.map((saha) => {
          "id": saha['id'].toString(),
          "isim": saha['name'],
          "fiyat": double.parse(saha['price'].toString()),
          "kapora": double.parse(saha['deposit'].toString()),
          "tamKonum": saha['address'],
          "ilce": (saha['address'] as String).split(',').last.trim(),
          "puan": 4.5,
          "resimYolu": "assets/resimler/saha1.png",
          "ozellikler": ["Otopark", "Kantin"],
        }).toList();
      }
    } catch (e) { debugPrint("Hata: $e"); }
    return [];
  }

  // REZERVASYON İŞLEMLERİ
  Future<List<int>> doluSaatleriGetir(int sahaId, DateTime tarih) async {
    try {
      String t = tarih.toIso8601String().split('T')[0];
      final r = await http.get(Uri.parse('$_baseUrl/bookings/availability/$sahaId/$t'));
      if (r.statusCode == 200) {
        final d = jsonDecode(r.body)['data'] as List;
        return d.where((s) => s['available'] == false)
                .map<int>((s) => int.parse(s['time'].split(':')[0])).toList();
      }
    } catch (e) { return []; }
    return [];
  }

  Future<bool> rezervasyonYap(int sahaId, int userId, DateTime tarih, int saat, String notlar) async {
    try {
      String d = tarih.toIso8601String().split('T')[0];
      String start = "${d}T${saat.toString().padLeft(2, '0')}:00:00";
      String end = "${d}T${(saat+1).toString().padLeft(2, '0')}:00:00";
      final r = await http.post(Uri.parse('$_baseUrl/bookings'), headers: await _headers(),
        body: jsonEncode({"pitchId": sahaId, "startTime": start, "endTime": end, "paymentMethod": "online"}));
      return r.statusCode == 200 || r.statusCode == 201;
    } catch (e) { return false; }
  }

  Future<List<dynamic>> randevularimiGetir(int userId) async {
    try {
      final r = await http.get(Uri.parse('$_baseUrl/bookings/user'), headers: await _headers());
      return jsonDecode(r.body)['data'] ?? [];
    } catch (e) { return []; }
  }

  // ADMIN VE KULLANICI İŞLEMLERİ
  Future<List<dynamic>> tumKullanicilariGetir() async {
    try {
      final r = await http.get(Uri.parse('$_baseUrl/users'), headers: await _headers());
      return jsonDecode(r.body)['data'] ?? [];
    } catch (e) { return []; }
  }

  Future<bool> kullaniciBilgileriniGuncelle(int id, Map<String, dynamic> veriler) async {
    try {
      final r = await http.put(Uri.parse('$_baseUrl/users/$id'), headers: await _headers(), body: jsonEncode(veriler));
      return r.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<bool> bilgileriGuncelle(int id, String ad, String email, String tel, String sifre) async {
    return await kullaniciBilgileriniGuncelle(id, {"name": ad, "email": email, "phone": tel});
  }

  Future<bool> kullaniciRoluGuncelle(int id, String rol) async => await kullaniciBilgileriniGuncelle(id, {"role": rol});

  Future<bool> sahaSil(int id) async {
    try {
      final r = await http.delete(Uri.parse('$_baseUrl/pitches/$id'), headers: await _headers());
      return r.statusCode == 200 || r.statusCode == 204;
    } catch (e) { return false; }
  }

  Future<List<dynamic>> sahaRandevulariniGetir(String id) async {
    try {
      final r = await http.get(Uri.parse('$_baseUrl/bookings/facility/$id'), headers: await _headers());
      return jsonDecode(r.body)['data'] ?? [];
    } catch (e) { return []; }
  }

  // KART İŞLEMLERİ (List<dynamic> dönmeli)
  Future<List<dynamic>> kartlariGetir(int id) async => [];
  Future<bool> kartSil(int id) async => true;
  Future<bool> kartEkle(int id, String a, String n) async => true;

  // SİLME İŞLEMLERİ
  Future<bool> kullaniciSil(int id) async {
    try {
      final r = await http.delete(Uri.parse('$_baseUrl/users/$id'), headers: await _headers());
      return r.statusCode == 200;
    } catch (e) { return false; }
  }
  Future<bool> hesabiSil(int id) async => await kullaniciSil(id);
  Future<Map<String, dynamic>?> kullaniciGetir(int id) async => null;
}