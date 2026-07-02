import 'package:flutter/material.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/widgets/skeleton/app_skeleton.dart';
import 'package:tranoo/widgets/transitaire_public_ui.dart';
import 'package:tranoo/widgets/transitaire_profile_ui.dart';
import 'package:tranoo/widgets/video_preview_placeholder.dart';
import 'package:video_player/video_player.dart';
import 'package:tranoo/widgets/tranoo_network_image.dart';
import 'package:tranoo/utils/tranoo_image_utils.dart';

class TransitaireGalleryItem {
  final String type;
  final String url;

  const TransitaireGalleryItem({required this.type, required this.url});

  bool get isVideo => type == 'video';
  bool get isImage => type == 'image';
}

List<TransitaireGalleryItem> parseTransitaireGallery(dynamic raw) {
  if (raw is! List) return const [];
  final items = <TransitaireGalleryItem>[];
  for (final entry in raw) {
    if (entry is! Map) continue;
    final type = (entry['type'] ?? '').toString();
    final url = (entry['url'] ?? '').toString().trim();
    if (url.isEmpty || (type != 'image' && type != 'video')) continue;
    items.add(TransitaireGalleryItem(type: type, url: url));
  }
  return items;
}

void showTransitaireGalleryVideo(BuildContext context, String url) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'close',
    barrierColor: Colors.black.withOpacity(0.92),
    pageBuilder: (ctx, _, __) => _TransitaireVideoViewer(url: url),
  );
}

class TransitaireGalleryGrid extends StatelessWidget {
  final List<TransitaireGalleryItem> items;
  final Map<String, dynamic> user;
  final String emptyMessage;
  final double bottomPadding;

  const TransitaireGalleryGrid({
    super.key,
    required this.items,
    required this.user,
    this.emptyMessage = '',
    this.bottomPadding = 24,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final message =
        emptyMessage.isNotEmpty ? emptyMessage : l10n.transitaireGalleryEmpty;
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library_outlined,
                  size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    final initials = TransitaireProfileHelpers.initials(user);

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        bottomPadding + MediaQuery.paddingOf(context).bottom,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: item.isVideo
              ? VideoPreviewPlaceholder(
                  videoUrl: item.url,
                  iconSize: 36,
                  onTap: () => showTransitaireGalleryVideo(context, item.url),
                )
              : GestureDetector(
                  onTap: () => showTransitairePhotoZoom(
                    context,
                    photoUrl: item.url,
                    initials: initials,
                  ),
                  child: TranooNetworkImage(
                    url: item.url,
                    fit: BoxFit.cover,
                    cloudinaryWidthPx: cloudinaryWidthPx(context),
                  ),
                ),
        );
      },
    );
  }
}

class _TransitaireVideoViewer extends StatefulWidget {
  final String url;

  const _TransitaireVideoViewer({required this.url});

  @override
  State<_TransitaireVideoViewer> createState() => _TransitaireVideoViewerState();
}

class _TransitaireVideoViewerState extends State<_TransitaireVideoViewer> {
  late VideoPlayerController _controller;
  bool _ready = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _controller.play();
      }).catchError((_) {
        if (!mounted) return;
        setState(() => _error = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_error)
              Text(
                AppLocalizations.of(context)!.videoPlaybackError,
                style: const TextStyle(color: Colors.white),
              )
            else if (_ready)
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            else
              SkeletonPresets.wrap(
                const SkeletonCircle(size: 48),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            if (_ready)
              Positioned(
                bottom: 24,
                child: IconButton(
                  iconSize: 56,
                  color: Colors.white,
                  icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
