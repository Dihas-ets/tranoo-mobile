import 'package:flutter/material.dart';
import 'payement.dart';
import 'package:video_player/video_player.dart';

class Movie extends StatefulWidget {
  final String? videoUrl;
  const Movie({super.key, this.videoUrl});

  @override
  State<Movie> createState() => _MovieState();
}

class _MovieState extends State<Movie> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
      _controller!.initialize().then((_) {
        setState(() {
          _initialized = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: _buildAppBar(),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [_buildVideoSection(), _buildContentSection()],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    if (widget.videoUrl != null && _initialized && _controller != null) {
      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            VideoPlayer(_controller!),
            VideoProgressIndicator(_controller!, allowScrubbing: true),
            Align(
              alignment: Alignment.center,
              child: IconButton(
                icon: Icon(
                  _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ),
                onPressed: () {
                  setState(() {
                    _controller!.value.isPlaying
                        ? _controller!.pause()
                        : _controller!.play();
                  });
                },
              ),
            ),
          ],
        ),
      );
    } else {
      // Fallback : icône play sur image statique
      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 500,
            width: 700,
            child: Image.asset(
              'assets/images/teslapro.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(child: Text('Vidéo non disponible')),
                );
              },
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Colors.deepOrange,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 50),
          ),
        ],
      );
    }
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildOrderButton(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tesla Modèle 3',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // Row(
            //   children: const [
            //     Text(
            //       '0',
            //       style: TextStyle(
            //         fontSize: 16,
            //         color: Colors.blue,
            //       ),
            //     ),
            //     Text(
            //       ' / 5 ',
            //       style: TextStyle(
            //         fontSize: 16,
            //         color: Colors.blue,
            //       ),
            //     ),
            //     Icon(
            //       Icons.star,
            //       color: Colors.blue,
            //     ),
            //   ],
            // ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Regarder la vidéo',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildOrderButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PayementScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'Passez la commande',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
