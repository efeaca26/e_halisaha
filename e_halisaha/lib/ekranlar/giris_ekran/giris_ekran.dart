import 'package:flutter/material.dart';
import '../anasayfa/anasayfa_ekrani.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isletmeModu = false; // Oyuncu mu İşletme mi? (Word dosyasındaki ayrım)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              // --- ÜST KISIM: LOGO VE KARŞILAMA ---
              Expanded(
                flex: 4,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.black, // Premium siyah tema
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.sports_soccer, size: 80, color: Colors.greenAccent),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "E-HALI SAHA",
                        style: TextStyle(
                          fontSize: 32, 
                          fontWeight: FontWeight.w900, 
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isletmeModu ? "İşletme Paneli Girişi" : "Maç Yapmaya Hazır mısın?",
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              // --- ALT KISIM: FORM VE SEÇİMLER ---
              Expanded(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: Column(
                    children: [
                      // OYUNCU / İŞLETME GEÇİŞ BUTONU
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey[300]!)
                        ),
                        child: Row(
                          children: [
                            _modSecici("Oyuncu", !isletmeModu, () => setState(() => isletmeModu = false)),
                            _modSecici("Saha Sahibi", isletmeModu, () => setState(() => isletmeModu = true)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // GİRİŞ / KAYIT TABLARI
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.green,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        tabs: const [
                          Tab(text: "Giriş Yap"),
                          Tab(text: "Kayıt Ol"),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // FORM İÇERİKLERİ
                      Expanded(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tasarım bileşeni: Oyuncu/İşletme Seçici Buton
  Widget _modSecici(String yazi, bool aktif, VoidCallback tikla) {
    return Expanded(
      child: GestureDetector(
        onTap: tikla,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: aktif ? Colors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: aktif ? [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
          ),
          child: Text(
            yazi,
            style: TextStyle(
              color: aktif ? Colors.white : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Giriş Formu
  Widget _girisFormu() {
    return Column(
      children: [
        _ozelInput(icon: Icons.email_outlined, hint: "E-Posta Adresi"),
        const SizedBox(height: 15),
        _ozelInput(icon: Icons.lock_outline, hint: "Şifre", gizli: true),
        const Spacer(),
        _anaButon("GİRİŞ YAP", () {
          // Giriş başarılıysa Ana Sayfaya git
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AnasayfaEkrani()));
        }),
      ],
    );
  }

  // Kayıt Formu (İşletme ise ekstra alanlar çıkar)
  Widget _kayitFormu() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _ozelInput(icon: Icons.person_outline, hint: isletmeModu ? "İşletme Adı" : "Ad Soyad"),
          const SizedBox(height: 15),
          _ozelInput(icon: Icons.phone_android_outlined, hint: "Telefon Numarası"),
          const SizedBox(height: 15),
          _ozelInput(icon: Icons.email_outlined, hint: "E-Posta Adresi"),
          const SizedBox(height: 15),
          _ozelInput(icon: Icons.lock_outline, hint: "Şifre", gizli: true),
          
          // Eğer "Saha Sahibi" seçiliyse İlçe soralım
          if (isletmeModu) ...[
             const SizedBox(height: 15),
             _ozelInput(icon: Icons.location_on_outlined, hint: "İl / İlçe"),
          ],
          
          const SizedBox(height: 30),
          _anaButon("KAYIT OL", () {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AnasayfaEkrani()));
          }),
        ],
      ),
    );
  }

  // Tasarım bileşeni: Özel Text Kutusu
  Widget _ozelInput({required IconData icon, required String hint, bool gizli = false}) {
    return TextField(
      obscureText: gizli,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
    );
  }

  // Tasarım bileşeni: Siyah Ana Buton
  Widget _anaButon(String yazi, VoidCallback tikla) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
        ),
        onPressed: tikla,
        child: Text(yazi, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}