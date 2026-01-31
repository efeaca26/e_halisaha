import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Klavye formatlayıcıları için şart
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

  final TextEditingController _kartNoController = TextEditingController();
  final TextEditingController _isimController = TextEditingController();
  final TextEditingController _sktController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // --- VALIDASYON VE ÖDEME ---
  void _odemeyiTamamla() async {
    // 1. Temel Boşluk Kontrolü
    if (_kartNoController.text.isEmpty || _isimController.text.isEmpty || 
        _sktController.text.isEmpty || _cvvController.text.isEmpty) {
      _hataGoster("Lütfen tüm alanları doldurun.");
      return;
    }

    // 2. Kart Numarası Uzunluk Kontrolü (Boşlukları silip sayıyoruz)
    String temizKartNo = _kartNoController.text.replaceAll(' ', '');
    if (temizKartNo.length != 16) {
      _hataGoster("Kart numarası 16 haneli olmalıdır.");
      return;
    }

    // 3. LUHN ALGORİTMASI (Gerçek Kart Kontrolü)
    if (!_luhnKontrolu(temizKartNo)) {
      _hataGoster("Geçersiz kart numarası! Lütfen kontrol ediniz.");
      return;
    }

    // 4. SKT Kontrolü (MM/YY formatı ve Mantık)
    if (_sktController.text.length != 5 || !_sktController.text.contains('/')) {
      _hataGoster("Son kullanma tarihi hatalı (Örn: 12/26)");
      return;
    }
    int ay = int.tryParse(_sktController.text.split('/')[0]) ?? 0;
    int yil = int.tryParse(_sktController.text.split('/')[1]) ?? 0;
    
    if (ay < 1 || ay > 12) {
      _hataGoster("Geçersiz ay girdiniz.");
      return;
    }
    // Basit bir yıl kontrolü (Geçmiş yıl olamaz)
    int buYil = DateTime.now().year % 100; // 2024 -> 24
    if (yil < buYil) {
      _hataGoster("Kartınızın süresi dolmuş.");
      return;
    }

    // 5. CVV Kontrolü
    if (_cvvController.text.length != 3) {
      _hataGoster("CVV kodu 3 haneli olmalıdır.");
      return;
    }

    // --- HER ŞEY DOĞRUYSA DEVAM ET ---
    setState(() => _yukleniyor = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    RezervasyonServisi.rezervasyonEkle(
      saha: widget.saha, 
      tarih: widget.tarih, 
      saat: widget.saat
    );

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

  void _hataGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mesaj), backgroundColor: Colors.red, duration: const Duration(seconds: 2)),
    );
  }

  // Dünyaca ünlü Luhn Algoritması (Kredi kartı numarasının matematiksel doğruluğunu ölçer)
  bool _luhnKontrolu(String kartNo) {
    int sum = 0;
    bool alternate = false;
    for (int i = kartNo.length - 1; i >= 0; i--) {
      int n = int.parse(kartNo[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      sum += n;
      alternate = !alternate;
    }
    return (sum % 10 == 0);
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
          children: [
            // --- KART GÖRSELİ (AYNI) ---
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

            // --- GELİŞMİŞ INPUTLAR ---
            _formAlani(
              controller: _isimController, 
              hint: "Kart Üzerindeki İsim", 
              icon: Icons.person, 
              // İsimde sadece harf olur (İsteğe bağlı, şimdilik serbest bıraktık)
              onChanged: (v) => setState((){})
            ),
            const SizedBox(height: 16),
            
            _formAlani(
              controller: _kartNoController, 
              hint: "Kart Numarası", 
              icon: Icons.credit_card_outlined, 
              klavyeTipi: TextInputType.number,
              onChanged: (v) => setState((){}),
              formatters: [
                FilteringTextInputFormatter.digitsOnly, // Sadece sayı
                LengthLimitingTextInputFormatter(16),   // En fazla 16 rakam
                _KartNumarasiFormatter(),               // 4'erli boşluk koyan özel kod
              ]
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _formAlani(
                    controller: _sktController, 
                    hint: "AA/YY", 
                    icon: Icons.calendar_today, 
                    klavyeTipi: TextInputType.number,
                    onChanged: (v) => setState((){}),
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4), // Sadece 4 rakam (1225 gibi)
                      _KartTarihiFormatter(),              // Araya / koyan özel kod
                    ]
                  )
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _formAlani(
                    controller: _cvvController, 
                    hint: "CVV", 
                    icon: Icons.lock_outline, 
                    klavyeTipi: TextInputType.number,
                    formatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3), // En fazla 3 rakam
                    ]
                  )
                ),
              ],
            ),

            const SizedBox(height: 30),

            // BUTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: _yukleniyor ? null : _odemeyiTamamla,
                child: _yukleniyor ? const CircularProgressIndicator(color: Colors.white) : const Text("Ödemeyi Onayla", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
    List<TextInputFormatter>? formatters,
    Function(String)? onChanged
  }) {
    return TextField(
      controller: controller,
      keyboardType: klavyeTipi,
      inputFormatters: formatters, // Formatlayıcıları buraya ekledik
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

// --- ÖZEL FORMATLAYICILAR ---

// 1. Kart Numarası için (1234 5678...)
class _KartNumarasiFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) return newValue;
    String girilenVeri = newValue.text;
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < girilenVeri.length; i++) {
      buffer.write(girilenVeri[i]);
      int index = i + 1;
      if (index % 4 == 0 && girilenVeri.length != index) {
        buffer.write(" "); // Her 4 rakamda bir boşluk ekle
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.toString().length),
    );
  }
}

// 2. Tarih için (12/25)
class _KartTarihiFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String yeniMetin = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < yeniMetin.length; i++) {
      buffer.write(yeniMetin[i]);
      int index = i + 1;
      if (index == 2 && yeniMetin.length != index) {
        buffer.write("/"); // 2. rakamdan sonra / ekle
      }
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.toString().length),
    );
  }
}