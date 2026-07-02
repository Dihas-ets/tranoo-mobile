import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer';
import 'package:tranoo/utils/cloudinary_url.dart';

class Movie extends StatefulWidget {
  final String? videoUrl;
  final Map<String, dynamic>? article;

  const Movie({super.key, this.videoUrl, this.article});

  @override
  State<Movie> createState() => _MovieState();
}

class _MovieState extends State<Movie> {
  late WebViewController _webController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    log('[MOVIE] initState called');
    log('[MOVIE] videoUrl: ${widget.videoUrl}');

    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _initialized = true;
            });
          },
        ),
      );

    if (widget.videoUrl != null) {
      final htmlContent = '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body { margin: 0; padding: 0; background: black; display: flex; justify-content: center; align-items: center; height: 100vh; }
            video { width: 100%; height: auto; max-height: 100vh; }
          </style>
        </head>
        <body>
          <video id="vid" controls autoplay playsinline muted>
            <source src="${widget.videoUrl}" type="video/mp4">
            Votre navigateur ne supporte pas la lecture vidéo.
          </video>
          <script>
            const v = document.getElementById('vid');
            if (v) {
              const tryPlay = () => {
                v.play().catch(() => {});
              };
              v.addEventListener('loadeddata', tryPlay);
              v.addEventListener('canplay', tryPlay);
              tryPlay();
            }
          </script>
        </body>
        </html>
      ''';

      _webController.loadHtmlString(htmlContent);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: _buildVideoSection(),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    final thumbUrl = cloudinaryVideoThumbUrl(widget.videoUrl);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (thumbUrl != null)
          CachedNetworkImage(
            imageUrl: thumbUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => const ColoredBox(color: Colors.black),
            errorWidget: (_, __, ___) => const ColoredBox(color: Colors.black),
          )
        else
          const ColoredBox(color: Colors.black),
        if (widget.videoUrl != null && _initialized)
          WebViewWidget(controller: _webController)
        else
          Center(
            child: Icon(
              Icons.play_circle_outline,
              color: Colors.white.withValues(alpha: 0.85),
              size: 72,
            ),
          ),
      ],
    );
  }
}
