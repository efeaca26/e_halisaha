import 'dart:io'; // Dosya işlemleri için
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Resim seçici
import '../../cekirdek/servisler/kimlik_servisi.dart'; // Kimlik servisi
import '../giris/giris_ekrani.dart'; // Çıkış yapınca gidilecek yer
import 'profil_alt_sayfalar_yeni.dart'; // Alt sayfalar
import 'gecmis_rezervasyonlar.dart';

class ProfilEkrani extends StatefulWidget {
  const ProfilEkrani({super.key});

  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  File? _profilResmi;
  final ImagePicker _picker = ImagePicker();

  // Galeriden resim seçme
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
    // Aktif kullanıcının bilgilerini al
    final kullanici = KimlikServisi.aktifKullanici;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4), 
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
                            backgroundColor: Colors.white,
                            backgroundImage: _profilResmi != null ? FileImage(_profilResmi!) : null,
                            child: _profilResmi == null 
                                ? Icon(Icons.person, size: 60, color: Colors.grey[300]) 
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
                    
                    // İsim ve E-posta (Servisten)
                    Text(
                      kullanici?['isim'] ?? "Misafir",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827))
                    ),
                    Text(
                      kullanici?['email'] ?? "",
                      style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))
                    ),
                  ],
                ),
              ),
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
                icon: Icons.payment, 
                text: "Ödeme Yöntemleri", 
                gidilecekSayfa: const GenelAltSayfa(baslik: "Ödemeler", ikon: Icons.credit_card)
              ),
              _profilMenuItem(
                context, 
                icon: Icons.history, 
                text: "Geçmiş Rezervasyonlar", 
                // BURAYI DEĞİŞTİRDİK:
                gidilecekSayfa: const GecmisRezervasyonlarEkrani() 
              ),
              _profilMenuItem(
                context, 
                icon: Icons.settings_outlined, 
                text: "Ayarlar", 
                gidilecekSayfa: const GenelAltSayfa(baslik: "Ayarlar", ikon: Icons.settings)
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

  Widget _profilMenuItem(BuildContext context, {required IconData icon, required String text, required Widget gidilecekSayfa}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF22C55E)),
        ),
        title: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9CA3AF)),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => gidilecekSayfa));
        },
      ),
    );
  }
}