import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'kimlik_servisi.dart';
import '../../modeller/saha_modeli.dart';

class ApiServisi {
  static const String _baseUrl = "http://185.157.46.167:3000/api";
  static const String _imageBaseUrl = "http://185.157.46.167:3000"; 

  Future<Map<String, String>> _headers() async {
    String? token = await KimlikServisi.tokenGetir();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // --- GÜNCELLENMİŞ KAYIT OLMA FONKSİYONU ---
  Future<bool> kayitOl(String adSoyad, String email, String telefon, String sifre) async {
    try {
      final url = Uri.parse("$_baseUrl/auth/register");
      debugPrint("Kayıt İsteği Başladı: $url");
      
      final bodyData = jsonEncode({
        "fullName": adSoyad,
        "name": adSoyad, // Backend hangisini istiyorsa yakalamak için
        "email": email,
        "phone": telefon,
        "phoneNumber": telefon,
        "password": sifre
        // DİKKAT: 'role' parametresi kaldırıldı. Backend bunu kendisi atamalı.
      });

      debugPrint("Gönderilen Veri: $bodyData");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: bodyData,
      ).timeout(const Duration(seconds: 15)); // Zaman aşımı süresi 15 saniyeye çıkarıldı

      debugPrint("Kayıt Yanıtı: STATÜ: ${response.statusCode} - BODY: ${response.body}");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Kayıt fonksiyonunda KRİTİK HATA veya ZAMAN AŞIMI: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> girisYap(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"login": email, "password": password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await KimlikServisi.girisYapveKaydet(data);
        return data;
      }
      return null;
    } catch (e) { return null; }
  }

  Future<List<dynamic>> tumKullanicilariGetir() async {
    try {
      final r = await http.get(Uri.parse('$_baseUrl/users'), headers: await _headers());
      if (r.statusCode == 200) {
        final Map<String, dynamic> decoded = jsonDecode(r.body);
        return decoded['data'] ?? [];
      }
    } catch (e) { debugPrint("Kullanıcı listesi çekilemedi: $e"); }
    return [];
  }

  Future<bool> kullaniciBilgileriniGuncelle(int id, Map<String, dynamic> veriler) async {
    try {
      final url = Uri.parse('$_baseUrl/users/$id');
      final headers = await _headers();
      final body = jsonEncode(veriler);

      var r = await http.put(url, headers: headers, body: body);
      if (r.statusCode == 404) {
        r = await http.patch(url, headers: headers, body: body);
      }
      return r.statusCode == 200 || r.statusCode == 204;
    } catch (e) { return false; }
  }

  Future<bool> kullaniciRoluGuncelle(int id, String rol) async {
    try {
      final headers = await _headers();
      final body = jsonEncode({'role': rol}); 
      
      final urlRole = Uri.parse('$_baseUrl/users/$id/role');
      var r = await http.put(urlRole, headers: headers, body: body);
      
      if (r.statusCode == 404 || r.statusCode == 405) {
        final url = Uri.parse('$_baseUrl/users/$id');
        r = await http.put(url, headers: headers, body: body);
      }

      debugPrint("Rol Güncelleme Yanıtı: ${r.statusCode} - ${r.body}");
      return r.statusCode == 200 || r.statusCode == 204;
    } catch (e) { 
      debugPrint("Rol güncelleme hatası: $e");
      return false; 
    }
  }

  Future<bool> kullaniciSil(int id) async {
    try {
      final r = await http.delete(Uri.parse('$_baseUrl/users/$id'), headers: await _headers());
      return r.statusCode == 200;
    } catch (e) { return false; }
  }

  Future<List<SahaModeli>> tumSahalariGetir() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/pitches'));
      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        List<dynamic> sahalarJson = resData['data'] ?? [];
        return sahalarJson.map((json) {
          String imgUrl = json['image_url'] ?? "";
          if (imgUrl.isNotEmpty && !imgUrl.startsWith('http')) {
            imgUrl = "$_imageBaseUrl/$imgUrl";
          }

          String ilceBilgisi = json['district'] ?? "";
          if (ilceBilgisi.isEmpty && json['address'] != null) {
            ilceBilgisi = json['address'].toString().split(',')[0].split('/')[0].trim();
          }
          if (ilceBilgisi.isEmpty) ilceBilgisi = "Konum Yok";

          return SahaModeli.fromMap({
            "id": json['id'].toString(),
            "isim": json['name'] ?? "İsimsiz Saha",
            "fiyat": double.tryParse((json['price'] ?? json['hourly_price'] ?? 0).toString()) ?? 0.0,
            "kapora": double.tryParse((json['deposit'] ?? 0).toString()) ?? 0.0,
            "tamKonum": json['address'] ?? "Adres yok",
            "ilce": ilceBilgisi,
            "puan": 4.5,
            "resimYolu": imgUrl,
            "ozellikler": ["Otopark", "Kantin"],
            "ownerId": json['owner_id']?.toString(), 
            "acilisSaati": json['opening_hour'] ?? 8,
            "kapanisSaati": json['closing_hour'] ?? 23,
          });
        }).toList();
      }
    } catch (e) { debugPrint("Saha hatası: $e"); }
    return [];
  }

  Future<bool> sahaSil(int id) async {
    try {
      final r = await http.delete(Uri.parse('$_baseUrl/pitches/$id'), headers: await _headers());
      return r.statusCode == 200 || r.statusCode == 204;
    } catch (e) { return false; }
  }

  Future<List<dynamic>> sahaRandevulariniGetir(String id) async {
    try {
      final r = await http.get(Uri.parse('$_baseUrl/bookings/facility/$id'), headers: await _headers());
      if (r.statusCode == 200) {
        final decoded = jsonDecode(r.body);
        return decoded['data'] ?? [];
      }
    } catch (e) { return []; }
    return [];
  }

  // --- GÜNCELLENEN REZERVASYONLARIMI GETİR FONKSİYONU ---
  Future<List<dynamic>> rezervasyonlarimiGetir() async {
    try {
      final r = await http.get(Uri.parse('$_baseUrl/bookings/my'), headers: await _headers());
      
      debugPrint("Rezervasyonlarım GET Yanıtı: STATÜ: ${r.statusCode} - BODY: ${r.body}");

      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        
        // Eğer backend direkt liste [] şeklinde dönüyorsa:
        if (data is List) {
          return data;
        }
        // Eğer { "data": [...] } veya { "bookings": [...] } şeklinde dönüyorsa:
        return data['data'] ?? data['bookings'] ?? [];
      }
    } catch (e) { 
      debugPrint("Rezervasyonları getirirken HATA: $e"); 
    }
    return [];
  }

  Future<List<int>> doluSaatleriGetir(int sahaId, DateTime tarih) async {
    try {
      String d = tarih.toIso8601String().split('T')[0];
      final r = await http.get(Uri.parse('$_baseUrl/bookings/check/$sahaId?date=$d'), headers: await _headers());
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return List<int>.from(data['busyHours'] ?? []);
      }
    } catch (e) { return []; }
    return [];
  }

  // --- GÜNCELLENEN REZERVASYON YAP FONKSİYONU ---
  Future<bool> rezervasyonYap(int sahaId, int userId, DateTime tarih, int saat, String notlar) async {
    try {
      String d = tarih.toIso8601String().split('T')[0];
      String start = "${d}T${saat.toString().padLeft(2, '0')}:00:00";
      String end = "${d}T${(saat+1).toString().padLeft(2, '0')}:00:00";
      
      // userId ve notes parametrelerini JSON'a EKLEDİK!
      final bodyData = jsonEncode({
        "pitchId": sahaId, 
        "userId": userId, // BACKEND KİMİN REZERVASYONU OLDUĞUNU BİLSİN
        "startTime": start, 
        "endTime": end, 
        "paymentMethod": "online",
        "notes": notlar 
      });

      debugPrint("Rezervasyon Yap İsteği: $bodyData");

      final r = await http.post(
        Uri.parse('$_baseUrl/bookings'), 
        headers: await _headers(),
        body: bodyData
      );

      debugPrint("Rezervasyon Yap Yanıtı: STATÜ: ${r.statusCode} - BODY: ${r.body}");
      
      return r.statusCode == 200 || r.statusCode == 201;
    } catch (e) { 
      debugPrint("Rezervasyon yaparken HATA: $e");
      return false; 
    }
  }

  Future<List<dynamic>> kartlariGetir(int id) async => [];
  Future<bool> kartSil(int id) async => true;
  Future<bool> kartEkle(int id, String a, String n) async => true;
}