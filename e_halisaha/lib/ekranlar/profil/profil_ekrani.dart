import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';
import '../../cekirdek/servisler/api_servisi.dart';
import '../giris/giris_ekrani.dart';
import 'profil_alt_sayfalar_yeni.dart'; 

class ProfilEkrani extends StatefulWidget {
  const ProfilEkrani({super.key});

  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  final ApiServisi _apiServisi = ApiServisi();
  
  // Varsayılan değerler (Yükleniyor...)
  String _adSoyad = "";
  String _email = "";
  int _toplamMac = 0;
  bool _yukleniyor = true;
  
  File? _profilResmi;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _kullaniciVerileriniYukle();
  }

  // --- KRİTİK DÜZELTME BURADA ---
  void _kullaniciVerileriniYukle() async {
    // 1. Giriş yapan kullanıcı var mı kontrol et
    final aktifKullanici = KimlikServisi.aktifKullanici;
    
    if (aktifKullanici == null || aktifKullanici['id'] == null) {
      // Kimse giriş yapmamışsa, kullanıcıyı Login sayfasına at
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const GirisEkrani()), (route) => false);
      });
      return;
    }

    int userId = aktifKullanici['id']; // Artık 1 değil, gerçek ID

    // 2. API'den taze veri çek
    try {
      var userMap = await _apiServisi.kullaniciGetir(userId);
      var maclar = await _apiServisi.randevularimiGetir(userId);

      if (mounted) {
        setState(() {
          if (userMap != null) {
            _adSoyad = userMap['fullName'] ?? "Kullanıcı";
            _email = userMap['email'] ?? "";
            
            // KimlikServisi'ni de tazeleyelim (Diğer sayfalar için)
            KimlikServisi.aktifKullanici?['isim'] = _adSoyad;
            KimlikServisi.aktifKullanici?['email'] = _email;
            KimlikServisi.aktifKullanici?['telefon'] = userMap['phoneNumber'];
          }
          _toplamMac = maclar.length;
          _yukleniyor = false;
        });
      }
    } catch (e) {
      print("Profil Yükleme Hatası: $e");
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  Future<void> _resimSec() async {
    final XFile? secilenDosya = await _picker.pickImage(source: ImageSource.gallery);
    if (secilenDosya != null) {
      setState(() => _profilResmi = File(secilenDosya.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool koyuMod = Theme.of(context).brightness == Brightness.dark;

    // Eğer veri yükleniyorsa loading göster
    if (_yukleniyor) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF22C55E), width: 3)),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: koyuMod ? Colors.grey[800] : Colors.white,
                            backgroundImage: _profilResmi != null ? FileImage(_profilResmi!) : null,
                            child: _profilResmi == null ? Icon(Icons.person, size: 60, color: Colors.grey[400]) : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
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
                    Text(_adSoyad, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: koyuMod ? Colors.white : const Color(0xFF111827))),
                    Text(_email, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // --- İSTATİSTİKLER ---
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(color: koyuMod ? Colors.black26 : Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _istatistikKutu("Maçlar", "$_toplamMac", koyuMod),
                    _dikeyCizgi(),
                    _istatistikKutu("Goller", "12", koyuMod),
                    _dikeyCizgi(),
                    _istatistikKutu("Puan", "9.4", koyuMod),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- MENÜLER (ESKİ TASARIMLAR DAHİL) ---
              _profilMenuItem(context, icon: Icons.person_outline, text: "Hesap Bilgileri", gidilecekSayfa: const HesapBilgileriEkrani()),
              _profilMenuItem(context, icon: Icons.history, text: "Geçmiş Rezervasyonlar", gidilecekSayfa: const GecmisRezervasyonlarEkrani()),
              _profilMenuItem(context, icon: Icons.groups_outlined, text: "Geçmiş Rakipler", gidilecekSayfa: const GecmisDetayEkrani(baslik: "Geçmiş Rakipler", rakipMi: true)),
              _profilMenuItem(context, icon: Icons.person_add_alt, text: "Geçmiş Oyuncular", gidilecekSayfa: const GecmisDetayEkrani(baslik: "Geçmiş Oyuncular", rakipMi: false)),
              _profilMenuItem(context, icon: Icons.payment, text: "Ödeme Yöntemleri", gidilecekSayfa: const OdemeYontemleriEkrani()),
              _profilMenuItem(context, icon: Icons.settings_outlined, text: "Ayarlar", gidilecekSayfa: const AyarlarEkrani()),
              
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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

  Widget _istatistikKutu(String baslik, String deger, bool koyuMod) {
    return Column(children: [Text(deger, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: baslik == "Puan" ? const Color(0xFF22C55E) : (koyuMod ? Colors.white : Colors.black87))), const SizedBox(height: 4), Text(baslik, style: TextStyle(fontSize: 12, color: Colors.grey[500]))]);
  }
  Widget _dikeyCizgi() => Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.3));
  
  Widget _profilMenuItem(BuildContext context, {required IconData icon, required String text, required Widget gidilecekSayfa}) {
    final bool koyuMod = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: koyuMod ? const Color(0xFF1F2937) : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: koyuMod ? Colors.black26 : const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: const Color(0xFF22C55E))),
        title: Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: koyuMod ? Colors.white : const Color(0xFF374151))),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // Sayfaya git ve dönünce verileri güncelle (örneğin isim değişmiş olabilir)
          Navigator.push(context, MaterialPageRoute(builder: (context) => gidilecekSayfa)).then((_) => _kullaniciVerileriniYukle());
        },
      ),
    );
  }
}