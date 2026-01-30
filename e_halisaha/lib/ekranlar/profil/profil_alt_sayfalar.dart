import 'package:flutter/material.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';

// --- BU SINIFIN EKSİK OLMADIĞINDAN EMİN OL ---
class GenelAltSayfa extends StatelessWidget {
  final String baslik;
  final IconData ikon;

  const GenelAltSayfa({super.key, required this.baslik, required this.ikon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(baslik, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: const Color(0xFFF0FDF4),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 20),
            Text("$baslik Burada Olacak", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Bu özellik geliştirme aşamasındadır.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
// ---------------------------------------------

class HesapBilgileriEkrani extends StatefulWidget {
  const HesapBilgileriEkrani({super.key});

  @override
  State<HesapBilgileriEkrani> createState() => _HesapBilgileriEkraniState();
}

class _HesapBilgileriEkraniState extends State<HesapBilgileriEkrani> {
  final Map<String, dynamic> kullanici = KimlikServisi.aktifKullanici ?? {}; 
  
  Future<void> _tarihSec(BuildContext context) async {
    final DateTime? secilenTarih = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF22C55E),
            colorScheme: const ColorScheme.light(primary: Color(0xFF22C55E)),
          ),
          child: child!,
        );
      },
    );

    if (secilenTarih != null) {
      setState(() {
        String formatliTarih = "${secilenTarih.day}.${secilenTarih.month}.${secilenTarih.year}";
        kullanici['dogumTarihi'] = formatliTarih;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Doğum tarihi güncellendi!"), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (KimlikServisi.aktifKullanici == null) {
      return const Scaffold(body: Center(child: Text("Lütfen tekrar giriş yapınız.")));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Hesap Bilgileri", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _saltOkunurSatir("Ad Soyad", kullanici['isim']),
            _saltOkunurSatir("E-Posta", kullanici['email']),
            _saltOkunurSatir("Telefon", kullanici['telefon']),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _tarihSec(context),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.5))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Doğum Tarihi", style: TextStyle(color: Colors.black54)),
                    Row(
                      children: [
                        Text(
                          kullanici['dogumTarihi'] ?? "Seçiniz", 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF15803D))
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.edit_calendar, size: 20, color: Color(0xFF15803D)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _saltOkunurSatir(String baslik, String? deger) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50], 
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(color: Colors.grey)),
          Text(deger ?? "-", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}