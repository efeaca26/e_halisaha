import 'package:flutter/material.dart';
import '../anasayfa/anasayfa_ekrani.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isletmeModu = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    // Dokümandaki Gradient Arka Plan
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0FDF4), // green-50
              Color(0xFFEFF6FF), // blue-50
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo Kısmı
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
                    ],
                  ),
                  child: const Icon(Icons.sports_soccer, size: 64, color: Color(0xFF22C55E)),
                ),
                const SizedBox(height: 24),
                const Text(
                  "eHalısaha",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937), // Gray-800
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isletmeModu ? "İşletme Yönetim Paneli" : "Saha Bul, Kirala, Oyna!",
                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 16), // Gray-500
                ),
                
                const SizedBox(height: 40),

                // Kart Yapısı (Dokümandaki shadow-md stili)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      // Oyuncu / İşletme Switch
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6), // Gray-100
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: "Giriş Yap"),
                          Tab(text: "Kayıt Ol"),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Form Alanı
                      SizedBox(
                        height: 300, // Form yüksekliği
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _girisFormu(),
                            _kayitFormu(),
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
          child: Text(
            yazi,
            style: TextStyle(
              color: aktif ? const Color(0xFF111827) : const Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _girisFormu() {
    return Column(
      children: [
        // Input stili main.dart'tan geliyor
        const TextField(decoration: InputDecoration(hintText: "E-Posta Adresi", prefixIcon: Icon(Icons.mail_outline))),
        const SizedBox(height: 16),
        const TextField(obscureText: true, decoration: InputDecoration(hintText: "Şifre", prefixIcon: Icon(Icons.lock_outline))),
        const Spacer(),
        _anaButon("GİRİŞ YAP", () {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AnasayfaEkrani()));
        }),
      ],
    );
  }

  Widget _kayitFormu() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(decoration: InputDecoration(hintText: isletmeModu ? "İşletme Adı" : "Ad Soyad", prefixIcon: const Icon(Icons.person_outline))),
          const SizedBox(height: 16),
          const TextField(decoration: InputDecoration(hintText: "E-Posta", prefixIcon: Icon(Icons.mail_outline))),
          const SizedBox(height: 16),
          const TextField(obscureText: true, decoration: InputDecoration(hintText: "Şifre", prefixIcon: Icon(Icons.lock_outline))),
          if (isletmeModu) ...[
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(hintText: "Konum (İl/İlçe)", prefixIcon: Icon(Icons.location_on_outlined))),
          ],
          const SizedBox(height: 24),
          _anaButon("KAYIT OL", () {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AnasayfaEkrani()));
          }),
        ],
      ),
    );
  }

  // Dokümandaki Primary Button stili
  Widget _anaButon(String yazi, VoidCallback tikla) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF22C55E), // bg-green-600
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