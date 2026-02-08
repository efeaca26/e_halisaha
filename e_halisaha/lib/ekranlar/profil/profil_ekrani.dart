import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';
import '../../cekirdek/servisler/api_servisi.dart'; // EKLENDİ
import '../giris/giris_ekrani.dart';
import 'profil_alt_sayfalar_yeni.dart'; 

class ProfilEkrani extends StatefulWidget {
  const ProfilEkrani({super.key});

  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  File? _profilResmi;
  final ImagePicker _picker = ImagePicker();
  
  // --- API İÇİN EKLENENLER ---
  final ApiServisi _apiServisi = ApiServisi();
  int _toplamMacSayisi = 0; // API'den gelecek
  bool _istatistikYukleniyor = true;

  @override
  void initState() {
    super.initState();
    _istatistikleriGetir();
  }

  // Kaç maç yaptığını API'den öğreniyoruz
  void _istatistikleriGetir() async {
    // Giriş yapan kullanıcının ID'sini al (Yoksa 1 varsay)
    int userId = KimlikServisi.aktifKullanici?['id'] ?? 1;
    
    // Randevuları çek
    var liste = await _apiServisi.randevularimiGetir(userId);
    
    if (mounted) {
      setState(() {
        _toplamMacSayisi = liste.length;
        _istatistikYukleniyor = false;
      });
    }
  }

  Future<void> _resimSec() async {
    final XFile? secilenDosya = await _picker.pickImage(source: ImageSource.gallery);
    if (secilenDosya != null) {
      setState(() {
        _profilResmi = File(secilenDosya.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final kullanici = KimlikServisi.aktifKullanici;
    final bool koyuMod = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // --- PROFİL FOTOĞRAFI ---
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF22C55E), width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: koyuMod ? Colors.grey[800] : Colors.white,
                            backgroundImage: _profilResmi != null ? FileImage(_profilResmi!) : null,
                            child: _profilResmi == null 
                                ? Icon(Icons.person, size: 60, color: Colors.grey[400]) 
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _resimSec,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // İsim ve E-posta
                    Text(
                      kullanici?['isim'] ?? "Misafir",
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        color: koyuMod ? Colors.white : const Color(0xFF111827)
                      )
                    ),
                    Text(
                      kullanici?['email'] ?? "",
                      style: const TextStyle(fontSize: 14, color: Colors.grey)
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // --- YENİ EKLENEN: İSTATİSTİK KUTULARI ---
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: koyuMod ? Colors.black26 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _istatistikKutu("Maçlar", _istatistikYukleniyor ? "-" : "$_toplamMacSayisi", koyuMod),
                    _dikeyCizgi(),
                    _istatistikKutu("Goller", "12", koyuMod), // Şimdilik sabit
                    _dikeyCizgi(),
                    _istatistikKutu("Puan", "9.4", koyuMod),  // Şimdilik sabit
                  ],
                ),
              ),
              // ------------------------------------------

              const SizedBox(height: 32),

              // --- MENÜLER ---
              _profilMenuItem(
                context, 
                icon: Icons.person_outline, 
                text: "Hesap Bilgileri", 
                gidilecekSayfa: const HesapBilgileriEkrani()
              ),
              _profilMenuItem(
                context, 
                icon: Icons.history, 
                text: "Geçmiş Rezervasyonlar", 
                gidilecekSayfa: const GecmisRezervasyonlarEkrani() // Bu ekranı aşağıda verdim
              ),
              _profilMenuItem(
                context, 
                icon: Icons.groups_outlined, 
                text: "Geçmiş Rakipler", 
                gidilecekSayfa: const GecmisDetayEkrani(baslik: "Geçmiş Rakipler", rakipMi: true)
              ),
              _profilMenuItem(
                context, 
                icon: Icons.person_add_alt, 
                text: "Geçmiş Oyuncular", 
                gidilecekSayfa: const GecmisDetayEkrani(baslik: "Geçmiş Oyuncular", rakipMi: false)
              ),
              _profilMenuItem(
                context, 
                icon: Icons.payment, 
                text: "Ödeme Yöntemleri", 
                gidilecekSayfa: const OdemeYontemleriEkrani() 
              ),
              _profilMenuItem(
                context, 
                icon: Icons.settings_outlined, 
                text: "Ayarlar", 
                gidilecekSayfa: const AyarlarEkrani() 
              ),
              
              const SizedBox(height: 24),

              // --- ÇIKIŞ BUTONU ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    KimlikServisi.cikisYap(); 
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const GirisEkrani()), (route) => false);
                  },
                  child: const Text("Çıkış Yap", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Yardımcı: İstatistik Kutusu
  Widget _istatistikKutu(String baslik, String deger, bool koyuMod) {
    return Column(
      children: [
        Text(
          deger, 
          style: TextStyle(
            fontSize: 22, 
            fontWeight: FontWeight.bold, 
            color: baslik == "Puan" ? const Color(0xFF22C55E) : (koyuMod ? Colors.white : Colors.black87)
          )
        ),
        const SizedBox(height: 4),
        Text(
          baslik, 
          style: TextStyle(fontSize: 12, color: Colors.grey[500])
        ),
      ],
    );
  }

  Widget _dikeyCizgi() {
    return Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.3));
  }

  Widget _profilMenuItem(BuildContext context, {required IconData icon, required String text, required Widget gidilecekSayfa}) {
    final bool koyuMod = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: koyuMod ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: koyuMod ? Colors.black26 : const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF22C55E)),
        ),
        title: Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: koyuMod ? Colors.white : const Color(0xFF374151))),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => gidilecekSayfa));
        },
      ),
    );
  }
}