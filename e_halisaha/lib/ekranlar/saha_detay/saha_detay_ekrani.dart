import 'package:flutter/material.dart';
import '../../modeller/saha_modeli.dart';
import '../anasayfa/anasayfa_ekrani.dart'; // <--- Ana sayfayı çağırdık

class SahaDetayEkrani extends StatefulWidget {
  final SahaModeli saha;

  const SahaDetayEkrani({super.key, required this.saha});

  @override
  State<SahaDetayEkrani> createState() => _SahaDetayEkraniState();
}

class _SahaDetayEkraniState extends State<SahaDetayEkrani> {
  bool _yukleniyor = false; // Butonda dönen yükleniyor simgesi için

  void _rezervasyonYap() async {
    setState(() => _yukleniyor = true);

    // 1. İşlem yapılıyormuş gibi bekle (Simülasyon)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // 2. Başarılı Mesajı Göster
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Rezervasyonunuz başarıyla alındı! 🎉"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    setState(() => _yukleniyor = false);

    // 3. ANA SAYFAYA YÖNLENDİR (Eskiden Giriş Ekranıydı)
    // pushAndRemoveUntil: Geri tuşuna basınca tekrar bu sayfaya dönmesin diye geçmişi siler.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AnasayfaEkrani()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4), // green-50
      body: CustomScrollView(
        slivers: [
          // --- ÜST RESİM VE GERİ BUTONU ---
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFF22C55E),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                widget.saha.resimYolu,
                fit: BoxFit.cover,
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // --- DETAYLAR ---
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık ve Puan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.saha.isim,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Color(0xFF15803D), size: 18),
                              const SizedBox(width: 4),
                              Text(
                                "${widget.saha.puan}",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "📍 ${widget.saha.tamKonum}",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Özellikler (Grid)
                    const Text("Saha Özellikleri", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: widget.saha.ozellikler.map((ozellik) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!)
                          ),
                          child: Text(ozellik, style: const TextStyle(color: Colors.black54)),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Açıklama (Lorem Ipsum yerine sabit yazı)
                    const Text("Açıklama", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      "Bu saha profesyonel suni çim ile kaplanmış olup, gece maçları için özel LED aydınlatmaya sahiptir. Maç sonrası duş imkanı ve kafeterya hizmeti bulunmaktadır.",
                      style: TextStyle(color: Colors.grey, height: 1.5),
                    ),
                    
                    const SizedBox(height: 100), // Buton için boşluk
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // --- ALT REZERVASYON BUTONU ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Toplam Ücret", style: TextStyle(color: Colors.grey)),
                Text(
                  "${widget.saha.fiyat.toStringAsFixed(0)}₺",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF22C55E)),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _yukleniyor ? null : _rezervasyonYap,
                  child: _yukleniyor 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Rezervasyon Yap", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}