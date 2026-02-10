import 'dart:convert';
import 'package:http/http.dart' as http;
import 'kimlik_servisi.dart'; // Kimlik servisi importu şart

class ApiServisi {
  // Emülatör için 10.0.2.2, Port: 5216 (Senin verdiğin)
  // static const String _baseUrl = "http://10.0.2.2:5216/api";
  //gerçek IP adresini yazıyoruz:
  // static const String _baseUrl = "http://10.250.98.178:5216/api";
  
  // ŞU AN GEÇERLİ OLAN ADRES (Senin IP):
  static const String _baseUrl = "http://10.250.98.178:5216/api";
  

  // // --- GİRİŞ YAP ---
  // Future<bool> girisYap(String email, String password) async {
  //   try {
  //     final url = Uri.parse('$_baseUrl/Users/Login');
      
  //     final response = await http.post(
  //       url,
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({
  //         "email": email,
  //         "password": password,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       // Token ve kullanıcı bilgilerini telefona kaydet
  //       await KimlikServisi.girisYapveKaydet(data);
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     print("Giriş Hatası: $e");
  //     return false;
  //   }
  // }

  // --- GİRİŞ YAP (DEBUG MODLU ve DÜZELTİLMİŞ) ---
  Future<bool> girisYap(String email, String password) async {
    try {
      // ESKİ HATALI SATIR: final url = Uri.parse("http://10.0.2.2:$port/api/Users/Login");
      // YENİ DOĞRU SATIR: Artık yukarıdaki _baseUrl'i (176...) kullanıyor.
      final url = Uri.parse("$_baseUrl/Users/Login");
      
      print("--------------------------------------------------");
      print("🚀 GİRİŞ DENEMESİ BAŞLIYOR");
      print("📡 Gidilen Adres: $url"); // Burası artık 176... ile başlamalı

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      print("Sunucu Cevap Kodu: ${response.statusCode}");
      print("Sunucu Cevabı: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['user'] == null) {
          print("HATA: Sunucu 'user' bilgisi göndermedi! Backend kodunu kontrol et.");
          return false;
        }

        await KimlikServisi.girisYapveKaydet(data);
        print("---- GİRİŞ BAŞARILI ----");
        return true;
      } else {
        print("---- GİRİŞ BAŞARISIZ ----");
        return false;
      }
    } catch (e) {
      print("---- BAĞLANTI HATASI ----");
      print("Hata Detayı: $e");
      return false;
    }
  }

  // // --- KAYIT OL ---
  // Future<bool> kayitOl(String adSoyad, String telefon, String sifre, bool isletmeMi) async {
  //   try {
  //     final url = Uri.parse('$_baseUrl/Users');
      
  //     final response = await http.post(
  //       url,
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({
  //         "fullName": adSoyad,
  //         "email": "$telefon@ehali.com", // E-posta yerine telefon formatı
  //         "passwordHash": sifre,
  //         "phoneNumber": telefon,
  //         "role": isletmeMi ? "isletme" : "oyuncu",
  //         "createdAt": DateTime.now().toIso8601String()
  //       }),
  //     );

  //     return response.statusCode == 201 || response.statusCode == 200;
  //   } catch (e) {
  //     print("Kayıt Hatası: $e");
  //     return false;
  //   }
  // }

  // --- KAYIT OL
  Future<bool> kayitOl(String adSoyad, String telefon, String sifre, bool isletmeMi, {String? sahaAdi, String? konum}) async {
    try {
      final url = Uri.parse('$_baseUrl/Users');
      
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fullName": adSoyad,
          "phoneNumber": telefon,
          "password": sifre,
          "role": isletmeMi ? "isletme" : "oyuncu",
          // İşletme ise bu verileri gönder, değilse null gider (sorun olmaz)
          "pitchName": sahaAdi, 
          "location": konum
        }),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print("Kayıt Başarısız: ${response.body}");
        return false;
      }
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

  // --- SAHA SİLME ---
  Future<bool> sahaSil(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/Pitches/$id'));
      // 204 No Content veya 200 OK başarılı demektir
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
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
  // --- ADMIN FONKSİYONLARI (Bunlardan sadece 1 tane olmalı) ---

  // Tüm kullanıcıları getir
  Future<List<dynamic>> tumKullanicilariGetir() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/Users'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Kullanıcıları getirme hatası: $e");
      return [];
    }
  }

  // Kullanıcı sil
  Future<bool> kullaniciSil(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/Users/$id'));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print("Silme hatası: $e");
      return false;
    }
  }

  // Rezervasyon sil
  Future<bool> rezervasyonSil(int id) async {
     try {
      final response = await http.delete(Uri.parse('$_baseUrl/Reservations/$id'));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print("Rezervasyon silme hatası: $e");
      return false;
    }
  }
  // --- YENİ ADMİN FONKSİYONLARI ---

  // 1. Kullanıcı Rolünü Değiştir
  Future<bool> kullaniciRoluGuncelle(int userId, String yeniRol) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/Users/ChangeRole/$userId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(yeniRol), // Sadece string olarak gönderiyoruz
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Rol güncelleme hatası: $e");
      return false;
    }
  }

  // 2. Tüm Sahaları Getir
  Future<List<dynamic>> tumSahalariGetir() async {
    try {
      // Backend controller adına göre burası 'Pitches' olmalı.
      // Eğer backendde Fields ise Fields kalsın ama genelde Pitches kullanıyoruz.
      // Güvenli olsun diye 'Pitches' yapıyorum, hata verirse değiştiririz.
      final response = await http.get(Uri.parse('$_baseUrl/Pitches')); 
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Sahaları getirme hatası: $e");
      return [];
    }
  }

  // 3. Tüm Rezervasyonları Getir
  Future<List<dynamic>> tumRezervasyonlariGetir() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/Reservations'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print("Rezervasyonları getirme hatası: $e");
      return [];
    }
  }
  // --- ADMIN: KULLANICIYI DÜZENLE (FULL YETKİ) ---
  Future<bool> kullaniciBilgileriniGuncelle(int id, Map<String, dynamic> veriler) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/Users/AdminUpdate/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(veriler),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Güncelleme hatası: $e");
      return false;
    }
  }
  // Onay Bekleyenleri Getir (isApproved = false olanlar)
  // Not: Backend'de buna özel endpoint yazmak gerekebilir veya tüm kullanıcıları çekip filter yapabiliriz.
  // Şimdilik tüm kullanıcıları çekip Flutter'da filtreleyeceğiz.
  
  // Kullanıcıyı Onayla
  Future<bool> kullaniciyiOnayla(int userId) async {
    // Backend'deki AdminUpdate metodunu kullanarak IsApproved = true yapacağız
    return await kullaniciBilgileriniGuncelle(userId, {"isApproved": true});
  }
}