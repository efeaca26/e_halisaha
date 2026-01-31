class OdemeServisi {
  // Hafızadaki kayıtlı kartlar
  static final List<Map<String, String>> _kayitliKartlar = [
    {'no': '**** **** **** 4242', 'isim': 'Test Kartı'}
  ];

  static List<Map<String, String>> get kartlar => _kayitliKartlar;

  static void kartEkle(String kartNo, String isim) {
    // Sadece son 4 haneyi gösterip maskeleyelim
    String maskeliNo = kartNo.length > 4 
        ? "**** **** **** ${kartNo.substring(kartNo.length - 4)}" 
        : kartNo;
        
    _kayitliKartlar.add({'no': maskeliNo, 'isim': isim});
  }

  static void kartSil(int index) {
    _kayitliKartlar.removeAt(index);
  }
}