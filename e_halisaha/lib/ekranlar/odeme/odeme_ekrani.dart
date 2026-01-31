import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../modeller/saha_modeli.dart';
import '../../cekirdek/servisler/rezervasyon_servisi.dart';
import '../anasayfa/anasayfa_ekrani.dart';

class OdemeEkrani extends StatefulWidget {
  final SahaModeli saha;
  final DateTime tarih;
  final String saat;
  final double sonTutar;

  const OdemeEkrani({
    super.key, 
    required this.saha, 
    required this.tarih, 
    required this.saat,
    required this.sonTutar,
  });

  @override
  State<OdemeEkrani> createState() => _OdemeEkraniState();
}

class _OdemeEkraniState extends State<OdemeEkrani> {
  bool _yukleniyor = false;
  int _secilenYontem = 0; // 0: Kart, 1: Kapora

  // Controllerlar
  final TextEditingController _kartNoController = TextEditingController();
  final TextEditingController _isimController = TextEditingController();
  final TextEditingController _sktController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  void _odemeyiTamamla() async {
    // Validasyonlar (Kısa tutuyorum)
    if (_kartNoController.text.length < 16 || _cvvController.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen kart bilgilerini eksiksiz girin."), backgroundColor: Colors.red));
      return;
    }

    setState(() => _yukleniyor = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    RezervasyonServisi.rezervasyonEkle(saha: widget.saha, tarih: widget.tarih, saat: widget.saat);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ödeme Başarılı! 🎉"), backgroundColor: Colors.green));
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AnasayfaEkrani()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    double odenecekTutar = _secilenYontem == 0 ? widget.sonTutar : (widget.sonTutar * 0.30);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Güvenli Ödeme", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- GÜZEL KART TASARIMI (GERİ GELDİ!) ---
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                // O sevdiğin Gradient
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF334155)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Üst İkonlar
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.nfc, color: Colors.white70, size: 35),
                      Icon(Icons.credit_card, color: Colors.white, size: 35), // Visa logosu yerine şık ikon
                    ],
                  ),
                  
                  // Kart Numarası (Anlık Değişir)
                  Text(
                    _kartNoController.text.isEmpty ? "**** **** **** ****" : _kartNoController.text,
                    style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 3, fontFamily: 'Courier', fontWeight: FontWeight.bold),
                  ),

                  // Alt Bilgiler
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("KART SAHİBİ", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(
                            _isimController.text.isEmpty ? "AD SOYAD" : _isimController.text.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("SKT", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(
                            _sktController.text.isEmpty ? "MM/YY" : _sktController.text,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // YÖNTEM SEÇİMİ
            Row(
              children: [
                _odemeYontemiSec(0, "Tamamını Öde", Icons.credit_card),
                const SizedBox(width: 15),
                _odemeYontemiSec(1, "Kapora (%30)", Icons.pie_chart),
              ],
            ),

            const SizedBox(height: 25),

            // INPUTLAR
            _inputAlani(_isimController, "Kart Üzerindeki İsim", Icons.person),
            const SizedBox(height: 15),
            _inputAlani(_kartNoController, "Kart Numarası", Icons.numbers, isNumber: true, isCard: true),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _inputAlani(_sktController, "AA/YY", Icons.calendar_month, isNumber: true, isDate: true)),
                const SizedBox(width: 15),
                Expanded(child: _inputAlani(_cvvController, "CVV", Icons.lock, isNumber: true, limit: 3)),
              ],
            ),

            const SizedBox(height: 30),

            // BUTON
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 5,
                  shadowColor: const Color(0xFF22C55E).withOpacity(0.4),
                ),
                onPressed: _yukleniyor ? null : _odemeyiTamamla,
                child: _yukleniyor 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "${odenecekTutar.toStringAsFixed(0)}₺ - ÖDEMEYİ TAMAMLA", 
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _odemeYontemiSec(int index, String text, IconData icon) {
    bool selected = _secilenYontem == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _secilenYontem = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF22C55E) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: selected ? Colors.transparent : Colors.grey.shade300),
            boxShadow: selected ? [BoxShadow(color: const Color(0xFF22C55E).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))] : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? Colors.white : Colors.grey),
              const SizedBox(height: 5),
              Text(text, style: TextStyle(color: selected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputAlani(TextEditingController controller, String hint, IconData icon, {bool isNumber = false, int? limit, bool isCard = false, bool isDate = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: (val) => setState(() {}), // Her tuşta ekranı yenile (Kart görseli için)
      inputFormatters: [
        if (isNumber) FilteringTextInputFormatter.digitsOnly,
        if (limit != null) LengthLimitingTextInputFormatter(limit),
        if (isCard) _KartFormatlayici(),
        if (isCard) LengthLimitingTextInputFormatter(19),
        if (isDate) _TarihFormatlayici(),
        if (isDate) LengthLimitingTextInputFormatter(5),
      ],
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      ),
    );
  }
}

// Formatlayıcılar (Öncekilerin aynısı, sadeleştirdim)
class _KartFormatlayici extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldVal, TextEditingValue newVal) {
    if (newVal.selection.baseOffset == 0) return newVal;
    String text = newVal.text.replaceAll(' ', '');
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) buffer.write(' ');
    }
    return TextEditingValue(text: buffer.toString(), selection: TextSelection.collapsed(offset: buffer.length));
  }
}

class _TarihFormatlayici extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldVal, TextEditingValue newVal) {
    String text = newVal.text.replaceAll('/', '');
    if (text.length > 2) text = '${text.substring(0, 2)}/${text.substring(2)}';
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}