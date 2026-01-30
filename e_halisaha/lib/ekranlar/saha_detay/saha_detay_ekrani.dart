import 'package:flutter/material.dart';
import '../../modeller/saha_modeli.dart';
import '../../cekirdek/servisler/sahte_veri_servisi.dart';
import '../odeme/odeme_ekrani.dart';

class SahaDetayEkrani extends StatefulWidget {
  final SahaModeli saha;
  const SahaDetayEkrani({super.key, required this.saha});

  @override
  State<SahaDetayEkrani> createState() => _SahaDetayEkraniState();
}

class _SahaDetayEkraniState extends State<SahaDetayEkrani> {
  // [cite: 101] Saat kutucukları (17:00 - 24:00 arası)
  final List<String> saatler = [
    '17:00', '18:00', '19:00', '20:00', 
    '21:00', '22:00', '23:00', '24:00'
  ];

  List<String> doluSaatler = [];
  String? secilenSaat; // [cite: 104] Sarı durum

  @override
  void initState() {
    super.initState();
    // Sahte sunucudan dolu saatleri çek
    doluSaatler = SahteVeriServisi.doluSaatleriGetir(widget.saha.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.saha.isim)),
      body: Column(
        children: [
          // Özellik İkonları [cite: 99]
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: widget.saha.ozellikler.map((ozellik) {
                return Column(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    Text(ozellik, style: const TextStyle(fontSize: 10)),
                  ],
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 20),
          const Text("📅 Tarih: Bugün (30 Ocak)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // [cite: 8] Grid Yapısı (Otobüs koltuğu seçer gibi)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Yan yana 3 kutu
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: saatler.length,
              itemBuilder: (context, index) {
                String saat = saatler[index];
                bool isDolu = doluSaatler.contains(saat);
                bool isSecili = secilenSaat == saat;

                return GestureDetector(
                  onTap: () {
                    if (isDolu) {
                      ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text("Bu saat maalesef dolu!")),
                      );
                      return;
                    }
                    setState(() {
                      //  Tek seçim hakkı
                      secilenSaat = saat; 
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      // [cite: 102, 103, 104] Renk Mantığı
                      color: isDolu ? Colors.red[300] : (isSecili ? Colors.orange : Colors.green[400]),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      saat,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),

          // Renk Açıklamaları
          const Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, color: Colors.green, size: 14), Text(" Boş "),
                Icon(Icons.circle, color: Colors.red, size: 14), Text(" Dolu "),
                Icon(Icons.circle, color: Colors.orange, size: 14), Text(" Seçili"),
              ],
            ),
          ),

          // Alt Bar - Devam Et Butonu
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Kapora: ${widget.saha.kapora} TL", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const Text("Toplam: Kalan sahada ödenir"),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  onPressed: secilenSaat == null ? null : () {
                    // [cite: 21] Kilit mantığını başlatmak için ödemeye git
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => OdemeEkrani(saha: widget.saha, saat: secilenSaat!))
                    );
                  },
                  child: const Text("DEVAM ET >", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}