import '../../modeller/saha_modeli.dart';

class SahteVeriServisi {
  static List<SahaModeli> sahalariGetir() {
    return [
      SahaModeli(
        id: '1',
        isim: 'Altınordu Halı Saha', //
        ilce: 'Gebze',
        tamKonum: 'Arapçeşme Mah. Gençlik Cad.',
        fiyat: 1400.0,
        kapora: 200.0,
        resimYolu: 'assets/resimler/saha1.png',
        puan: 4.8,
        ozellikler: ['Kapalı Saha', 'Duş', 'Krampon Kiralama', 'Otopark'],
      ),
      SahaModeli(
        id: '2',
        isim: 'Mega Spor Tesisleri',
        ilce: 'Darıca',
        tamKonum: 'Sahil Yolu, No: 5',
        fiyat: 1200.0,
        kapora: 150.0,
        resimYolu: 'assets/resimler/saha2.png',
        puan: 4.5,
        ozellikler: ['Açık Saha', 'Kafe', 'Wifi'],
      ),
      SahaModeli(
        id: '3',
        isim: 'Çayırova Arena',
        ilce: 'Çayırova',
        tamKonum: 'Fatih Cad. No:12',
        fiyat: 1000.0,
        kapora: 100.0,
        resimYolu: 'assets/resimler/saha3.png',
        puan: 4.2,
        ozellikler: ['Kapalı Saha', 'Servis Var'],
      ),
    ];
  }

  // Dolu saatleri simüle edelim (Sunucu olmadığı için buradan çekiyoruz)
  // ID'si 1 olan saha için akşam 20:00 ve 22:00 dolu olsun.
  static List<String> doluSaatleriGetir(String sahaId) {
    if (sahaId == '1') {
      return ['20:00', '22:00']; 
    }
    return ['19:00'];
  }
}