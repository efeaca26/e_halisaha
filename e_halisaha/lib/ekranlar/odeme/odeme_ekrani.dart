import 'package:flutter/material.dart';
import '../../modeller/saha_modeli.dart';
import '../../cekirdek/servisler/rezervasyon_servisi.dart';
import '../anasayfa/anasayfa_ekrani.dart';

class OdemeEkrani extends StatefulWidget {
  final SahaModeli saha;
  final DateTime tarih;
  final String saat;

  const OdemeEkrani({
    super.key, 
    required this.saha, 
    required this.tarih, 
    required this.saat
  });

  @override
  State<OdemeEkrani> createState() => _OdemeEkraniState();
}

class _OdemeEkraniState extends State<OdemeEkrani> {
  bool _yukleniyor = false;

  // Form Kontrolcüleri (Sadece görsel, doğrulama yapmıyoruz)
  final TextEditingController _kartNoController = TextEditingController();
  final TextEditingController _isimController = TextEditingController();
  final TextEditingController _sktController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // --- ÖDEME İŞLEMİ (SİMÜLASYON) ---
  void _odemeyiTamamla() async {
    // 1. Basit Kontrol: Alanlar boş mu?
    if (_kartNoController.text.isEmpty || _isimController.text.isEmpty || 
        _sktController.text.isEmpty || _cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen kart bilgilerini doldurun."), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _yukleniyor = true);

    // 2. Banka ile iletişim kuruyormuş gibi bekle
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 3. Ödeme Başarılı! Şimdi Rezervasyonu Kaydet
    RezervasyonServisi.rezervasyonEkle(
      saha: widget.saha, 
      tarih: widget.tarih, 
      saat: widget.saat
    );

    // 4. Başarı Mesajı ve Yönlendirme
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Ödeme Başarılı! Rezervasyonunuz oluşturuldu. 🎉"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AnasayfaEkrani()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Ödeme Yap", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- KREDİ KARTI GÖRSELİ ---
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.nfc, color: Colors.white54, size: 30),
                      Icon(Icons.credit_card, color: Colors.white, size: 30), // Logo yerine ikon
                    ],
                  ),
                  const Text("**** **** **** 1234", style: TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2, fontFamily: 'Courier')),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Kart Sahibi", style: TextStyle(color: Colors.white54, fontSize: 10)),
                          Text(_isimController.text.isEmpty ? "AD SOYAD" : _isimController.text.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("SKT", style: TextStyle(color: Colors.white54, fontSize: 10)),
                          Text(_sktController.text.isEmpty ? "MM/YY" : _sktController.text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // --- FORM ALANLARI ---
            const Text("Kart Bilgileri", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _formAlani(controller: _isimController, hint: "Kart Üzerindeki İsim", icon: Icons.person, onChanged: (v) => setState((){})),
            const SizedBox(height: 16),
            _formAlani(controller: _kartNoController, hint: "Kart Numarası", icon: Icons.credit_card_outlined, klavyeTipi: TextInputType.number),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _formAlani(controller: _sktController, hint: "AA/YY", icon: Icons.calendar_today, klavyeTipi: TextInputType.datetime, onChanged: (v) => setState((){}))),
                const SizedBox(width: 16),
                Expanded(child: _formAlani(controller: _cvvController, hint: "CVV", icon: Icons.lock_outline, klavyeTipi: TextInputType.number)),
              ],
            ),

            const SizedBox(height: 30),
            
            // --- ÖZET BİLGİ ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDCFCE7)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.saha.isim, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("${widget.tarih.day}.${widget.tarih.month}.${widget.tarih.year} - ${widget.saat}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  Text("${widget.saha.fiyat.toStringAsFixed(0)}₺", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- BUTON ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _yukleniyor ? null : _odemeyiTamamla,
                child: _yukleniyor 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Ödemeyi Onayla", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formAlani({
    required TextEditingController controller, 
    required String hint, 
    required IconData icon, 
    TextInputType klavyeTipi = TextInputType.text,
    Function(String)? onChanged
  }) {
    return TextField(
      controller: controller,
      keyboardType: klavyeTipi,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF22C55E))),
      ),
    );
  }
}