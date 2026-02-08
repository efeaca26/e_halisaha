import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http; // HTTP paketi eklendi
import 'dart:convert'; // JSON çevirici eklendi

import 'ekranlar/giris/giris_ekrani.dart';

ValueNotifier<ThemeMode> temaYoneticisi = ValueNotifier(ThemeMode.light);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EHalisahaUygulamasi());
}

class EHalisahaUygulamasi extends StatelessWidget {
  const EHalisahaUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaYoneticisi,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'E-HalıSaha',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF22C55E),
            scaffoldBackgroundColor: const Color(0xFFF0FDF4),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF22C55E),
            scaffoldBackgroundColor: const Color(0xFF111827), // Koyu gri
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1F2937),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('tr', 'TR'),
          ],
          // BURASI DEĞİŞTİ: Test bitince tekrar GirisEkrani() yapabilirsin.
          // home: const GirisEkrani(),
          home: const ApiTestEkrani(), 
        );
      },
    );
  }
}

// --- GEÇİCİ API TEST EKRANI ---
// Backend bağlantısını test etmek için buraya ekledik.
class ApiTestEkrani extends StatefulWidget {
  const ApiTestEkrani({super.key});

  @override
  State<ApiTestEkrani> createState() => _ApiTestEkraniState();
}

class _ApiTestEkraniState extends State<ApiTestEkrani> {
  List<dynamic> sahalar = [];
  String durumMesaji = "Veriler yükleniyor...";
  bool hataVarMi = false;

  // Emülatör için özel adres: 10.0.2.2
  // Port numaran: 5216
  final String apiUrl = "http://10.0.2.2:5216/api/Pitches";

  @override
  void initState() {
    super.initState();
    verileriCek();
  }

  Future<void> verileriCek() async {
    try {
      print("İstek gönderiliyor: $apiUrl"); // Konsolda görmek için
      final response = await http.get(Uri.parse(apiUrl));

      print("Durum Kodu: ${response.statusCode}");

      if (response.statusCode == 200) {
        setState(() {
          sahalar = json.decode(response.body);
          durumMesaji = "${sahalar.length} saha bulundu!";
          hataVarMi = false;
        });
      } else {
        setState(() {
          durumMesaji = "Hata Kodu: ${response.statusCode}";
          hataVarMi = true;
        });
      }
    } catch (e) {
      print("Hata oluştu: $e");
      setState(() {
        durumMesaji = "Bağlantı Hatası: \n$e";
        hataVarMi = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("API Bağlantı Testi")),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: hataVarMi ? Colors.red.shade100 : Colors.green.shade100,
            width: double.infinity,
            child: Text(
              durumMesaji,
              style: TextStyle(
                color: hataVarMi ? Colors.red.shade900 : Colors.green.shade900,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: sahalar.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: sahalar.length,
                    itemBuilder: (context, index) {
                      final saha = sahalar[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.stadium, color: Color(0xFF22C55E)),
                          title: Text(saha['pitchName'] ?? 'İsim Yok'),
                          subtitle: Text(saha['location'] ?? 'Konum Yok'),
                          trailing: Text(
                            "${saha['pricePerHour']} TL",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: verileriCek,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}