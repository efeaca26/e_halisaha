// import 'package:flutter/material.dart';
// import '../../cekirdek/servisler/api_servisi.dart';
// import '../../cekirdek/servisler/kimlik_servisi.dart';

// class ProfilDuzenleSayfasi extends StatefulWidget {
//   const ProfilDuzenleSayfasi({super.key});

//   @override
//   State<ProfilDuzenleSayfasi> createState() => _ProfilDuzenleSayfasiState();
// }

// class _ProfilDuzenleSayfasiState extends State<ProfilDuzenleSayfasi> {
//   final ApiServisi _apiServisi = ApiServisi();
//   final _formKey = GlobalKey<FormState>();
  
//   late TextEditingController _adController;
//   late TextEditingController _emailController;
//   bool _yukleniyor = false;

//   @override
//   void initState() {
//     super.initState();
//     final user = KimlikServisi.aktifKullanici;
//     _adController = TextEditingController(text: user?['name'] ?? "");
//     _emailController = TextEditingController(text: user?['email'] ?? "");
//   }

//   Future<void> _kaydet() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _yukleniyor = true);
      
//       final user = KimlikServisi.aktifKullanici;
//       if (user != null) {
//         bool basarili = await _apiServisi.bilgileriGuncelle(
//           int.parse(user['id'].toString()),
//           _adController.text,
//           _emailController.text,
//           user['phone'] ?? "",
//           "" // Şifre boş gönderiliyor
//         );

//         if (!mounted) return;
//         setState(() => _yukleniyor = false);

//         if (basarili) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Profil güncellendi!"), backgroundColor: Colors.green),
//           );
//           Navigator.pop(context);
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Profili Düzenle")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _adController,
//                 decoration: const InputDecoration(labelText: "Ad Soyad", border: OutlineInputBorder()),
//                 validator: (val) => val!.isEmpty ? "Boş bırakılamaz" : null,
//               ),
//               const SizedBox(height: 20),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(labelText: "E-posta", border: OutlineInputBorder()),
//                 validator: (val) => val!.isEmpty ? "Boş bırakılamaz" : null,
//               ),
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _yukleniyor ? null : _kaydet,
//                   style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
//                   child: _yukleniyor 
//                     ? const CircularProgressIndicator(color: Colors.white) 
//                     : const Text("DEĞİŞİKLİKLERİ KAYDET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }