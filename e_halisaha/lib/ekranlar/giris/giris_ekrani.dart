import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Beni hatırla için
import '../../cekirdek/servisler/api_servisi.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';
import '../anasayfa/anasayfa_ekrani.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> with TickerProviderStateMixin {
  final ApiServisi _apiServisi = ApiServisi();
  
  // Formatlayıcılar
  var telefonMaskesi = MaskTextInputFormatter(
    mask: '0### ### ## ##', 
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy
  );

  // Controllerlar
  final _girisEmailController = TextEditingController(); 
  final _girisSifreController = TextEditingController();
  
  final _kayitIsimController = TextEditingController();
  final _kayitEmailController = TextEditingController();
  final _kayitTelefonController = TextEditingController(); // Artık opsiyonel
  final _kayitSifreController = TextEditingController();
  final _kayitSahaAdiController = TextEditingController();
  final _kayitKonumController = TextEditingController();

  late TabController _tabController;
  bool _isletmeModu = false;
  bool _yukleniyor = false;
  bool _sifreGizli = true;
  bool _beniHatirla = false; // Beni Hatırla Checkbox Durumu

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _beniHatirlaBilgileriniYukle();
  }

  // Kayıtlı e-posta varsa getir
  void _beniHatirlaBilgileriniYukle() async {
    final prefs = await SharedPreferences.getInstance();
    String? kayitliEmail = prefs.getString('saved_email');
    if (kayitliEmail != null) {
      setState(() {
        _girisEmailController.text = kayitliEmail;
        _beniHatirla = true;
      });
    }
  }

  // --- GİRİŞ YAP ---
  Future<void> _girisYap() async {
    if (_girisEmailController.text.isEmpty || _girisSifreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen tüm alanları doldurun.")));
      return;
    }

    setState(() => _yukleniyor = true);
    bool basarili = await _apiServisi.girisYap(_girisEmailController.text.trim(), _girisSifreController.text);
    setState(() => _yukleniyor = false);

    if (basarili) {
      // Beni Hatırla Kaydı
      final prefs = await SharedPreferences.getInstance();
      if (_beniHatirla) {
        await prefs.setString('saved_email', _girisEmailController.text.trim());
      } else {
        await prefs.remove('saved_email');
      }

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AnasayfaEkrani()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Giriş başarısız! Bilgileri kontrol edin."), backgroundColor: Colors.red));
    }
  }

  // --- KAYIT OL (Validasyonlu) ---
  Future<void> _kayitOl() async {
    // 1. İsim Kontrolü
    if (_kayitIsimController.text.length < 3) {
      _hataGoster("İsim en az 3 karakter olmalı.");
      return;
    }
    // 2. Email Kontrolü (@ içermeli)
    if (!_kayitEmailController.text.contains('@') || _kayitEmailController.text.length < 5) {
      _hataGoster("Geçerli bir E-posta adresi giriniz.");
      return;
    }
    // 3. Şifre Kontrolü (Min 6 hane)
    if (_kayitSifreController.text.length < 6) {
      _hataGoster("Şifre en az 6 karakter olmalıdır.");
      return;
    }
    // 4. İşletme Kontrolü
    if (_isletmeModu && (_kayitSahaAdiController.text.isEmpty || _kayitKonumController.text.isEmpty)) {
      _hataGoster("İşletme bilgilerini eksiksiz doldurun.");
      return;
    }

    setState(() => _yukleniyor = true);
    
    // API Çağrısı (Yeni Parametre Sırası: İsim, Email, Şifre, Rol...)
    bool basarili = await _apiServisi.kayitOl(
      _kayitIsimController.text.trim(),
      _kayitEmailController.text.trim(), // Email artık 2. sırada ve zorunlu
      _kayitSifreController.text,
      _isletmeModu,
      phoneNumber: _kayitTelefonController.text.isNotEmpty ? _kayitTelefonController.text : null, // Opsiyonel
      pitchName: _isletmeModu ? _kayitSahaAdiController.text : null,
      location: _isletmeModu ? _kayitKonumController.text : null,
    );

    setState(() => _yukleniyor = false);

    if (basarili) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kayıt Başarılı! Giriş yapabilirsiniz."), backgroundColor: Colors.green));
      _tabController.animateTo(0); // Giriş sekmesine geç
    } else {
      _hataGoster("Kayıt başarısız. Bu e-posta kullanılıyor olabilir.");
    }
  }

  void _hataGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final bool koyuMod = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Logo
              Image.asset(
                koyuMod ? 'assets/icon.png' : 'assets/icon.png',
                height: 100
              ),
              const SizedBox(height: 20),
              // Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [Tab(text: "Giriş Yap"), Tab(text: "Kayıt Ol")],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Formlar
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // --- GİRİŞ TAB ---
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextField(
                            controller: _girisEmailController,
                            decoration: const InputDecoration(labelText: "E-posta", prefixIcon: Icon(Icons.email)),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _girisSifreController,
                            obscureText: _sifreGizli,
                            decoration: InputDecoration(
                              labelText: "Şifre", 
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(icon: Icon(_sifreGizli ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _sifreGizli = !_sifreGizli))
                            ),
                          ),
                          
                          // Beni Hatırla & Şifremi Unuttum
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    activeColor: const Color(0xFF22C55E),
                                    value: _beniHatirla, 
                                    onChanged: (val) => setState(() => _beniHatirla = val!)
                                  ),
                                  const Text("Beni Hatırla")
                                ],
                              ),
                              TextButton(
                                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Şifre sıfırlama bağlantısı e-postanıza gönderildi. (Demo)"))),
                                child: const Text("Şifremi Unuttum?", style: TextStyle(color: Colors.grey)),
                              )
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          _yukleniyor 
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _girisYap,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF22C55E),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                ),
                                child: const Text("GİRİŞ YAP", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                        ],
                      ),
                    ),

                    // --- KAYIT TAB ---
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          TextField(controller: _kayitIsimController, decoration: const InputDecoration(labelText: "Ad Soyad", prefixIcon: Icon(Icons.person))),
                          const SizedBox(height: 15),
                          TextField(controller: _kayitEmailController, decoration: const InputDecoration(labelText: "E-posta (Zorunlu)", prefixIcon: Icon(Icons.email)), keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _kayitTelefonController, // Opsiyonel
                            inputFormatters: [telefonMaskesi],
                            decoration: const InputDecoration(labelText: "Telefon (İsteğe Bağlı)", prefixIcon: Icon(Icons.phone)),
                            keyboardType: TextInputType.phone
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _kayitSifreController, 
                            obscureText: true,
                            decoration: const InputDecoration(labelText: "Şifre (Min 6 Karakter)", prefixIcon: Icon(Icons.lock))
                          ),
                          const SizedBox(height: 20),
                          
                          // İşletme Switch
                          Row(
                            children: [
                              Switch(
                                value: _isletmeModu,
                                activeColor: const Color(0xFF22C55E),
                                onChanged: (val) => setState(() => _isletmeModu = val),
                              ),
                              const Text("Halı Saha İşletmecisiyim", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          
                          if (_isletmeModu) ...[
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green)),
                              child: Column(
                                children: [
                                  TextField(controller: _kayitSahaAdiController, decoration: const InputDecoration(labelText: "Saha Adı", prefixIcon: Icon(Icons.stadium))),
                                  const SizedBox(height: 10),
                                  TextField(controller: _kayitKonumController, decoration: const InputDecoration(labelText: "İlçe / Konum", prefixIcon: Icon(Icons.map))),
                                ],
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 25),
                          _yukleniyor 
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _kayitOl,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF22C55E),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                                ),
                                child: const Text("HESAP OLUŞTUR", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                          const SizedBox(height: 30), // Klavye payı
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}