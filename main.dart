import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAphYx9v8lCs7GzVgrMCrx-KNFxGxC8Klc",
      authDomain: "mobiluygulamafinali.firebaseapp.com",
      projectId: "mobiluygulamafinali",
      storageBucket: "mobiluygulamafinali.appspot.com",
      messagingSenderId: "207665247032",
      appId: "1:207665247032:web:554d99c7c281b569a247cd",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Öğrenci Notları',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NotGirisiEkrani(),
    );
  }
}

class NotGirisiEkrani extends StatefulWidget {
  @override
  _NotGirisiEkraniState createState() => _NotGirisiEkraniState();
}

class _NotGirisiEkraniState extends State<NotGirisiEkrani> {
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _soyadController = TextEditingController();
  final TextEditingController _notController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> ogrenciListesi = [];

  void _hesaplaVeNotKaydet() {
    String ad = _adController.text;
    String soyad = _soyadController.text;
    int not = int.tryParse(_notController.text) ?? 0;

    // Harf notu hesaplama
    String harfNotu = harfNotunuHesapla(not);

    // Firestore'a kaydetme
    _firestore.collection('ogrenciler').add({
      'ad': ad,
      'soyad': soyad,
      'not': not,
      'harfNotu': harfNotu,
    });

    // Not giriş kutularını temizleme
    _adController.clear();
    _soyadController.clear();
    _notController.clear();

    // Öğrenci listesini güncelleme
    setState(() {
      ogrenciListesi.add({
        'ad': ad,
        'soyad': soyad,
        'not': not,
        'harfNotu': harfNotu,
      });
    });
  }

  void _ogrenciSil(String ad, String soyad) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('ogrenciler')
        .where('ad', isEqualTo: ad)
        .where('soyad', isEqualTo: soyad)
        .get();

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      documentSnapshot.reference.delete();
    }

    // Öğrenci listesini güncelleme
    setState(() {
      ogrenciListesi.removeWhere(
          (ogrenci) => ogrenci['ad'] == ad && ogrenci['soyad'] == soyad);
    });

    // Uyarı göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Öğrenci silindi.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _notGuncelle(String ad, String soyad, int yeniNot) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('ogrenciler')
        .where('ad', isEqualTo: ad)
        .where('soyad', isEqualTo: soyad)
        .get();

    for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
      documentSnapshot.reference.update({'not': yeniNot});
    }

    // Öğrenci listesini güncelleme
    setState(() {
      ogrenciListesi.firstWhere((ogrenci) =>
          ogrenci['ad'] == ad && ogrenci['soyad'] == soyad)['not'] = yeniNot;
    });

    // Uyarı göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Öğrenci notu güncellendi.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String harfNotunuHesapla(int not) {
    if (not >= 90) {
      return 'A';
    } else if (not >= 80) {
      return 'B';
    } else if (not >= 70) {
      return 'C';
    } else if (not >= 60) {
      return 'D';
    } else {
      return 'F';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Öğrenci Notları'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _adController,
              decoration: InputDecoration(
                labelText: 'Adınızı Girin',
              ),
            ),
            TextField(
              controller: _soyadController,
              decoration: InputDecoration(
                labelText: 'Soyadınızı Girin',
              ),
            ),
            TextField(
              controller: _notController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Notunuzu Girin (0-100)',
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _hesaplaVeNotKaydet,
                  child: Text('Gönder'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // Sil butonuna basıldığında ilgili öğrenciyi sil
                    _ogrenciSil(_adController.text, _soyadController.text);
                  },
                  child: Text('Sil'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // Not güncelleme butonuna basıldığında ilgili öğrencinin notunu güncelle
                    int yeniNot = int.tryParse(_notController.text) ?? 0;
                    _notGuncelle(
                        _adController.text, _soyadController.text, yeniNot);
                  },
                  child: Text('Not Güncelle'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              'Öğrenci Listesi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: ogrenciListesi.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      '${ogrenciListesi[index]['ad']} ${ogrenciListesi[index]['soyad']}',
                    ),
                    subtitle: Text(
                      'Not: ${ogrenciListesi[index]['not']} - Harf Notu: ${ogrenciListesi[index]['harfNotu']}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
