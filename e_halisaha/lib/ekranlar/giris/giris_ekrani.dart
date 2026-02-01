import 'package:flutter/material.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart'; // Servisimizi çağırdık
import '../anasayfa/anasayfa_ekrani.dart';


class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isletmeModu = false;
  bool _yukleniyor = false; // Dönen yuvarlak (Loading) için

  // --- YAZI KUTUSU KONTROLCÜLERİ ---
  // Yazılanları okumak için bunları tanımlamamız şart
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  
  final TextEditingController _kayitIsimController = TextEditingController();
  final TextEditingController _kayitEmailController = TextEditingController();
  final TextEditingController _kayitSifreController = TextEditingController();
  final TextEditingController _kayitKonumController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // --- GİRİŞ İŞLEMİ ---
  void _girisYap() async {
    String email = _emailController.text.trim(); // Boşlukları temizle
    String sifre = _sifreController.text.trim();

    if (email.isEmpty || sifre.isEmpty) {
      _hataGoster("Lütfen tüm alanları doldurun.");
      return;
    }

    setState(() => _yukleniyor = true); // Yükleniyor başlat

    bool basarili = await KimlikServisi.girisYap(email, sifre);

    setState(() => _yukleniyor = false); // Yükleniyor durdur

    if (basarili) {
      // Başarılıysa Ana Sayfaya git
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AnasayfaEkrani()));
      }
    } else {
      _hataGoster("E-posta veya şifre hatalı!");
    }
  }

  // --- KAYIT İŞLEMİ ---
  void _kayitOl() async {
    String isim = _kayitIsimController.text.trim();
    String email = _kayitEmailController.text.trim();
    String sifre = _kayitSifreController.text.trim();

    if (isim.isEmpty || email.isEmpty || sifre.isEmpty) {
      _hataGoster("Lütfen zorunlu alanları doldurun.");
      return;
    }

    setState(() => _yukleniyor = true);

    bool basarili = await KimlikServisi.kayitOl(isim, email, sifre, isletmeModu);

    setState(() => _yukleniyor = false);

    if (basarili) {
      // Kayıt başarılı, şimdi otomatik giriş yapsın mı yoksa giriş sekmesine mi atsın?
      // Biz direkt ana sayfaya alalım kullanıcıyı yormayalım.
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AnasayfaEkrani()));
      }
    } else {
      _hataGoster("Bu e-posta adresi zaten kayıtlı.");
    }
  }

  void _hataGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mesaj), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
      print("Giriş Ekranı Çiziliyor..."); // <--- Bunu ekle ve konsolu izle
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0FDF4), Color(0xFFEFF6FF)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 20)],
                  ),
                  child: const Icon(Icons.sports_soccer, size: 64, color: Color(0xFF22C55E)),
                ),
                const SizedBox(height: 24),
                const Text("eHalısaha", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                const SizedBox(height: 8),
                Text(isletmeModu ? "İşletme Yönetim Paneli" : "Saha Bul, Kirala, Oyna!", style: const TextStyle(color: Color(0xFF6B7280), fontSize: 16)),
                const SizedBox(height: 40),

                // Kart
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      // Oyuncu / İşletme Switch
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            _modSecici("Oyuncu", !isletmeModu, () => setState(() => isletmeModu = false)),
                            _modSecici("İşletme", isletmeModu, () => setState(() => isletmeModu = true)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tab Bar
                      TabBar(
                        controller: _tabController,
                        labelColor: const Color(0xFF22C55E),
                        unselectedLabelColor: const Color(0xFF6B7280),
                        indicatorColor: const Color(0xFF22C55E),
                        dividerColor: Colors.transparent,
                        tabs: const [Tab(text: "Giriş Yap"), Tab(text: "Kayıt Ol")],
                      ),
                      const SizedBox(height: 24),

                      // Form Alanı
                      SizedBox(
                        height: 320,
                        child: TabBarView(
                          controller: _tabController,
                          children: [_girisFormu(), _kayitFormu()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modSecici(String yazi, bool aktif, VoidCallback tikla) {
    return Expanded(
      child: GestureDetector(
        onTap: tikla,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: aktif ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: aktif ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
          ),
          child: Text(yazi, style: TextStyle(color: aktif ? const Color(0xFF111827) : const Color(0xFF6B7280), fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _girisFormu() {
    return Column(
      children: [
        TextField(controller: _emailController, decoration: const InputDecoration(hintText: "E-Posta Adresi", prefixIcon: Icon(Icons.mail_outline))),
        const SizedBox(height: 16),
        TextField(controller: _sifreController, obscureText: true, decoration: const InputDecoration(hintText: "Şifre", prefixIcon: Icon(Icons.lock_outline))),
        const Spacer(),
        _yukleniyor 
          ? const CircularProgressIndicator(color: Color(0xFF22C55E))
          : _anaButon("GİRİŞ YAP", _girisYap),
      ],
    );
  }

  Widget _kayitFormu() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(controller: _kayitIsimController, decoration: InputDecoration(hintText: isletmeModu ? "İşletme Adı" : "Ad Soyad", prefixIcon: const Icon(Icons.person_outline))),
          const SizedBox(height: 16),
          TextField(controller: _kayitEmailController, decoration: const InputDecoration(hintText: "E-Posta", prefixIcon: Icon(Icons.mail_outline))),
          const SizedBox(height: 16),
          TextField(controller: _kayitSifreController, obscureText: true, decoration: const InputDecoration(hintText: "Şifre", prefixIcon: Icon(Icons.lock_outline))),
          if (isletmeModu) ...[
            const SizedBox(height: 16),
            TextField(controller: _kayitKonumController, decoration: const InputDecoration(hintText: "Konum (İl/İlçe)", prefixIcon: Icon(Icons.location_on_outlined))),
          ],
          const SizedBox(height: 24),
          _yukleniyor 
            ? const CircularProgressIndicator(color: Color(0xFF22C55E))
            : _anaButon("KAYIT OL", _kayitOl),
        ],
      ),
    );
  }

  Widget _anaButon(String yazi, VoidCallback tikla) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF22C55E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: tikla,
        child: Text(yazi, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}