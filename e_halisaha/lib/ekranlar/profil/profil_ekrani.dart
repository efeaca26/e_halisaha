import 'package:flutter/material.dart';
import '../../cekirdek/servisler/api_servisi.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';
import 'profil_alt_sayfalar.dart'; // Ayarlar ve Randevular burada
import 'profil_alt_sayfalar_yeni.dart'; // Profil Düzenleme burada

class ProfilEkrani extends StatefulWidget {
  const ProfilEkrani({super.key});

  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  // ... (diğer metodlar aynı kalabilir)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: ListView(
        children: [
          // Profil Düzenleme (Hesap Bilgileri)
          _profilSecenegi(
            icon: Icons.person_outline,
            label: "Hesap Bilgileri",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilDuzenleSayfasi()), // HesapBilgileriEkrani yerine
            ),
          ),
          // Geçmiş Rezervasyonlar (Randevularım)
          _profilSecenegi(
            icon: Icons.history,
            label: "Geçmiş Rezervasyonlar",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RandevularimSayfasi()), // GecmisRezervasyonlarEkrani yerine
            ),
          ),
          // Ayarlar
          _profilSecenegi(
            icon: Icons.settings_outlined,
            label: "Ayarlar",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AyarlarSayfasi()), // AyarlarEkrani yerine
            ),
          ),
          const Divider(),
          _profilSecenegi(
            icon: Icons.logout,
            label: "Çıkış Yap",
            color: Colors.red,
            onTap: () async {
              await KimlikServisi.cikisYap();
              if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _profilSecenegi({required IconData icon, required String label, required VoidCallback onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(label, style: TextStyle(color: color ?? Colors.black87)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}