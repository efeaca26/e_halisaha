import 'package:flutter/material.dart';
import '../../cekirdek/servisler/api_servisi.dart';
import '../../modeller/saha_modeli.dart';
import '../../cekirdek/servisler/kimlik_servisi.dart';
import '../saha_detay/saha_detay_ekrani.dart';

class AnasayfaEkrani extends StatefulWidget {
  const AnasayfaEkrani({super.key});

  @override
  State<AnasayfaEkrani> createState() => _AnasayfaEkraniState();
}

class _AnasayfaEkraniState extends State<AnasayfaEkrani> {
  final ApiServisi _apiServisi = ApiServisi();
  List<SahaModeli> _sahalar = [];
  bool _yukleniyor = true;
  String? _kullaniciAdi;

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  Future<void> _verileriYukle() async {
    // KimlikServisi metodunu artık bulabilecek
    final user = await KimlikServisi.kullaniciGetir();
    final veriler = await _apiServisi.tumSahalariGetir();
    
    if (mounted) {
      setState(() {
        _kullaniciAdi = user?['name']?.split(' ')[0] ?? "Futbolsever";
        _sahalar = veriler.map((v) => SahaModeli.fromMap(v)).toList();
        _yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Web bg-gray-50
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _verileriYukle,
          color: const Color(0xFF16A34A),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Merhaba, $_kullaniciAdi 👋", style: const TextStyle(fontSize: 16, color: Color(0xFF4B5563))),
                              const Text("Hangi sahada maç var?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                            ],
                          ),
                          const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person_outline, color: Color(0xFF16A34A))),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03), // HATA DÜZELTİLDİ
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: "Saha adı veya konum ara...",
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _yukleniyor
                  ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFF16A34A))))
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _sahaKartiniOlustur(_sahalar[index]),
                          childCount: _sahalar.length,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sahaKartiniOlustur(SahaModeli saha) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SahaDetayEkrani(saha: saha))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), // HATA DÜZELTİLDİ
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(height: 180, color: const Color(0xFFF3F4F6), child: const Center(child: Icon(Icons.sports_soccer, size: 48, color: Color(0xFFD1D5DB)))),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(saha.isim, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("${saha.fiyat.toInt()} ₺", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                    ],
                  ),
                  Text(saha.ilce, style: const TextStyle(color: Color(0xFF6B7280))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}