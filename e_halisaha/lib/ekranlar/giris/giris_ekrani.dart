import 'package:flutter/material.dart';
import '../../cekirdek/servisler/api_servisi.dart';
import '../anasayfa/anasayfa_ekrani.dart';

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
  bool _yukleniyor = false; 
  
  bool _girisSifreGizli = true; 
  bool _kayitSifreGizli = true; 

  // ARTIK HEM EMAIL HEM TELEFON GİREBİLİR
  final _girisController = TextEditingController(); // İsmini değiştirdik
  final _sifreController = TextEditingController();
  
  final _kayitIsimController = TextEditingController();
  final _kayitTelefonController = TextEditingController();
  final _kayitSifreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

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

  void _girisYap() async {
    if (_girisController.text.isEmpty || _sifreController.text.isEmpty) {
      _mesajGoster("Lütfen alanları doldurun", kirmizi: true);
      return;
    }

    setState(() => _yukleniyor = true);

    // E-POSTA VEYA TELEFON FARK ETMEZ, SERVİS HALLEDECEK
    bool basarili = await ApiServisi.girisYap(
      _girisController.text.trim(),
      _sifreController.text.trim()
    );

    setState(() => _yukleniyor = false);

    if (basarili) {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AnasayfaEkrani()));
    } else {
      _mesajGoster("Giriş Başarısız! Bilgilerinizi kontrol edin.", kirmizi: true);
    }
  }

  void _kayitOl() async {
    if (_kayitIsimController.text.isEmpty || _kayitTelefonController.text.isEmpty || _kayitSifreController.text.isEmpty) {
      _mesajGoster("Eksik bilgi girdiniz", kirmizi: true);
      return;
    }

    setState(() => _yukleniyor = true);

    bool basarili = await ApiServisi.kayitOl(
      _kayitIsimController.text.trim(),
      _kayitTelefonController.text.trim(), // Kayıtta hala telefon zorunlu
      _kayitSifreController.text.trim(),
      isletmeModu
    );

    setState(() => _yukleniyor = false);

    if (basarili) {
      _mesajGoster("Kayıt Başarılı! Şimdi giriş yapabilirsin.");
      _tabController.animateTo(0);
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
              
              AnimatedBuilder(
                animation: _topDusmeAnimasyonu,
                builder: (context, child) => Transform.translate(offset: Offset(0, _topDusmeAnimasyonu.value), child: const Icon(Icons.sports_soccer, size: 80, color: Color(0xFF22C55E))),
              ),
              
              const SizedBox(height: 20),

              const Text(
                "e-Halisaha",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 1.5),
              ),
              const SizedBox(height: 5),
              const Text(
                "Maçın Adresi",
                style: TextStyle(fontSize: 16, color: Colors.grey, fontStyle: FontStyle.italic),
              ),

              const SizedBox(height: 30),
              
              FadeTransition(
                opacity: _icerikOpaklik,
                child: SlideTransition(
                  position: _icerikKayma,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)]),
                    child: Column(
                      children: [
                        Row(children: [_rolButonu("Oyuncu", !isletmeModu), _rolButonu("İşletme", isletmeModu)]),
                        const SizedBox(height: 20),
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

  // --- GÜNCELLENMİŞ GİRİŞ FORMU ---
  Widget _girisFormu() {
    return Column(
      children: [
        TextField(
          controller: _girisController, 
          keyboardType: TextInputType.emailAddress, // Hem @ hem rakam için en uygun klavye
          decoration: const InputDecoration(
            hintText: "E-Posta veya Telefon", // Kullanıcıya ipucu
            prefixIcon: Icon(Icons.person_outline) // Daha genel bir ikon
          )
        ),
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
        TextField(
          controller: _kayitTelefonController, 
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: "Telefon (05xxxxxxxxx)", prefixIcon: Icon(Icons.phone_iphone))
        ),
        const SizedBox(height: 10),
        TextField(controller: _kayitSifreController, obscureText: _kayitSifreGizli, decoration: InputDecoration(hintText: "Şifre", prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(_kayitSifreGizli ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _kayitSifreGizli = !_kayitSifreGizli)))),
        const Spacer(),
        _yukleniyor ? const CircularProgressIndicator() : ElevatedButton(onPressed: _kayitOl, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E), minimumSize: const Size(double.infinity, 50)), child: const Text("KAYIT OL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ],
    );
  }
}