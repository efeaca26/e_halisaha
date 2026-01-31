import 'package:flutter/material.dart';
import '../../modeller/oyuncu_modeli.dart';

class OyuncuSecimEkrani extends StatefulWidget {
  // Daha önce seçilenler varsa onları işaretli getirmek için alıyoruz
  final List<OyuncuModeli> suankiSecimler; 

  const OyuncuSecimEkrani({super.key, required this.suankiSecimler});

  @override
  State<OyuncuSecimEkrani> createState() => _OyuncuSecimEkraniState();
}

class _OyuncuSecimEkraniState extends State<OyuncuSecimEkrani> {
  // SAHTE OYUNCU VERİTABANI (Topluluk Listesi)
  final List<OyuncuModeli> _tumOyuncular = [
    OyuncuModeli(isim: "Muslera Ahmet", mevkii: "Kaleci", ucret: 200, puan: 4.8, resimUrl: "https://i.pravatar.cc/150?u=1"),
    OyuncuModeli(isim: "Hızlı Kemal", mevkii: "Forvet", ucret: 150, puan: 4.5, resimUrl: "https://i.pravatar.cc/150?u=2"),
    OyuncuModeli(isim: "Kemik Kıran Ali", mevkii: "Defans", ucret: 100, puan: 3.9, resimUrl: "https://i.pravatar.cc/150?u=3"),
    OyuncuModeli(isim: "Pasör Mehmet", mevkii: "Orta Saha", ucret: 120, puan: 4.2, resimUrl: "https://i.pravatar.cc/150?u=4"),
    OyuncuModeli(isim: "Panter Sinan", mevkii: "Kaleci", ucret: 250, puan: 5.0, resimUrl: "https://i.pravatar.cc/150?u=5"),
    OyuncuModeli(isim: "Genç Semih", mevkii: "Forvet", ucret: 80, puan: 3.5, resimUrl: "https://i.pravatar.cc/150?u=6"),
    OyuncuModeli(isim: "Emineke", mevkii: "Forvet", ucret: 280, puan: 3.5, resimUrl: "https://i.pravatar.cc/150?u=6"),
  ];

// class _OyuncuSecimEkraniState extends State<OyuncuSecimEkrani> {
//   // SAHTE OYUNCU VERİTABANI (Topluluk Listesi)
//   final List<OyuncuModeli> _tumOyuncular = [
//     OyuncuModeli(isim: "Muslera Ünal", mevkii: "Kaleci", ucret: 200, puan: 4.8, resimUrl: "https://i.pravatar.cc/150?u=1"),
//     OyuncuModeli(isim: "Yavaş Mustafa", mevkii: "Forvet", ucret: 150, puan: 4.5, resimUrl: "https://i.pravatar.cc/150?u=2"),
//     OyuncuModeli(isim: "Big Cihan", mevkii: "Defans", ucret: 100, puan: 3.9, resimUrl: "https://i.pravatar.cc/150?u=3"),
//     OyuncuModeli(isim: "Pasör Acar", mevkii: "Orta Saha", ucret: 120, puan: 4.2, resimUrl: "https://i.pravatar.cc/150?u=4"),
//     OyuncuModeli(isim: "Panter Seyfi The Bektaş", mevkii: "Kaleci", ucret: 300, puan: 5.0, resimUrl: "https://i.pravatar.cc/150?u=5"),
//     OyuncuModeli(isim: "Vagnerlove", mevkii: "Forvet", ucret: 80, puan: 3.5, resimUrl: "https://i.pravatar.cc/150?u=6"),
//     OyuncuModeli(isim: "Emineke", mevkii: "Forvet", ucret: 280, puan: 3.5, resimUrl: "https://i.pravatar.cc/150?u=6"),

//   ];

  // Seçilenleri burada tutacağız
  List<OyuncuModeli> _secilenler = [];

  @override
  void initState() {
    super.initState();
    // Sayfa açılınca, önceden seçili gelenleri listemize ekleyelim
    _secilenler = List.from(widget.suankiSecimler);
  }

  void _secimDegistir(OyuncuModeli oyuncu, bool? secildiMi) {
    setState(() {
      if (secildiMi == true) {
        _secilenler.add(oyuncu);
      } else {
        _secilenler.removeWhere((item) => item.isim == oyuncu.isim);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Topluluk Oyuncuları", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tumOyuncular.length,
              itemBuilder: (context, index) {
                final oyuncu = _tumOyuncular[index];
                // Bu oyuncu listede var mı?
                final secili = _secilenler.any((item) => item.isim == oyuncu.isim);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: secili ? const Color(0xFFF0FDF4) : Colors.white,
                    border: Border.all(color: secili ? const Color(0xFF22C55E) : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(oyuncu.resimUrl),
                      backgroundColor: Colors.grey[200],
                    ),
                    title: Text(oyuncu.isim, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${oyuncu.mevkii} • ⭐ ${oyuncu.puan}", style: const TextStyle(color: Colors.grey)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("${oyuncu.ucret.toStringAsFixed(0)}₺", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                        Checkbox(
                          activeColor: const Color(0xFF22C55E),
                          value: secili,
                          onChanged: (val) => _secimDegistir(oyuncu, val),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // ALT BUTON
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  // Seçilenleri geri gönder
                  Navigator.pop(context, _secilenler);
                },
                child: Text("Kadroyu Onayla (${_secilenler.length} Oyuncu)", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
    );
  }
}