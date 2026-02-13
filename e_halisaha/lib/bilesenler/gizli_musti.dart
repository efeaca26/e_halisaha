import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// --- TETİKLEYİCİ WIDGET (Bunu Versiyon Yazısının Etrafına Saracağız) ---
class GizliVideoTetikleyici extends StatefulWidget {
  final Widget child;
  final String videoYolu; // Örn: 'assets/video.mp4'

  const GizliVideoTetikleyici({
    super.key,
    required this.child,
    required this.videoYolu,
  });

  @override
  State<GizliVideoTetikleyici> createState() => _GizliVideoTetikleyiciState();
}

class _GizliVideoTetikleyiciState extends State<GizliVideoTetikleyici> {
  Timer? _zamanlayici;

  void _sayaciBaslat() {
    // 5.2 Saniye (5200 milisaniye) basılı tutulursa açılır
    _zamanlayici = Timer(const Duration(milliseconds: 5200), _videoyuAc);
  }

  void _sayaciIptal() {
    _zamanlayici?.cancel();
  }

  void _videoyuAc() {
    // Süre doldu! Videoyu aç.
    showDialog(
      context: context,
      barrierDismissible: false, // Dışarı tıklayınca kapanmasın
      builder: (context) => _GizliVideoPenceresi(videoYolu: widget.videoYolu),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _sayaciBaslat(), // Parmağı bastığı an
      onTapUp: (_) => _sayaciIptal(),   // Parmağı kaldırdığı an
      onTapCancel: _sayaciIptal,        // İşlem iptal olursa
      child: widget.child,
    );
  }
}

// --- VİDEO OYNATICI PENCERESİ ---
class _GizliVideoPenceresi extends StatefulWidget {
  final String videoYolu;
  const _GizliVideoPenceresi({required this.videoYolu});

  @override
  State<_GizliVideoPenceresi> createState() => _GizliVideoPenceresiState();
}

class _GizliVideoPenceresiState extends State<_GizliVideoPenceresi> {
  late VideoPlayerController _controller;
  bool _hazir = false;

  @override
  void initState() {
    super.initState();
    // 4. DÜZELTME: iOS Ses ayarları için 'mixWithOthers' eklendi
    _controller = VideoPlayerController.asset(
      widget.videoYolu,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )..initialize().then((_) {
        // initialize tamamlanınca çalışır
        if (mounted) {
          setState(() => _hazir = true);
          
          // 🔊 SESİ SON SES AÇ
          _controller.setVolume(1.0); 
          
          _controller.play();
          _controller.setLooping(true);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: _hazir
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(color: Colors.white),
          ),
          
          // Kapatma Butonu
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}