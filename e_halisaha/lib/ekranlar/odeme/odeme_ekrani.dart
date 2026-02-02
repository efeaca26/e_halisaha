import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';
import '../../modeller/saha_modeli.dart';
import '../../cekirdek/servisler/rezervasyon_servisi.dart';
import '../../cekirdek/servisler/odeme_servisi.dart';
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
  int _secilenYontem = 0; // 0: Kart Tamamı, 1: Kart Kapora, 2: IBAN
  bool _arkaYuzMu = false;

  Timer? _zamanlayici;
  int _kalanSaniye = 300; // 5 Dakika

  final TextEditingController _kartNoController = TextEditingController();
  final TextEditingController _isimController = TextEditingController();
  final TextEditingController _sktController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final FocusNode _cvvFocus = FocusNode();

  final String _ibanNo = "TR12 0006 1005 4567 8901 2345 67";
  final String _aliciIsim = "Yıldız Spor Tesisleri A.Ş.";

  @override
  void initState() {
    super.initState();
    _sayaciBaslat();
    _cvvFocus.addListener(() {
      setState(() => _arkaYuzMu = _cvvFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _zamanlayici?.cancel();
    _cvvFocus.dispose();
    super.dispose();
  }

  void _sayaciBaslat() {
    _zamanlayici = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_kalanSaniye > 0) {
        setState(() => _kalanSaniye--);
      } else {
        timer.cancel();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Süre doldu!"), backgroundColor: Colors.red));
        }
      }
    });
  }

  String get _formatliSure {
    int dakika = _kalanSaniye ~/ 60;
    int saniye = _kalanSaniye % 60;
    return "${dakika.toString().padLeft(2, '0')}:${saniye.toString().padLeft(2, '0')}";
  }

  void _islemYap() async {
    if (_secilenYontem == 2) {
       _ibanIleOde();
       return;
    }

    if (_kartNoController.text.replaceAll(' ', '').length < 16 || _cvvController.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kart bilgileri eksik."), backgroundColor: Colors.red));
      return;
    }

    setState(() => _yukleniyor = true);
    await Future.delayed(const Duration(seconds: 2));
    
    RezervasyonServisi.rezervasyonYap(widget.saha.id, widget.tarih, widget.saat, "Kredi Kartı Ödemesi", beklemede: false);
    
    if (_kartNoController.text.isNotEmpty) {
      OdemeServisi.kartEkle(_kartNoController.text, _isimController.text.isEmpty ? "Kart" : _isimController.text);
    }
    
    _basariylaBitir("Ödeme Alındı, Rezervasyon Onaylandı! 🎉");
  }

  void _ibanIleOde() {
    RezervasyonServisi.rezervasyonYap(widget.saha.id, widget.tarih, widget.saat, "IBAN Transferi - Dekont Bekleniyor", beklemede: true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("WhatsApp'a Yönlendiriliyor"),
        content: const Text("Lütfen açılan WhatsApp ekranında dekontu paylaşınız.\n\nİşletme dekontu kontrol edip onaylayacaktır."),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _basariylaBitir("Talep oluşturuldu! İşletme onayı bekleniyor. ⏳");
            },
            child: const Text("Tamam, Dekontu Attım"),
          )
        ],
      ),
    );
  }

  void _basariylaBitir(String mesaj) {
    if (!mounted) return;
    _zamanlayici?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj), backgroundColor: Colors.green));
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AnasayfaEkrani()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // --- FİYAT VE KALAN BORÇ HESAPLAMA ---
    double toplamTutar = widget.sonTutar;
    double odenecekTutar = toplamTutar; 
    double kalanTutar = 0; // Sahada ödenecek kısım
    
    if (_secilenYontem == 1) { // Kapora ise
      odenecekTutar = toplamTutar * 0.30;
      kalanTutar = toplamTutar - odenecekTutar; // Geriye kalan borç
    }
    // -------------------------------------

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Ödeme Ekranı"),
        actions: [
           Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: _kalanSaniye < 60 ? Colors.red : Colors.grey[800], borderRadius: BorderRadius.circular(20)),
            child: Row(children: [const Icon(Icons.timer, color: Colors.white, size: 16), const SizedBox(width: 6), Text(_formatliSure, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))]),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- KART GÖRSELİ ---
            if (_secilenYontem != 2) 
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: _arkaYuzMu ? 1 : 0),
                duration: const Duration(milliseconds: 600),
                builder: (context, double val, child) {
                  double angle = val * pi;
                  bool isFront = angle < (pi / 2);
                  return Transform(
                    transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle),
                    alignment: Alignment.center,
                    child: isFront ? _kartOnYuz() : Transform(alignment: Alignment.center, transform: Matrix4.identity()..rotateY(pi), child: _kartArkaYuz()),
                  );
                },
              )
            else
              const Icon(Icons.account_balance, size: 100, color: Color(0xFF22C55E)),
            
            const SizedBox(height: 20),

            // --- DETAYLI FİYAT BİLGİSİ KUTUSU ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
              ),
              child: Column(
                children: [
                  // 1. Satır: Toplam Borç
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Maç Ücreti:", style: TextStyle(color: Colors.grey)),
                      Text(
                        "${toplamTutar.toStringAsFixed(0)}₺", 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          decoration: _secilenYontem == 1 ? TextDecoration.lineThrough : null, // Kapora seçiliyse üstünü çiz
                          color: _secilenYontem == 1 ? Colors.grey : Colors.black
                        )
                      ),
                    ],
                  ),

                  // 2. Satır: Kapora Seçiliyse Detaylar
                  if (_secilenYontem == 1) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Kapora (%30):", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                          Text("${odenecekTutar.toStringAsFixed(0)}₺", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                        ],
                      ),
                    ),
                    // --- YENİ EKLENEN KISIM: KALAN BORÇ ---
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Sahada Ödenecek:", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                          Text("${kalanTutar.toStringAsFixed(0)}₺", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],

                  const Divider(height: 20),
                  
                  // 3. Satır: Şimdi Ödenecek (Vurgulu)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_secilenYontem == 2 ? "TRANSFER TUTARI:" : "ŞİMDİ ÖDENECEK:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("${odenecekTutar.toStringAsFixed(0)}₺", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF22C55E))),
                    ],
                  ),
                ],
              ),
            ),
            // ------------------------------------------

            const SizedBox(height: 20),

            Row(children: [
              _odemeYontemiSec(0, "Tamamı", Icons.credit_card),
              const SizedBox(width: 10),
              _odemeYontemiSec(1, "Kapora", Icons.pie_chart),
              const SizedBox(width: 10),
              _odemeYontemiSec(2, "IBAN", Icons.account_balance),
            ]),
            
            const SizedBox(height: 30),

            if (_secilenYontem == 2) ...[
              // IBAN EKRANI (Aynı Kaldı)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
                child: Column(
                  children: [
                    const Text("Banka Transferi / EFT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    const Text("Alıcı:", style: TextStyle(color: Colors.grey)),
                    Text(_aliciIsim, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    const Text("IBAN:", style: TextStyle(color: Colors.grey)),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _ibanNo));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("IBAN Kopyalandı!")));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_ibanNo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            const SizedBox(width: 10),
                            const Icon(Icons.copy, size: 18, color: Colors.green),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange),
                          SizedBox(width: 10),
                          Expanded(child: Text("Lütfen açıklama kısmına Adınızı Soyadınızı yazınız.", style: TextStyle(fontSize: 12, color: Colors.black87))),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ] 
            else ...[
              // KART GİRİŞ ALANLARI (Aynı Kaldı)
              const SizedBox(height: 10),
              _inputAlani(_isimController, "Kart Üzerindeki İsim", Icons.person, limit: 26),
              const SizedBox(height: 15),
              _inputAlani(_kartNoController, "Kart Numarası", Icons.numbers, isNumber: true, isCard: true),
              const SizedBox(height: 15),
              Row(children: [
                Expanded(child: _inputAlani(_sktController, "AA/YY", Icons.calendar_month, isNumber: true, isDate: true)),
                const SizedBox(width: 15),
                Expanded(child: _inputAlani(_cvvController, "CVV", Icons.lock, isNumber: true, limit: 3, focusNode: _cvvFocus)),
              ]),
            ],

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity, height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                onPressed: _yukleniyor ? null : _islemYap,
                child: _yukleniyor 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : Text(
                      _secilenYontem == 2 
                        ? "Ödemeyi Yaptım, Bildir" 
                        : "${odenecekTutar.toStringAsFixed(0)}₺ Öde", 
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- KART GÖRSELLERİ (DEĞİŞMEDİ) ---
  Widget _kartOnYuz() {
    return Container(
      height: 220, width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF334155)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(Icons.nfc, color: Colors.white70, size: 35), Icon(Icons.credit_card, color: Colors.white, size: 35)]),
          Text(_kartNoController.text.isEmpty ? "**** **** **** ****" : _kartNoController.text, style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2, fontFamily: 'Courier', fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("KART SAHİBİ", style: TextStyle(color: Colors.white54, fontSize: 10)), Text(_isimController.text.isEmpty ? "AD SOYAD" : _isimController.text.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("SKT", style: TextStyle(color: Colors.white54, fontSize: 10)), Text(_sktController.text.isEmpty ? "MM/YY" : _sktController.text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
            ],
          )
        ],
      ),
    );
  }

  Widget _kartArkaYuz() {
    return Container(
      height: 220, width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(25), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        children: [
          const SizedBox(height: 30), Container(height: 50, color: Colors.black), const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [Expanded(child: Container(height: 40, color: Colors.grey[300])), Container(width: 60, height: 40, alignment: Alignment.center, color: Colors.white, child: Text(_cvvController.text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)))]),
          ),
        ],
      ),
    );
  }

  Widget _odemeYontemiSec(int index, String text, IconData icon) {
    bool selected = _secilenYontem == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _secilenYontem = index), 
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10), 
          decoration: BoxDecoration(color: selected ? const Color(0xFF22C55E) : Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)), 
          child: Column(children: [Icon(icon, color: selected ? Colors.white : Colors.grey), Text(text, style: TextStyle(fontSize: 12, color: selected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold))])
        )
      )
    );
  }

  Widget _inputAlani(TextEditingController controller, String hint, IconData icon, {bool isNumber = false, int? limit, bool isCard = false, bool isDate = false, FocusNode? focusNode}) {
    return TextField(
      controller: controller, focusNode: focusNode, keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: (val) => setState(() {}),
      inputFormatters: [
        if (isNumber) FilteringTextInputFormatter.digitsOnly,
        if (limit != null) LengthLimitingTextInputFormatter(limit),
        if (isCard) _KartFormatlayici(), 
        if (isCard) LengthLimitingTextInputFormatter(19),
        if (isDate) _TarihFormatlayici(),
        if (isDate) LengthLimitingTextInputFormatter(5),
      ],
      decoration: InputDecoration(prefixIcon: Icon(icon), hintText: hint, filled: true, fillColor: Theme.of(context).cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
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