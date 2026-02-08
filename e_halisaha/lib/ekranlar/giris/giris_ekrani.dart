import 'package:flutter/material.dart';
// Dosya yollarını kendi projene göre kontrol et
import '../../cekirdek/servisler/api_servisi.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';
import '../anasayfa/anasayfa_ekrani.dart';
import '../admin/admin_ana_sayfa.dart'; 

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> with TickerProviderStateMixin {
  final ApiServisi _apiServisi = ApiServisi();
  final _sahaAdiController = TextEditingController();
  final _konumController = TextEditingController();

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

  final _girisController = TextEditingController(); 
  final _sifreController = TextEditingController();
  
  final _kayitIsimController = TextEditingController();
  final _kayitEmailController = TextEditingController();
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


  // // GİRİŞ

//   void _girisYap() async {

//     if (_girisController.text.isEmpty || _sifreController.text.isEmpty) {

//       _mesajGoster("Lütfen alanları doldurun", kirmizi: true);

//       return;

//     }



//     setState(() => _yukleniyor = true);



//     // 1. API İsteği

//     print("--- GİRİŞ İSTEĞİ BAŞLIYOR ---");

//     bool basarili = await _apiServisi.girisYap(

//       _girisController.text.trim(),

//       _sifreController.text.trim()

//     );



//     setState(() => _yukleniyor = false);



//     if (basarili) {

//       // 2. Kimlik Servisine Ne Kaydedildi?

//       var aktifKullanici = KimlikServisi.aktifKullanici;

      

//       print("--- KİMLİK SERVİSİ RAPORU ---");

//       print("Kayıtlı İsim: ${aktifKullanici?['isim']}");

//       print("Kayıtlı Rol (Raw): ${aktifKullanici?['role']}"); // Burası null mı geliyor?

//       print("Admin mi?: ${KimlikServisi.isAdmin}");

//       print("------------------------------");



//       if (mounted) {

//         // ROL KONTROLÜ

//         // Not: Veritabanında 'admin' küçük harf, burada da küçük harf kontrol ediyoruz.

//         String rol = aktifKullanici?['role']?.toString().toLowerCase() ?? 'oyuncu';



//         if (rol == 'admin') {

//           print(">>> YÖNETİCİ SAYFASINA GİDİLİYOR >>>");

//           Navigator.pushReplacement(

//             context, 

//             MaterialPageRoute(builder: (context) => AdminAnaSayfa())

//           );

//         } else {

//           print(">>> OYUNCU SAYFASINA GİDİLİYOR (Rol: $rol) >>>");

//           Navigator.pushReplacement(

//             context, 

//             MaterialPageRoute(builder: (context) => const AnasayfaEkrani())

//           );

//         }

//       }

//     } else {

//       _mesajGoster("Giriş Başarısız!", kirmizi: true);

//     }

//   }

  // --- GİRİŞ YAP (DEBUG VE FİXLENMİŞ VERSİYON) ---
  void _girisYap() async {
    if (_girisController.text.isEmpty || _sifreController.text.isEmpty) {
      _mesajGoster("Lütfen alanları doldurun", kirmizi: true);
      return;
    }

    setState(() => _yukleniyor = true);

    print("--------------------------------------------------");
    print("🚀 GİRİŞ İŞLEMİ BAŞLATILIYOR...");
    print("📧 Email: ${_girisController.text.trim()}");
    print("🔑 Şifre: ${_sifreController.text.trim()}");

    try {
      // 1. API İsteği
      bool basarili = await _apiServisi.girisYap(
        _girisController.text.trim(),
        _sifreController.text.trim()
      );

      setState(() => _yukleniyor = false);

      if (basarili) {
        print("✅ API 'Başarılı' döndü.");
        
        // Değişkeni burada tanımlıyoruz
        var aktifKullanici = KimlikServisi.aktifKullanici;

        // 2. Kimlik Servisine Ne Kaydedildi?
        print("Admin Yetkisi Var Mı?: ${KimlikServisi.isAdmin}");
        
        print("🔍 KİMLİK SERVİSİ İNCELENİYOR:");
        if (aktifKullanici != null) {
          print("👤 İsim: ${aktifKullanici['isim']}");
          print("🆔 ID: ${aktifKullanici['id']}");
          // Hem 'role' hem 'rol' kontrolü (Debug için)
          print("🎭 ROL (role): '${aktifKullanici['role']}'"); 
          print("🎭 ROL (rol): '${aktifKullanici['rol']}'"); 
        } else {
          print("❌ HATA: Aktif Kullanıcı NULL!");
        }

        if (mounted) {
          // --- KESİN YÖNLENDİRME ---
          // String karmaşasına girmeden doğrudan getter kullanıyoruz
          if (KimlikServisi.isAdmin) {
            print("🛑 KARAR: YÖNETİCİ PANELİNE GİDİLİYOR...");
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (context) => AdminAnaSayfa())
            );
          } else {
            print("🏃 KARAR: OYUNCU SAYFASINA GİDİLİYOR...");
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (context) => const AnasayfaEkrani())
            );
          }
        }
      } else {
        print("❌ API 'Başarısız' döndü.");
        _mesajGoster("Giriş Başarısız! E-posta veya şifre hatalı.", kirmizi: true);
      }
    } catch (e) {
       print("💥 BÜYÜK HATA: $e");
       setState(() => _yukleniyor = false);
    }
    print("--------------------------------------------------");
  }

  // --- KAYIT OL ---
  void _kayitOl() async {
    // Validasyonlar
    if (_kayitIsimController.text.isEmpty || _kayitTelefonController.text.isEmpty || _kayitSifreController.text.isEmpty) {
      _mesajGoster("Eksik bilgi girdiniz", kirmizi: true);
      return;
    }

    // İşletme ise ek kontroller
    if (isletmeModu) {
      if (_sahaAdiController.text.isEmpty || _konumController.text.isEmpty) {
        _mesajGoster("Lütfen Saha Adı ve Konum giriniz", kirmizi: true);
        return;
      }
    }

    setState(() => _yukleniyor = true);

    bool basarili = await _apiServisi.kayitOl(
      _kayitIsimController.text.trim(),
      _kayitTelefonController.text.trim(), 
      _kayitSifreController.text.trim(),
      isletmeModu,
      sahaAdi: isletmeModu ? _sahaAdiController.text.trim() : null,
      konum: isletmeModu ? _konumController.text.trim() : null,
    );

    setState(() => _yukleniyor = false);

    if (basarili) {
      if (isletmeModu) {
        _mesajGoster("Kayıt alındı! Admin onayından sonra giriş yapabileceksiniz.");
      } else {
        _mesajGoster("Kayıt Başarılı! Giriş yapabilirsiniz.");
      }
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
                          height: 400,
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

  // --- GİRİŞ FORMU ---
  Widget _girisFormu() {
    return Column(
      children: [
        TextField(
          controller: _girisController, 
          keyboardType: TextInputType.emailAddress, 
          decoration: const InputDecoration(
            labelText: "E-Posta", 
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(), 
          )
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _sifreController, 
          obscureText: _girisSifreGizli, 
          decoration: InputDecoration(
            labelText: "Şifre", 
            prefixIcon: const Icon(Icons.lock_outline), 
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(_girisSifreGizli ? Icons.visibility_off : Icons.visibility), 
              onPressed: () => setState(() => _girisSifreGizli = !_girisSifreGizli)
            )
          )
        ),
        const Spacer(),
        _yukleniyor 
          ? const CircularProgressIndicator() 
          : ElevatedButton(
              onPressed: _girisYap, 
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E), minimumSize: const Size(double.infinity, 50)), 
              child: const Text("GİRİŞ YAP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
            ),
      ],
    );
  }

  // --- KAYIT FORMU ---
  Widget _kayitFormu() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(controller: _kayitIsimController, decoration: const InputDecoration(labelText: "Ad Soyad", prefixIcon: Icon(Icons.person), border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: _kayitTelefonController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: "Telefon", prefixIcon: Icon(Icons.phone), border: OutlineInputBorder())),
          const SizedBox(height: 10),
          TextField(controller: _kayitSifreController, obscureText: _kayitSifreGizli, decoration: const InputDecoration(labelText: "Şifre", prefixIcon: Icon(Icons.lock), border: OutlineInputBorder())),
          
          // --- İŞLETME İSE EKSTRA ALANLAR GÖZÜKSÜN ---
          if (isletmeModu) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green)),
              child: Column(
                children: [
                  const Text("Saha Bilgileri", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 10),
                  TextField(controller: _sahaAdiController, decoration: const InputDecoration(labelText: "Saha Adı", prefixIcon: Icon(Icons.stadium), border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(controller: _konumController, decoration: const InputDecoration(labelText: "Konum (İl/İlçe)", prefixIcon: Icon(Icons.map), border: OutlineInputBorder())),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 20),
          _yukleniyor ? const CircularProgressIndicator() : ElevatedButton(onPressed: _kayitOl, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E), minimumSize: const Size(double.infinity, 50)), child: const Text("KAYIT OL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}