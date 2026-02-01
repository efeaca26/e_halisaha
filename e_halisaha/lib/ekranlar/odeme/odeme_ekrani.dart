import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math'; // Animasyon için (pi sayısı)
import '../../modeller/saha_modeli.dart';
import '../../cekirdek/servisler/rezervasyon_servisi.dart'; // Rezervasyon servisi
import '../../cekirdek/servisler/odeme_servisi.dart'; // Kart servisi
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
    required this.sonTutar
  });

  @override
  State<OdemeEkrani> createState() => _OdemeEkraniState();
}

class _OdemeEkraniState extends State<OdemeEkrani> {
  bool _yukleniyor = false;
  int _secilenYontem = 0; // 0: Tamamı, 1: Kapora
  bool _arkaYuzMu = false; // Kart dönme durumu

  // Form Kontrolcüleri
  final TextEditingController _kartNoController = TextEditingController();
  final TextEditingController _isimController = TextEditingController();
  final TextEditingController _sktController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  
  final FocusNode _cvvFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // CVV alanına tıklanınca kartı arkaya çevir
    _cvvFocus.addListener(() {
      setState(() {
        _arkaYuzMu = _cvvFocus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _cvvFocus.dispose();
    super.dispose();
  }

  void _odemeyiTamamla() async {
    // 1. Basit Doğrulama
    if (_kartNoController.text.replaceAll(' ', '').length < 16 || _cvvController.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen kart bilgilerini eksiksiz girin."), backgroundColor: Colors.red)
      );
      return;
    }

    setState(() => _yukleniyor = true);

    // 2. Banka simülasyonu (2 saniye bekle)
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    // --- 3. REZERVASYONU KAYDET (DÜZELTİLEN KISIM) ---
    // Artık rezervasyonYap fonksiyonunu kullanıyoruz ve ID gönderiyoruz
    RezervasyonServisi.rezervasyonYap(
      widget.saha.id, 
      widget.tarih, 
      widget.saat, 
      "Ödeme Yapıldı - Uygulama" // Not olarak ekliyoruz
    );
    // -------------------------------------------------

    // 4. KARTI CÜZDANA KAYDET
    if (_kartNoController.text.isNotEmpty) {
      OdemeServisi.kartEkle(
        _kartNoController.text, 
        _isimController.text.isEmpty ? "Kullanılan Kart" : _isimController.text
      );
    }

    // 5. Başarı Mesajı ve Yönlendirme
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ödeme Başarılı! Rezervasyon Oluşturuldu 🎉"), backgroundColor: Colors.green)
    );
    
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (context) => const AnasayfaEkrani()), 
      (route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    double odenecekTutar = _secilenYontem == 0 ? widget.sonTutar : (widget.sonTutar * 0.30); // Kapora mantığı burada basitçe tutarı böler, gerçekte kapora tutarı modelden gelmeli ama şimdilik oranla yapıyoruz.

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Güvenli Ödeme")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- KART ANİMASYONU ---
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: _arkaYuzMu ? 1 : 0),
              duration: const Duration(milliseconds: 600),
              builder: (context, double val, child) {
                double angle = val * pi;
                bool isFront = angle < (pi / 2);

                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  alignment: Alignment.center,
                  child: isFront 
                      ? _kartOnYuz() 
                      : Transform(
                          alignment: Alignment.center, 
                          transform: Matrix4.identity()..rotateY(pi), 
                          child: _kartArkaYuz()
                        ),
                );
              },
            ),
            
            const SizedBox(height: 30),

            // ÖDEME YÖNTEMİ SEÇİMİ
            Row(children: [
              _odemeYontemiSec(0, "Tamamını Öde", Icons.credit_card),
              const SizedBox(width: 15),
              _odemeYontemiSec(1, "Kapora (%30)", Icons.pie_chart)
            ]),

            const SizedBox(height: 25),

            // --- INPUT ALANLARI ---
            _inputAlani(_isimController, "Kart Üzerindeki İsim", Icons.person, limit: 26),
            const SizedBox(height: 15),
            
            _inputAlani(
              _kartNoController, 
              "Kart Numarası", 
              Icons.numbers, 
              isNumber: true, 
              isCard: true 
            ),
            
            const SizedBox(height: 15),
            
            Row(
              children: [
                Expanded(child: _inputAlani(_sktController, "AA/YY", Icons.calendar_month, isNumber: true, isDate: true)),
                const SizedBox(width: 15),
                Expanded(child: _inputAlani(_cvvController, "CVV", Icons.lock, isNumber: true, limit: 3, focusNode: _cvvFocus)),
              ],
            ),

            const SizedBox(height: 30),

            // ÖDE BUTONU
            SizedBox(
              width: double.infinity, height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                ),
                onPressed: _yukleniyor ? null : _odemeyiTamamla,
                child: _yukleniyor 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : Text(
                      "${odenecekTutar.toStringAsFixed(0)}₺ Öde", 
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- KART ÖN YÜZ TASARIMI ---
  Widget _kartOnYuz() {
    return Container(
      height: 220, width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF334155)], 
          begin: Alignment.topLeft, 
          end: Alignment.bottomRight
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(Icons.nfc, color: Colors.white70, size: 35), 
            Icon(Icons.credit_card, color: Colors.white, size: 35)
          ]),
          
          Text(
            _kartNoController.text.isEmpty ? "**** **** **** ****" : _kartNoController.text,
            style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2, fontFamily: 'Courier', fontWeight: FontWeight.bold)
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    const Text("KART SAHİBİ", style: TextStyle(color: Colors.white54, fontSize: 10)),
                    Text(
                      _isimController.text.isEmpty ? "AD SOYAD" : _isimController.text.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )
                  ]
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  const Text("SKT", style: TextStyle(color: Colors.white54, fontSize: 10)), 
                  Text(
                    _sktController.text.isEmpty ? "MM/YY" : _sktController.text, 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  )
                ]
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- KART ARKA YÜZ TASARIMI ---
  Widget _kartArkaYuz() {
    return Container(
      height: 220, width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF334155), 
        borderRadius: BorderRadius.circular(25), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Container(height: 50, color: Colors.black), // Manyetik Şerit
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: Container(height: 40, color: Colors.grey[300])), // İmza bandı
                Container(
                  width: 60, height: 40, 
                  alignment: Alignment.center, 
                  color: Colors.white, 
                  child: Text(
                    _cvvController.text, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)
                  )
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(right: 20), 
            child: Align(
              alignment: Alignment.centerRight, 
              child: Text("CVV", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
            )
          )
        ],
      ),
    );
  }

  // --- YARDIMCI WIDGETLAR ---
  Widget _odemeYontemiSec(int index, String text, IconData icon) {
    bool selected = _secilenYontem == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _secilenYontem = index), 
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15), 
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF22C55E) : Theme.of(context).cardColor, 
            borderRadius: BorderRadius.circular(15), 
            border: Border.all(color: selected ? Colors.transparent : Colors.grey.shade300)
          ), 
          child: Column(
            children: [
              Icon(icon, color: selected ? Colors.white : Colors.grey), 
              const SizedBox(height: 5), 
              Text(text, style: TextStyle(color: selected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold))
            ]
          )
        )
      )
    );
  }

  Widget _inputAlani(
    TextEditingController controller, 
    String hint, 
    IconData icon, 
    {bool isNumber = false, int? limit, bool isCard = false, bool isDate = false, FocusNode? focusNode}
  ) {
    return TextField(
      controller: controller, 
      focusNode: focusNode,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: (val) => setState(() {}),
      inputFormatters: [
        if (isNumber) FilteringTextInputFormatter.digitsOnly,
        if (limit != null) LengthLimitingTextInputFormatter(limit),
        if (isCard) _KartFormatlayici(), 
        if (isCard) LengthLimitingTextInputFormatter(19),
        if (isDate) _TarihFormatlayici(),
        if (isDate) LengthLimitingTextInputFormatter(5),
      ],
      decoration: InputDecoration(
        prefixIcon: Icon(icon), 
        hintText: hint, 
        filled: true, 
        fillColor: Theme.of(context).cardColor, 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
      ),
    );
  }
}

// --- FORMATLAYICILAR ---
class _KartFormatlayici extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length < oldValue.text.length) return newValue;
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) buffer.write(' ');
    }
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}

class _TarihFormatlayici extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length < oldValue.text.length) return newValue;
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length) buffer.write('/');
    }
    var string = buffer.toString();
    return newValue.copyWith(text: string, selection: TextSelection.collapsed(offset: string.length));
  }
}