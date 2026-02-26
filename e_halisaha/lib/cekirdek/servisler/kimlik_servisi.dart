import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class KimlikServisi {
  static const String _tokenKey = "token";
  static const String _userKey = "user";
  static Map<String, dynamic>? _onbellekKullanici;

  static Future<void> girisYapveKaydet(Map<String, dynamic> veri) async {
    final prefs = await SharedPreferences.getInstance();
    if (veri['token'] != null) await prefs.setString(_tokenKey, veri['token']);
    if (veri['user'] != null) {
      _onbellekKullanici = veri['user'];
      await prefs.setString(_userKey, jsonEncode(veri['user']));
    }
  }

  static Map<String, dynamic>? get aktifKullanici => _onbellekKullanici;

  static Future<Map<String, dynamic>?> kullaniciGetir() async {
    if (_onbellekKullanici != null) return _onbellekKullanici;
    final prefs = await SharedPreferences.getInstance();
    String? userStr = prefs.getString(_userKey);
    if (userStr == null) return null;
    _onbellekKullanici = jsonDecode(userStr);
    return _onbellekKullanici;
  }

  static Future<bool> girisYapildiMi() async {
    final prefs = await SharedPreferences.getInstance();
    String? userStr = prefs.getString(_userKey);
    if (userStr != null) _onbellekKullanici = jsonDecode(userStr);
    String? token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  static Future<String?> tokenGetir() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> cikisYap() async {
    final prefs = await SharedPreferences.getInstance();
    _onbellekKullanici = null;
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}