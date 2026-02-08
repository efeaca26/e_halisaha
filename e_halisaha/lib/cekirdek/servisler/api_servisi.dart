import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServisi {
  // 1. Emülatör için Adres (Port: 5216)
  static const String _baseUrl = "http://10.0.2.2:5216/api";

  // --- GİRİŞ YAP ---
  // Backend'deki Users/Login endpoint'ine gider
  Future<Map<String, dynamic>?> girisYap(String email, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/Users/Login');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password, // Backend'de LoginRequest modelinde "Password" demiştik
        }),
      );

      if (response.statusCode == 200) {
        // Başarılı: { "message": "...", "userId": 1, ... } döner
        return jsonDecode(response.body);
      } else {
        print("Giriş Başarısız: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Giriş Hatası: $e");
      return null;
    }
  }

  // --- KAYIT OL ---
  // Backend'deki Users tablosuna yeni kayıt ekler (POST)
  Future<bool> kayitOl(String adSoyad, String email, String sifre, String telefon) async {
    try {
      // Otomatik oluşturulan UsersController direkt bu adresi dinler
      final url = Uri.parse('$_baseUrl/Users'); 

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": adSoyad,       // C# Modelindeki isimle aynı olmalı
          "email": email,
          "passwordHash": sifre,     // C#'ta veritabanında bu isimle tutuyoruz
          "phoneNumber": telefon
        }),
      );

      // 201: Created (Oluşturuldu) demektir
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      
      print("Kayıt Başarısız: ${response.body}");
      return false;
    } catch (e) {
      print("Kayıt Hatası: $e");
      return false;
    }
  }
  Future<List<dynamic>> sahalariGetir() async {
    try {
      final url = Uri.parse('$_baseUrl/Pitches');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Gelen JSON listesini döndür
        return jsonDecode(response.body);
      } else {
        print("Saha Çekme Hatası: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Bağlantı Hatası: $e");
      return [];
    }
  }
  // --- REZERVASYON YAP (KAYIT) ---
  // POST: api/Reservations
  Future<bool> rezervasyonYap(int sahaId, int userId, DateTime tarih, int saat, String notlar) async {
    try {
      final url = Uri.parse('$_baseUrl/Reservations');
      
      final bodyData = jsonEncode({
        "pitchId": sahaId,
        "userId": userId,
        "rezDate": tarih.toIso8601String(),
        "rezHour": saat, // Sadece saati (örn: 19) gönderiyoruz
        "note": notlar,
        "status": 1 // 1: Onaylı varsayalım
      });

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: bodyData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print("Rezervasyon Hatası: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Bağlantı Hatası: $e");
      return false;
    }
  }

  // GET: api/Reservations
  Future<List<int>> doluSaatleriGetir(int sahaId, DateTime tarih) async {
    try {
      // Şimdilik tüm rezervasyonları çekip içeride filtreliyoruz.
      // İleride backend'e "?pitchId=1" gibi filtre eklenirse daha iyi olur.
      final url = Uri.parse('$_baseUrl/Reservations');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> tumRezervasyonlar = jsonDecode(response.body);
        List<int> doluSaatler = [];

        // Seçilen tarih formatı (Yıl-Ay-Gün)
        String secilenTarihStr = tarih.toIso8601String().split('T')[0];

        for (var rez in tumRezervasyonlar) {
          // Gelen tarih formatı "2026-02-08T00:00:00" olabilir, parse edip gününe bakıyoruz
          String rezTarihStr = rez['rezDate'].toString().split('T')[0];
          
          // Eğer ID ve Tarih eşleşiyorsa o saati listeye ekle
          if (rez['pitchId'] == sahaId && rezTarihStr == secilenTarihStr) {
             doluSaatler.add(rez['rezHour']);
          }
        }
        return doluSaatler;
      }
      return [];
    } catch (e) {
      print("Veri Çekme Hatası: $e");
      return [];
    }
  }
  // GET: api/Reservations
  Future<List<dynamic>> randevularimiGetir(int userId) async {
    try {
      final url = Uri.parse('$_baseUrl/Reservations');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> tumRezervasyonlar = jsonDecode(response.body);
        
        // Sadece bana ait olanları (userId) filtrele
        // Not: İleride Backend'e "?userId=1" filtresi eklemek daha performanslı olur.
        var benimkiler = tumRezervasyonlar.where((rez) => rez['userId'] == userId).toList();
        
        return benimkiler;
      }
      return [];
    } catch (e) {
      print("Randevu Geçmişi Hatası: $e");
      return [];
    }
  }
  // PUT: api/Users/5
  Future<bool> bilgileriGuncelle(int userId, String adSoyad, String email, String telefon, String sifre) async {
    try {
      final url = Uri.parse('$_baseUrl/Users/$userId');
      
      final bodyData = jsonEncode({
        "userId": userId,
        "fullName": adSoyad,
        "email": email,
        "phoneNumber": telefon,
        "passwordHash": sifre, // Şifreyi de gönderiyoruz (değişmediyse aynısını yollarız)
        "createdAt": DateTime.now().toIso8601String() // Tarih zorunlu değil ama hata vermesin diye ekledik
      });

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: bodyData,
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      } else {
        print("Güncelleme Hatası: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Bağlantı Hatası: $e");
      return false;
    }
  }
  // --- KULLANICI BİLGİSİNİ GETİR (PROFİL İÇİN) ---
  Future<Map<String, dynamic>?> kullaniciGetir(int userId) async {
    try {
      final url = Uri.parse('$_baseUrl/Users/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Kullanıcı Getirme Hatası: $e");
    }
    return null;
  }

  // --- KARTLARI GETİR ---
  Future<List<dynamic>> kartlariGetir(int userId) async {
    try {
      final url = Uri.parse('$_baseUrl/SavedCards?userId=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Kart Getirme Hatası: $e");
    }
    return [];
  }

  // --- KART EKLE ---
  Future<bool> kartEkle(int userId, String kartAdi, String kartNo) async {
    try {
      final url = Uri.parse('$_baseUrl/SavedCards');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "cardAlias": kartAdi,
          "cardNumber": kartNo
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  Future<bool> kartSil(int cardId) async {
    try {
      final url = Uri.parse('$_baseUrl/SavedCards/$cardId');
      final response = await http.delete(url);
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  // --- TÜM KULLANICILARI GETİR (ADMİN İÇİN) ---
  Future<List<dynamic>> tumKullanicilariGetir() async {
    try {
      final url = Uri.parse('$_baseUrl/Users');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Kullanıcıları Getirme Hatası: $e");
    }
    return [];
  }

  Future<bool> rolGuncelle(int userId, Map<String, dynamic> mevcutVeriler, String yeniRol) async {
    try {
      final url = Uri.parse('$_baseUrl/Users/$userId');
      
      // Mevcut verileri koruyarak sadece rolü değiştiriyoruz
      mevcutVeriler['userId'] = userId; // ID'yi garantiye al
      mevcutVeriler['role'] = yeniRol;  // Yeni rolü ata

      // API tarih formatında sorun çıkarabilir, null veya boşsa şimdiki zamanı atayalım
      if (mevcutVeriler['createdAt'] == null) {
         mevcutVeriler['createdAt'] = DateTime.now().toIso8601String();
      }

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(mevcutVeriler),
      );

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print("Rol Güncelleme Hatası: $e");
      return false;
    }
  }
}