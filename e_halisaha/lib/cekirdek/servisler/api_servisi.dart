import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'kimlik_servisi.dart';
import '../../modeller/saha_modeli.dart';

class ApiServisi {
  static const String _baseUrl = "http://185.157.46.167:3000/api";

  Future<Map<String, String>> _headers() async {
    String? token = await KimlikServisi.tokenGetir();
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // --- KİMLİK VE KULLANICI İŞLEMLERİ ---
  Future<Map<String, dynamic>?> girisYap(String email, String password) async {
    try {
      final url = Uri.parse("$_baseUrl/auth/login");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"login": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await KimlikServisi.girisYapveKaydet(data);
        return data;
      }
      return null;
    } catch (e) { 
      return null; 
    }
  }

  Future<List<dynamic>> tumKullanicilariGetir() async {
    try {
      final r = await http.get(Uri.parse('$_baseUrl/users'), headers: await _headers());
      if (r.statusCode == 200) {
        return jsonDecode(r.body)['data'] ?? [];
      }
    } catch (e) {
      debugPrint("Kullanıcı Getirme Hatası: $e");
    }
    return [];
  }

  Future<bool> kullaniciBilgileriniGuncelle(int id, Map<String, dynamic> veriler) async {
    try {
      final r = await http.put(
        Uri.parse('$_baseUrl/users/$id'), 
        headers: await _headers(), 
        body: jsonEncode(veriler)
      );
      return r.statusCode == 200;
    } catch (e) { 
      return false; 
    }
  }

  Future<bool> bilgileriGuncelle(int id, String ad, String email, String tel, String sifre) async {
    return await kullaniciBilgileriniGuncelle(id, {
      "name": ad, 
      "email": email, 
      "phone": tel
    });
  }

  Future<bool> kullaniciRoluGuncelle(int id, String rol) async {
    return await kullaniciBilgileriniGuncelle(id, {"role": rol});
  }

  Future<bool> kullaniciSil(int id) async {
    try {
      final r = await http.delete(Uri.parse('$_baseUrl/users/$id'), headers: await _headers());
      return r.statusCode == 200;
    } catch (e) { 
      return false; 
    }
  }
  
  Future<bool> hesabiSil(int id) async => await kullaniciSil(id);
  
  Future<Map<String, dynamic>?> kullaniciGetir(int id) async {
    try {
      final r = await http.get(Uri.parse('$_baseUrl/users/$id'), headers: await _headers());
      if (r.statusCode == 200) {
        return jsonDecode(r.body)['data'];
      }
    } catch (e) {
      debugPrint("Kullanıcı Getirme Hatası: $e");
    }
    return null;
  }

  // --- SAHA İŞLEMLERİ ---
  Future<List<SahaModeli>> tumSahalariGetir() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/pitches'));
      
      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        List<dynamic> sahalarJson = resData['data'] ?? [];
        
        return sahalarJson.map((json) {
          return SahaModeli.fromMap({
            "id": json['id'].toString(),
            "isim": json['name'] ?? "İsimsiz Saha",
            "fiyat": double.tryParse(json['price']?.toString() ?? "0") ?? 0.0,
            "kapora": double.tryParse(json['deposit']?.toString() ?? "0") ?? 0.0,
            "tamKonum": json['address'] ?? "Adres bilgisi yok",
            "ilce": (json['address'] as String?)?.split(',').last.trim() ?? "Merkez",
            "puan": 4.5,
            "resimYolu": json['image_url'] ?? "assets/resimler/saha1.png",
            "ozellikler": ["Otopark", "Kantin", "Soyunma Odası"],
            "isletmeSahibiEmail": json['owner_email'] ?? "",
            // İşletme ekranında filtrelemek için backend'den gelen id'yi de tutuyoruz
            "ownerId": json['owner_id'] ?? json['userId'], 
          });
        }).toList();
      }
    } catch (e) { 
      debugPrint("Saha Listeleme Hatası: $e"); 
    }
    return [];
  }

  Future<bool> sahaSil(int id) async {
    try {
      final r = await http.delete(Uri.parse('$_baseUrl/pitches/$id'), headers: await _headers());
      return r.statusCode == 200 || r.statusCode == 204;
    } catch (e) { 
      return false; 
    }
  }

  // --- REZERVASYON VE DOLULUK ---
  Future<List<int>> doluSaatleriGetir(int sahaId, DateTime tarih) async {
    try {
      String t = tarih.toIso8601String().split('T')[0];
      final r = await http.get(Uri.parse('$_baseUrl/bookings/availability/$sahaId/$t'));
      if (r.statusCode == 200) {
        final res = jsonDecode(r.body);
        final d = res['data'] as List;
        return d.where((s) => s['available'] == false)
                .map<int>((s) => int.parse(s['time'].split(':')[0])).toList();
      }
    } catch (e) { 
      debugPrint("Doluluk Getirme Hatası: $e");
    }
    return [];
  }

  Future<bool> rezervasyonYap(int sahaId, int userId, DateTime tarih, int saat, String notlar) async {
    try {
      String d = tarih.toIso8601String().split('T')[0];
      String start = "${d}T${saat.toString().padLeft(2, '0')}:00:00";
      String end = "${d}T${(saat+1).toString().padLeft(2, '0')}:00:00";
      
      final r = await http.post(
        Uri.parse('$_baseUrl/bookings'), 
        headers: await _headers(),
        body: jsonEncode({
          "pitchId": sahaId, 
          "startTime": start, 
          "endTime": end, 
          "paymentMethod": "online"
        })
      );
      return r.statusCode == 200 || r.statusCode == 201;
    } catch (e) { 
      debugPrint("Rezervasyon Hatası: $e");
      return false; 
    }
  }

  Future<List<dynamic>> randevularimiGetir(int userId) async {
    try {
      final r = await http.get(Uri.parse('$_baseUrl/bookings/user'), headers: await _headers());
      if (r.statusCode == 200) {
        return jsonDecode(r.body)['data'] ?? [];
      }
    } catch (e) { 
      debugPrint("Randevu Getirme Hatası: $e");
    }
    return [];
  }

  Future<List<dynamic>> sahaRandevulariniGetir(String id) async {
    try {
      final r = await http.get(Uri.parse('$_baseUrl/bookings/facility/$id'), headers: await _headers());
      if (r.statusCode == 200) {
        return jsonDecode(r.body)['data'] ?? [];
      }
    } catch (e) { 
      debugPrint("Saha Randevuları Hatası: $e");
    }
    return [];
  }

  // --- KART İŞLEMLERİ (Ödeme ekranı için - Şimdilik Dummy) ---
  Future<List<dynamic>> kartlariGetir(int id) async => [];
  Future<bool> kartSil(int id) async => true;
  Future<bool> kartEkle(int id, String a, String n) async => true;
}