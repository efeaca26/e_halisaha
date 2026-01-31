import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  
  // Ödeme Yöntemi: 0 = Kredi Kartı (Tamamı), 1 = Nakit (Kapora)
  int _secilenYontem = 0; 

  final TextEditingController _kartNoController = TextEditingController();
  final TextEditingController _isimController = TextEditingController();
  final TextEditingController _sktController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  void _odemeyiTamamla() async {
    // Validasyonlar (Aynı)
    if (_kartNoController.text.isEmpty || _isimController.text.isEmpty || 
        _sktController.text.isEmpty || _cvvController.text.isEmpty) {
      _hataGoster("Lütfen tüm alanları doldurun.");
      return;
    }

    String temizKartNo = _kartNoController.text.replaceAll(' ', '');
    if (temizKartNo.length != 16) {
      _hataGoster("Kart numarası 16 haneli olmalıdır.");
      return;
    }

    if (!_luhnKontrolu(temizKartNo)) {
      _hataGoster("Geçersiz kart numarası! Lütfen kontrol ediniz.");
      return;
    }

    if (_sktController.text.length != 5 || !_sktController.text.contains('/')) {
      _hataGoster("Son kullanma tarihi hatalı (Örn: 12/26)");
      return;
    }
    
    if (_cvvController.text.length != 3) {
      _hataGoster("CVV kodu 3 haneli olmalıdır.");
      return;
    }

    // --- ÖDEME İŞLEMİ ---
    setState(() => _yukleniyor = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    RezervasyonServisi.rezervasyonEkle(
      saha: widget.saha, 
      tarih: widget.tarih, 
      saat: widget.saat
    );

    // Mesajı Duruma Göre Değiştir
    String mesaj = _secilenYontem == 0 
        ? "Ödeme Tamamlandı! İyi eğlenceler. 🎉"
        : "Kapora Alındı! Kalan tutarı sahada ödeyebilirsiniz. 🎉";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AnasayfaEkrani()),
      (route) => false,
    );
  }

  void _hataGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mesaj), backgroundColor: Colors.red, duration: const Duration(seconds: 2)),
    );
  }

  bool _luhnKontrolu(String kartNo) {
    int sum = 0;
    bool alternate = false;
    for (int i = kartNo.length - 1; i >= 0; i--) {
      int n = int.parse(kartNo[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n = (n % 10) + 1;
      }
      sum += n;
      alternate = !alternate;
    }
    return (sum % 10 == 0);
  }

  @override
  Widget build(BuildContext context) {
    // --- HESAPLAMALAR ---
    double toplamTutar = widget.saha.fiyat;
    double odenecekTutar = _secilenYontem == 0 ? toplamTutar : (toplamTutar * 0.30); // %30 Kapora
    double kalanTutar = _secilenYontem == 0 ? 0 : (toplamTutar - odenecekTutar);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Daha modern gri arka plan
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
            // --- ÖDEME YÖNTEMİ SEÇİMİ ---
            const Text("Ödeme Yöntemi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _odemeYontemiKarti(
                  index: 0, 
                  baslik: "Tamamını Öde", 
                  altBaslik: "Kredi Kartı", 
                  ikon: Icons.credit_card
                ),
                const SizedBox(width: 12),
                _odemeYontemiKarti(
                  index: 1, 
                  baslik: "Kapora Ver", 
                  altBaslik: "%30 Şimdi, Kalan Elden", 
                  ikon: Icons.money
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // --- KART GÖRSELİ ---
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15)],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.credit_card, color: Colors.white, size: 30),
                  Text(_kartNoController.text.isEmpty ? "**** **** **** ****" : _kartNoController.text, style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2, fontFamily: 'Courier')),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_isimController.text.isEmpty ? "AD SOYAD" : _isimController.text.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(_sktController.text.isEmpty ? "MM/YY" : _sktController.text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // --- FORM ALANLARI ---
            _formAlani(controller: _isimController, hint: "Kart Üzerindeki İsim", icon: Icons.person, onChanged: (v) => setState((){})),
            const SizedBox(height: 16),
            _formAlani(controller: _kartNoController, hint: "Kart Numarası", icon: Icons.credit_card_outlined, klavyeTipi: TextInputType.number, onChanged: (v) => setState((){}), formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16), _KartNumarasiFormatter()]),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _formAlani(controller: _sktController, hint: "AA/YY", icon: Icons.calendar_today, klavyeTipi: TextInputType.number, onChanged: (v) => setState((){}), formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4), _KartTarihiFormatter()])),
                const SizedBox(width: 16),
                Expanded(child: _formAlani(controller: _cvvController, hint: "CVV", icon: Icons.lock_outline, klavyeTipi: TextInputType.number, formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)])),
              ],
            ),

            const SizedBox(height: 30),
            
            // --- DETAYLI ÖZET BİLGİ ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _ozetSatir("Saha Ücreti", "${toplamTutar.toStringAsFixed(0)}₺"),
                  const Divider(height: 20),
                  if (_secilenYontem == 1) ...[
                    _ozetSatir("Kapora (%30)", "${odenecekTutar.toStringAsFixed(0)}₺", renk: Colors.black, kalin: true),
                    const SizedBox(height: 8),
                    _ozetSatir("Elden Ödenecek", "${kalanTutar.toStringAsFixed(0)}₺", renk: Colors.orange.shade800),
                    const Divider(height: 20),
                  ],
                  _ozetSatir(
                    "Şimdi Ödenecek", 
                    "${odenecekTutar.toStringAsFixed(0)}₺", 
                    renk: const Color(0xFF22C55E), 
                    kalin: true, 
                    buyuk: true
                  ),
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
                  : Text(
                      "${odenecekTutar.toStringAsFixed(0)}₺ Öde ve Onayla", 
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ödeme Yöntemi Seçim Kartı
  Widget _odemeYontemiKarti({required int index, required String baslik, required String altBaslik, required IconData ikon}) {
    bool secili = _secilenYontem == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _secilenYontem = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: secili ? const Color(0xFFF0FDF4) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: secili ? const Color(0xFF22C55E) : Colors.grey.shade300,
              width: secili ? 2 : 1
            ),
          ),
          child: Column(
            children: [
              Icon(ikon, color: secili ? const Color(0xFF22C55E) : Colors.grey, size: 28),
              const SizedBox(height: 8),
              Text(baslik, style: TextStyle(fontWeight: FontWeight.bold, color: secili ? Colors.black : Colors.grey.shade700, fontSize: 14)),
              const SizedBox(height: 4),
              Text(altBaslik, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: secili ? const Color(0xFF15803D) : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ozetSatir(String baslik, String deger, {Color renk = Colors.black, bool kalin = false, bool buyuk = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(baslik, style: TextStyle(color: Colors.grey.shade600, fontSize: buyuk ? 16 : 14)),
        Text(deger, style: TextStyle(color: renk, fontWeight: kalin ? FontWeight.bold : FontWeight.normal, fontSize: buyuk ? 22 : 14)),
      ],
    );
  }

  Widget _formAlani({required TextEditingController controller, required String hint, required IconData icon, TextInputType klavyeTipi = TextInputType.text, List<TextInputFormatter>? formatters, Function(String)? onChanged}) {
    return TextField(
      controller: controller, keyboardType: klavyeTipi, inputFormatters: formatters, onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint, prefixIcon: Icon(icon, color: Colors.grey), filled: true, fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF22C55E))),
      ),
    );
  }
}

class _KartNumarasiFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) return newValue;
    String girilenVeri = newValue.text;
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < girilenVeri.length; i++) {
      buffer.write(girilenVeri[i]);
      int index = i + 1;
      if (index % 4 == 0 && girilenVeri.length != index) buffer.write(" ");
    }
    return TextEditingValue(text: buffer.toString(), selection: TextSelection.collapsed(offset: buffer.toString().length));
  }
}

class _KartTarihiFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String yeniMetin = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < yeniMetin.length; i++) {
      buffer.write(yeniMetin[i]);
      int index = i + 1;
      if (index == 2 && yeniMetin.length != index) buffer.write("/");
    }
    return TextEditingValue(text: buffer.toString(), selection: TextSelection.collapsed(offset: buffer.toString().length));
  }
}