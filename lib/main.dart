import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(UzayOyunu());
}

class UzayOyunu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: OyunEkrani(),
    );
  }
}

class OyunEkrani extends StatefulWidget {
  @override
  _OyunEkraniState createState() => _OyunEkraniState();
}

class _OyunEkraniState extends State<OyunEkrani> {
  double uzayGemiX = 0.0;
  double uzayGemiY = 0.0;
  double lazerX = -100.0;
  double lazerY = 0.0;
  double dusmanX = 0.0;
  double dusmanY = 0.0;
  int puan = 0;
  int kalanSure = 60;
  bool oyunBitti = false;

  AudioCache _audioCache = AudioCache();

  Timer? atisTimer;
  Timer? dusmanHareketTimer;

  @override
  void initState() {
    super.initState();
    baslangicDurumu();
  }

  void baslangicDurumu() {
    atisTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      if (!oyunBitti) {
        hareketleriGuncelle();
      }
    });

    dusmanHareketTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!oyunBitti && kalanSure > 0) {
        setState(() {
          kalanSure--;
        });
      } else {
        timer.cancel();
        setState(() {
          oyunBitti = true;
        });
      }
    });
  }

  void dusmanKonumunuAyarla() {
    setState(() {
      Random random = Random();
      dusmanX = random.nextDouble() * MediaQuery.of(context).size.width;
      dusmanY = 0.0;
    });
  }

  void hareketleriGuncelle() {
    setState(() {
      dusmanY += 3;
      if (dusmanY > MediaQuery.of(context).size.height) {
        dusmanKonumunuAyarla();
      }

      if (lazerY > 0) {
        lazerY -= 5;
        if ((lazerX > dusmanX - 30) &&
            (lazerX < dusmanX + 30) &&
            (lazerY > dusmanY - 30) &&
            (lazerY < dusmanY + 30)) {
          dusmanKonumunuAyarla();
          lazerX = -100.0;
          lazerY = 0.0;
          puan += 10;

          // Düşman gemi vurulduğunda ses çal
          _audioCache.play('dusman_vuruldu.mp3');
        }
      }
    });
  }

  void seriAtis() {
    if (lazerY <= 0) {
      lazerX = uzayGemiX + 25;
      lazerY = uzayGemiY - 30;
    }
    _audioCache.play('lazerr.mp3');
  }

  void oyunuYenidenBaslat() {
    setState(() {
      uzayGemiX = 0.0;
      uzayGemiY = MediaQuery.of(context).size.height - 250.0;
      lazerX = -100.0;
      lazerY = 0.0;
      dusmanX = 0.0;
      dusmanY = 0.0;
      puan = 0;
      kalanSure = 60;
      oyunBitti = false;
    });

    atisTimer?.cancel();
    dusmanHareketTimer?.cancel();

    baslangicDurumu();
  }

  void gemiyiHareketEttir(Offset globalPosition) {
    setState(() {
      uzayGemiX =
          globalPosition.dx - 25; // Gemi genişliği 50.0 olduğunu varsayalım
    });
  }

  @override
  Widget build(BuildContext context) {
    uzayGemiY = MediaQuery.of(context).size.height - 250.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Niloş ile Hüma Uzayda'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/galaksi.jpg',
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            left: uzayGemiX,
            top: uzayGemiY,
            child: GestureDetector(
              onPanUpdate: (details) {
                gemiyiHareketEttir(details.globalPosition);
              },
              onTap: () {
                if (!oyunBitti) {
                  setState(() {
                    lazerX = uzayGemiX + 25;
                    lazerY = uzayGemiY - 30;
                    seriAtis();
                  });
                }
              },
              child: UzayGemi(),
            ),
          ),
          Positioned(
            left: dusmanX,
            top: dusmanY,
            child: DusmanGemi(),
          ),
          Positioned(
            left: lazerX,
            top: lazerY,
            child: Lazer(),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Text(
              'Puan: $puan',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Text(
              'Kalan Süre: $kalanSure saniye',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          if (oyunBitti)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Oyun Bitti! Puanınız: $puan',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Image.asset(
                    'assets/credit.jpeg',
                    width: 200.0,
                    height: 200.0,
                    fit: BoxFit.cover,
                  ),
                  ElevatedButton(
                    onPressed: oyunuYenidenBaslat,
                    child: Text('Tekrar Başla'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class UzayGemi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.0,
      height: 50.0,
      child: Image.asset('assets/uzay_gemi.png'),
    );
  }
}

class DusmanGemi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.0,
      height: 50.0,
      child: Image.asset('assets/dusman_gemi.png'),
    );
  }
}

class Lazer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5.0,
      height: 30.0,
      child: Image.asset('assets/lazer.png'),
    );
  }
}
