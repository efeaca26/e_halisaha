import 'api_servisi.dart';

class KimlikServisi {
  static bool isletmeModu = false;

  static Future<bool> girisYap(String email, String sifre, bool isletme) async {
    return await ApiServisi.girisYap(email, sifre, isletme);
  }

  static Future<bool> kayitOl(String isim, String email, String sifre, bool isletme) async {
    return await ApiServisi.kayitOl(isim, email, sifre, isletme);
  }
}