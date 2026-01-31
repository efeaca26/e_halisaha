import 'package:flutter/material.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';
import '../giris/giris_ekrani.dart';

// --- TEK İMPORT: Sadece yeni birleştirdiğimiz dosyayı çağırıyoruz ---
import 'profil_alt_sayfalar_yeni.dart'; 
// --------------------------------------------------------------------

class ProfilEkrani extends StatelessWidget {
  const ProfilEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final kullanici = KimlikServisi.aktifKullanici;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Hafif gri arka plan
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // --- ÜST PROFİL KARTI ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFF22C55E),
                      child: Text(
                        kullanici != null ? kullanici['isim'][0].toUpperCase() : "M",
                        style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kullanici != null ? kullanici['isim'] : "Misafir",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            kullanici != null ? kullanici['email'] : "Giriş yapılmadı",
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () {
                        // Hesap Bilgilerine Git
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const HesapBilgileriEkrani()));
                      },
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- MENÜ LİSTESİ ---
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
                gidilecekSayfa: const GecmisRezervasyonlarEkrani()
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
                icon: Icons.credit_card, 
                text: "Ödeme Yöntemleri", 
                gidilecekSayfa: const OdemeYontemleriEkrani()
              ),

              _profilMenuItem(
                context, 
                icon: Icons.settings_outlined, 
                text: "Ayarlar", 
                gidilecekSayfa: const AyarlarEkrani()
              ),

              const SizedBox(height: 20),

              // --- ÇIKIŞ BUTONU ---
              TextButton.icon(
                onPressed: () {
                  // Çıkış Yap ve Giriş Ekranına Dön
                  KimlikServisi.cikisYap();
                  Navigator.pushAndRemoveUntil(
                    context, 
                    MaterialPageRoute(builder: (context) => const GirisEkrani()), 
                    (route) => false
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text("Çıkış Yap", style: TextStyle(color: Colors.red, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Menü Tasarımı (Yardımcı Widget)
  Widget _profilMenuItem(BuildContext context, {required IconData icon, required String text, required Widget gidilecekSayfa}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF15803D)),
        ),
        title: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => gidilecekSayfa));
        },
      ),
    );
  }
}