import 'package:flutter/material.dart';
import '../../servisler/api_servisi.dart'; // Az önce yazdığımız dosya
import '../anasayfa/anasayfa_ekrani.dart'; // Anasayfa dosyanın yolu

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> with TickerProviderStateMixin {
  late AnimationController _topKontrolcusu;
  late AnimationController _icerikKontrolcusu;
  late Animation<double> _topDusmeAnimasyonu;
  late Animation<double> _icerikOpaklik;
  late Animation<Offset> _icerikKayma;

  late TabController _tabController;
  bool isletmeModu = false;
  bool _yukleniyor = false; // Yükleniyor çarkı için
  
  bool _girisSifreGizli = true; 
  bool _kayitSifreGizli = true; 

  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();
  final _kayitIsimController = TextEditingController();
  final _kayitEmailController = TextEditingController();
  final _kayitSifreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // --- ANİMASYON AYARLARI ---
    _topKontrolcusu = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _topDusmeAnimasyonu = Tween<double>(begin: -350, end: 0).animate(CurvedAnimation(parent: _topKontrolcusu, curve: Curves.bounceOut));

    _icerikKontrolcusu = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _icerikOpaklik = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _icerikKontrolcusu, curve: Curves.easeIn));
    _icerikKayma = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _icerikKontrolcusu, curve: Curves.easeOutCubic));

    _baslat();
  }

  void _baslat() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _topKontrolcusu.forward(); 
    await Future.delayed(const Duration(milliseconds: 800));
    _icerikKontrolcusu.forward(); 
  }

  // --- GİRİŞ YAP BUTONUNA BASINCA ---
  void _girisYap() async {
    if (_emailController.text.isEmpty || _sifreController.text.isEmpty) {
      _mesajGoster("Lütfen alanları doldurun", kirmizi: true);
      return;
    }

    setState(() => _yukleniyor = true); // Çark dönsün

    // GERÇEK SUNUCUYA İSTEK ATIYORUZ
    bool basarili = await ApiServisi.girisYap(
      _emailController.text.trim(),
      _sifreController.text.trim(),
      isletmeModu
    );

    setState(() => _yukleniyor = false); // Çark dursun

    if (basarili) {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AnasayfaEkrani()));
    } else {
      _mesajGoster("Giriş Başarısız! Sunucu kapalı olabilir.", kirmizi: true);
    }
  }

  // --- KAYIT OL BUTONUNA BASINCA ---
  void _kayitOl() async {
    if (_kayitIsimController.text.isEmpty || _kayitEmailController.text.isEmpty || _kayitSifreController.text.isEmpty) {
      _mesajGoster("Eksik bilgi girdiniz", kirmizi: true);
      return;
    }

    setState(() => _yukleniyor = true);

    bool basarili = await ApiServisi.kayitOl(
      _kayitIsimController.text.trim(),
      _kayitEmailController.text.trim(),
      _kayitSifreController.text.trim(),
      isletmeModu
    );

    setState(() => _yukleniyor = false);

    if (basarili) {
      _mesajGoster("Kayıt Başarılı! Şimdi giriş yapabilirsin.");
      _tabController.animateTo(0); // Giriş sekmesine geç
    } else {
      _mesajGoster("Kayıt olunamadı.", kirmizi: true);
    }
  }

  void _mesajGoster(String mesaj, {bool kirmizi = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj), backgroundColor: kirmizi ? Colors.red : Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF0FDF4), Color(0xFFEFF6FF)]),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Column(
            children: [
              const SizedBox(height: 50),
              // Animasyonlu Top
              AnimatedBuilder(
                animation: _topDusmeAnimasyonu,
                builder: (context, child) => Transform.translate(offset: Offset(0, _topDusmeAnimasyonu.value), child: const Icon(Icons.sports_soccer, size: 80, color: Color(0xFF22C55E))),
              ),
              const SizedBox(height: 30),
              // İçerik
              FadeTransition(
                opacity: _icerikOpaklik,
                child: SlideTransition(
                  position: _icerikKayma,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)]),
                    child: Column(
                      children: [
                        // Rol Seçici
                        Row(children: [_rolButonu("Oyuncu", !isletmeModu), _rolButonu("İşletme", isletmeModu)]),
                        const SizedBox(height: 20),
                        // Tablar (Giriş / Kayıt)
                        TabBar(
                          controller: _tabController,
                          labelColor: Colors.green,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.green,
                          tabs: const [Tab(text: "Giriş Yap"), Tab(text: "Kayıt Ol")],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 300,
                          child: TabBarView(
                            controller: _tabController,
                            children: [_girisFormu(), _kayitFormu()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rolButonu(String text, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isletmeModu = text == "İşletme"),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: active ? Colors.green[50] : Colors.transparent, borderRadius: BorderRadius.circular(8)),
          child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: active ? Colors.green : Colors.grey, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _girisFormu() {
    return Column(
      children: [
        TextField(controller: _emailController, decoration: const InputDecoration(hintText: "E-Posta", prefixIcon: Icon(Icons.email_outlined))),
        const SizedBox(height: 15),
        TextField(controller: _sifreController, obscureText: _girisSifreGizli, decoration: InputDecoration(hintText: "Şifre", prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(_girisSifreGizli ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _girisSifreGizli = !_girisSifreGizli)))),
        const Spacer(),
        _yukleniyor ? const CircularProgressIndicator() : ElevatedButton(onPressed: _girisYap, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E), minimumSize: const Size(double.infinity, 50)), child: const Text("GİRİŞ YAP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _kayitFormu() {
    return Column(
      children: [
        TextField(controller: _kayitIsimController, decoration: const InputDecoration(hintText: "Ad Soyad", prefixIcon: Icon(Icons.person_outline))),
        const SizedBox(height: 10),
        TextField(controller: _kayitEmailController, decoration: const InputDecoration(hintText: "E-Posta", prefixIcon: Icon(Icons.email_outlined))),
        const SizedBox(height: 10),
        TextField(controller: _kayitSifreController, obscureText: _kayitSifreGizli, decoration: InputDecoration(hintText: "Şifre", prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(_kayitSifreGizli ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _kayitSifreGizli = !_kayitSifreGizli)))),
        const Spacer(),
        _yukleniyor ? const CircularProgressIndicator() : ElevatedButton(onPressed: _kayitOl, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E), minimumSize: const Size(double.infinity, 50)), child: const Text("KAYIT OL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ],
    );
  }
}