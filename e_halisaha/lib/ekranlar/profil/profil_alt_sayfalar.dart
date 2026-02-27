import 'package:flutter/material.dart';
import '../../cekirdek/servisler/api_servisi.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';

// ---------------------------------------------------
// 1. PROFİL DÜZENLEME SAYFASI
// ---------------------------------------------------
class ProfilDuzenleSayfasi extends StatefulWidget {
  const ProfilDuzenleSayfasi({super.key});

  @override
  State<ProfilDuzenleSayfasi> createState() => _ProfilDuzenleSayfasiState();
}

class _ProfilDuzenleSayfasiState extends State<ProfilDuzenleSayfasi> {
  final ApiServisi _apiServisi = ApiServisi();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _adController;
  late TextEditingController _emailController;
  bool _yukleniyor = false;

  @override
  void initState() {
    super.initState();
    _adController = TextEditingController();
    _emailController = TextEditingController();
    _bilgileriDoldur();
  }

  void _bilgileriDoldur() async {
    final user = await KimlikServisi.kullaniciGetir();
    if (mounted && user != null) {
      setState(() {
        _adController.text = user['fullName'] ?? user['full_name'] ?? user['name'] ?? "";
        _emailController.text = user['email'] ?? "";
      });
    }
  }

  Future<void> _kaydet() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _yukleniyor = true);
      
      final user = await KimlikServisi.kullaniciGetir();
      if (user != null) {
        int id = user['userId'] ?? user['id'] ?? 0;
        bool basarili = await _apiServisi.bilgileriGuncelle(
          id,
          _adController.text,
          _emailController.text,
          user['phoneNumber'] ?? user['phone'] ?? "",
          "" 
        );

        if (!mounted) return;
        setState(() => _yukleniyor = false);

        if (basarili) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Profil güncellendi!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Güncelleme başarısız."), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Profili Düzenle", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _ozelInput(_adController, "Ad Soyad", Icons.person_outline),
              const SizedBox(height: 20),
              _ozelInput(_emailController, "E-posta", Icons.email_outlined, klavyeTipi: TextInputType.emailAddress),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _yukleniyor ? null : _kaydet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _yukleniyor 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text("DEĞİŞİKLİKLERİ KAYDET", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ozelInput(TextEditingController controller, String etiket, IconData ikon, {TextInputType klavyeTipi = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: klavyeTipi,
      decoration: InputDecoration(
        labelText: etiket,
        prefixIcon: Icon(ikon, color: const Color(0xFF16A34A)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      ),
      validator: (val) => val!.isEmpty ? "Bu alan boş bırakılamaz" : null,
    );
  }
}

// ---------------------------------------------------
// 2. RANDEVULARIM (GEÇMİŞ REZERVASYONLAR) SAYFASI
// ---------------------------------------------------
class RandevularimSayfasi extends StatefulWidget {
  const RandevularimSayfasi({super.key});

  @override
  State<RandevularimSayfasi> createState() => _RandevularimSayfasiState();
}

class _RandevularimSayfasiState extends State<RandevularimSayfasi> {
  final ApiServisi _apiServisi = ApiServisi();
  List<dynamic> _randevular = [];
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _verileriGetir();
  }

  Future<void> _verileriGetir() async {
    setState(() => _yukleniyor = true);
    try {
      var veriler = await _apiServisi.randevularimiGetir();
      if (mounted) {
        setState(() {
          _randevular = veriler;
          _yukleniyor = false;
        });
      }
    } catch (e) {
      debugPrint("Randevu listeleme hatası: $e");
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Rezervasyonlarım", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF16A34A)))
          : RefreshIndicator(
              onRefresh: _verileriGetir,
              color: const Color(0xFF16A34A),
              child: _randevular.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                        const Icon(Icons.calendar_today_outlined, size: 80, color: Color(0xFFD1D5DB)),
                        const SizedBox(height: 16),
                        const Center(child: Text("Henüz bir randevunuz bulunmuyor.", style: TextStyle(color: Colors.grey, fontSize: 16))),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _randevular.length,
                      itemBuilder: (context, index) {
                        final randevu = _randevular[index];
                        
                        // --- DÜZELTİLEN YER: toLocal() EKLENDİ ---
                        String? rawDate = (randevu['startTime'] ?? randevu['start_time'])?.toString();
                        DateTime start = rawDate != null 
                            ? DateTime.parse(rawDate).toLocal() 
                            : DateTime.now();
                        
                        String formatliTarih = "${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}";
                        String formatliSaat = "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}";

                        // ZIRHLI SAHA İSMİ OKUMA
                        String sahaIsmi = (randevu['pitchName'] ?? randevu['pitch']?['name'] ?? "Bilinmeyen Saha").toString();
                        
                        // DURUM KONTROLÜ
                        String durum = (randevu['status'] ?? "Pending").toString().toLowerCase();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56, height: 56,
                                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(14)),
                                child: const Icon(Icons.sports_soccer, color: Color(0xFF16A34A), size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(sahaIsmi, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827))),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text("$formatliTarih - $formatliSaat", style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              _durumRozeti(durum),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _durumRozeti(String durum) {
    bool onayli = durum == 'confirmed';
    bool iptal = durum == 'cancelled';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: onayli ? Colors.green[50] : (iptal ? Colors.red[50] : Colors.orange[50]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        onayli ? "ONAYLANDI" : (iptal ? "İPTAL" : "BEKLEMEDE"),
        style: TextStyle(
          color: onayli ? Colors.green : (iptal ? Colors.red : Colors.orange),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ---------------------------------------------------
// 3. AYARLAR SAYFASI
// ---------------------------------------------------
class AyarlarSayfasi extends StatefulWidget {
  const AyarlarSayfasi({super.key});

  @override
  State<AyarlarSayfasi> createState() => _AyarlarSayfasiState();
}

class _AyarlarSayfasiState extends State<AyarlarSayfasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Ayarlar", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _ayarSatiri(Icons.notifications_none, "Bildirimler", true),
          _ayarSatiri(Icons.dark_mode_outlined, "Karanlık Mod", false),
          _ayarSatiri(Icons.language, "Dil Seçimi (Türkçe)", null),
          const Divider(height: 40),
          _ayarSatiri(Icons.help_outline, "Yardım Merkezi", null),
          _ayarSatiri(Icons.info_outline, "Uygulama Hakkında", null),
        ],
      ),
    );
  }

  Widget _ayarSatiri(IconData ikon, String baslik, bool? switchDegeri) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(ikon, color: const Color(0xFF4B5563)),
      title: Text(baslik, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: switchDegeri != null 
        ? Switch(value: switchDegeri, onChanged: (v){}, activeColor: const Color(0xFF16A34A))
        : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }
}