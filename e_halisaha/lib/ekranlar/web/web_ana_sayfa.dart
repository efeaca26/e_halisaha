import 'package:flutter/material.dart';

class WebAnaSayfa extends StatefulWidget {
  final Map<String, dynamic> kullanici;
  const WebAnaSayfa({super.key, required this.kullanici});

  @override
  State<WebAnaSayfa> createState() => _WebAnaSayfaState();
}

class _WebAnaSayfaState extends State<WebAnaSayfa> {
  @override
  Widget build(BuildContext context) {
    // Rol kontrolü: Admin/İşletme ise kırmızı, Oyuncu ise yeşil tema
    String rol = (widget.kullanici['role'] ?? "oyuncu").toString().toLowerCase();
    bool isAdmin = rol == "admin" || rol == "isletme";
    Color anaRenk = isAdmin ? const Color(0xFFD32F2F) : const Color(0xFF15803D);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Row(
        children: [
          // 🚩 SOL SIDEBAR (SADECE ADMIN İÇİN)
          if (isAdmin) _buildSidebar(anaRenk),
          
          // ⚽ ANA İÇERİK ALANI
          Expanded(
            child: Column(
              children: [
                _buildTopBar(anaRenk),
                Expanded(
                  child: SingleChildScrollView(
                    child: isAdmin ? _buildAdminDashboard() : _buildUserDiscovery(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETLAR ---

  Widget _buildSidebar(Color renk) {
    return Container(
      width: 260,
      color: const Color(0xFFB71C1C),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text("ADMİN PANELİ", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          _sidebarItem(Icons.dashboard, "Dashboard", true),
          _sidebarItem(Icons.assignment, "Başvurular", false),
          _sidebarItem(Icons.people, "Kullanıcılar", false),
          _sidebarItem(Icons.stadium, "Tesisler", false),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, bool selected) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      selected: selected,
      selectedTileColor: Colors.black12,
      onTap: () {},
    );
  }

  Widget _buildTopBar(Color renk) {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Icon(Icons.location_on, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          const Text("Kocaeli, Gebze", style: TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(widget.kullanici['fullName'] ?? "Kullanıcı", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 15),
          const CircleAvatar(radius: 18, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
        ],
      ),
    );
  }

  // --- İÇERİK EKRANLARI ---

  Widget _buildAdminDashboard() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Platform Raporları", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              _statCard("Toplam Ciro", "0 ₺", Icons.payments, Colors.green),
              _statCard("Kullanıcılar", "5", Icons.people, Colors.blue),
              _statCard("Tesisler", "1", Icons.business, Colors.purple),
              _statCard("Rezervasyonlar", "4", Icons.calendar_month, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserDiscovery() {
    return Column(
      children: [
        // Yeşil Hero Banner
        Container(
          width: double.infinity,
          height: 300,
          color: const Color(0xFF15803D),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Halı Sahaları Keşfet", style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text("Hızlı ve kolay rezervasyon, %30 kapora ile güvenli ödeme", style: TextStyle(color: Colors.white70, fontSize: 18)),
            ],
          ),
        ),
        // Saha Kartları
        Padding(
          padding: const EdgeInsets.all(40),
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildFieldCard("ACFTK", "Gebze / Kocaeli", "0.0"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard(String title, String val, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey)),
                  Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldCard(String name, String loc, String rate) {
    return Container(
      width: 300,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
      child: Column(
        children: [
          Container(height: 150, color: const Color(0xFF22C55E), child: const Center(child: Icon(Icons.stadium, size: 50, color: Colors.white))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(loc, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E)),
                  child: const Center(child: Text("Rezervasyon Yap", style: TextStyle(color: Colors.white))),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}