import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Affiche un aperçu vidéo (première frame) avec bouton lecture cliquable.
class VideoPreviewPlaceholder extends StatefulWidget {
  final String? videoUrl;
  final double iconSize;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final VoidCallback? onTap;
  final bool enablePreviewFrame;

  const VideoPreviewPlaceholder({
    super.key,
    this.videoUrl,
    this.iconSize = 40,
    this.label = 'Vidéo disponible',
    this.backgroundColor = Colors.black87,
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
    this.onTap,
    this.enablePreviewFrame = true,
  });

  @override
  State<VideoPreviewPlaceholder> createState() =>
      _VideoPreviewPlaceholderState();
}

class _VideoPreviewPlaceholderState extends State<VideoPreviewPlaceholder> {
  VideoPlayerController? _controller;
  bool _initTried = false;

  @override
  void initState() {
    super.initState();
    _initializePreview();
  }

  Future<void> _initializePreview() async {
    if (widget.videoUrl == null || widget.videoUrl!.isEmpty) {
      setState(() {
        _initTried = true;
      });
      return;
    }
    if (widget.enablePreviewFrame) {
      try {
        final controller =
            VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
        _controller = controller;
        await controller.initialize();
        await controller.setLooping(false);
        await controller.pause();
      } catch (_) {
        // silent fail -> fallback to placeholder
      }
    }
    if (mounted) {
      setState(() {
        _initTried = true;
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
    final canShowFrame = widget.enablePreviewFrame &&
        _controller != null &&
        _controller!.value.isInitialized;
    final thumbUrl = _buildCloudinaryThumb(widget.videoUrl);

    Widget content = Container(
      width: double.infinity,
      height: double.infinity,
      color: widget.backgroundColor,
      child: Stack(
        children: [
          if (thumbUrl != null)
            Positioned.fill(
              child: Image.network(
                thumbUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: widget.backgroundColor),
              ),
            ),
          if (canShowFrame)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_circle_fill,
                    color: widget.iconColor == Colors.white
                        ? Colors.grey[900]
                        : widget.iconColor,
                    size: widget.iconSize,
                  ),
                ),
                if (widget.label.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.onTap != null) {
      content = GestureDetector(onTap: widget.onTap, child: content);
    }

    // If initialization has not been attempted yet, keep placeholder background
    return content;
  }

  String? _buildCloudinaryThumb(String? url) {
    if (url == null || url.isEmpty) return null;
    // Fonctionne pour URLs Cloudinary: .../upload/.../publicId.ext -> .../upload/so_1/.../publicId.jpg
    final uploadIndex = url.indexOf('/upload/');
    if (uploadIndex == -1) return null;
    final prefix = url.substring(0, uploadIndex + '/upload/'.length);
    final suffix = url.substring(uploadIndex + '/upload/'.length);
    final noExt = suffix.contains('.')
        ? suffix.substring(0, suffix.lastIndexOf('.'))
        : suffix;
    return '$prefix' 'so_1/$noExt.jpg';
  }
}
