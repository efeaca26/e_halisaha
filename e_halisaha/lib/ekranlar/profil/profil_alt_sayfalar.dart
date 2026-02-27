import 'package:flutter/material.dart';
import '../../cekirdek/servisler/api_servisi.dart';
import 'package:intl/intl.dart';

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
    _verileriYukle();
  }

  Future<void> _verileriYukle() async {
    try {
      final veriler = await _apiServisi.rezervasyonlarimiGetir();
      if (mounted) {
        setState(() {
          _randevular = veriler;
          _yukleniyor = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Rezervasyonlarım", style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF16A34A)))
          : _randevular.isEmpty
              ? _bosEkranGoster()
              : RefreshIndicator(
                  onRefresh: _verileriYukle,
                  color: const Color(0xFF16A34A),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _randevular.length,
                    itemBuilder: (context, index) {
                      try {
                        return _randevuKarti(_randevular[index]);
                      } catch (e) {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
    );
  }

  Widget _randevuKarti(dynamic randevu) {
    // 1. Verileri Güvenli Bir Şekilde Çekme
    final String pitchName = (randevu['pitch_name'] ?? "Bilinmeyen Saha").toString();
    final String facilityName = (randevu['facility_name'] ?? "Tesis Bilgisi Yok").toString();
    final String status = (randevu['status'] ?? "pending").toString().toLowerCase();
    
    // Fiyat
    double priceValue = 0.0;
    if (randevu['total_price'] != null) {
      priceValue = double.tryParse(randevu['total_price'].toString()) ?? 0.0;
    }

    // 2. Tarih ve Saat Formatlama (Hatasız)
    String formatliTarih = "Bilinmeyen Tarih";
    String saatString = "--:--";
    
    try {
      if (randevu['start_time'] != null) {
        String timeStr = randevu['start_time'].toString();
        // Backend'den "2026-02-28T06:00:00.000Z" geliyor, bunu cihaza göre (toLocal) çeviriyoruz
        DateTime tarih = DateTime.parse(timeStr).toLocal();
        formatliTarih = DateFormat('dd MMMM yyyy', 'tr_TR').format(tarih);
        saatString = DateFormat('HH:mm').format(tarih);
      }
    } catch (e) {
      debugPrint("Tarih formatlanamadı: $e");
    }

    // 3. Durum Renklerini Belirleme
    Color durumKutuRengi = const Color(0xFFFEF3C7); // Sarımsı arka plan (beklemede)
    Color durumYaziRengi = const Color(0xFF92400E); // Koyu sarı yazı (beklemede)
    String durumMetni = "Beklemede";

    if (status == 'confirmed' || status == 'onaylandı') {
      durumKutuRengi = const Color(0xFFDBEAFE); // Mavimsi arka plan
      durumYaziRengi = const Color(0xFF1E40AF); // Koyu mavi yazı
      durumMetni = "Onaylandı";
    } else if (status == 'cancelled' || status == 'iptal') {
      durumKutuRengi = const Color(0xFFFEE2E2); // Kırmızımsı arka plan
      durumYaziRengi = const Color(0xFF991B1B); // Koyu kırmızı yazı
      durumMetni = "İptal Edildi";
    }

    // 4. Kart Tasarımı
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Üstten hizala
        children: [
          // Sol İkon Kutusu
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.sports_soccer, color: Color(0xFF16A34A), size: 28),
          ),
          const SizedBox(width: 16),
          
          // Orta Bilgiler (Saha Adı, Tesis Adı, Tarih)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pitchName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827))),
                const SizedBox(height: 2),
                Text(facilityName, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 14, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 4),
                    Text("$formatliTarih | $saatString", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
                  ],
                ),
              ],
            ),
          ),
          
          // Sağ Kısım (Fiyat ve Durum)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${priceValue.toInt()} ₺", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF16A34A))),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: durumKutuRengi,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  durumMetni,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: durumYaziRengi),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bosEkranGoster() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sports_soccer_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("Henüz bir maçın yok!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
          const SizedBox(height: 8),
          const Text("Hemen bir saha bul ve maçını ayarla!", style: TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Saha Ara", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class AyarlarSayfasi extends StatelessWidget {
  const AyarlarSayfasi({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Ayarlar")));
}

class ProfilDuzenleSayfasi extends StatelessWidget {
  const ProfilDuzenleSayfasi({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Profili Düzenle")));
}