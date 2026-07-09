import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tranoo/utils/brand_logo_resolver.dart';

const Map<String, String> _brandSvgHeaders = {
  'User-Agent': 'TranooApp/1.0 (Flutter; catalog filters)',
};

/// Affiche un logo marque : Motomarks → Wikimedia PNG → SVG.
class CatalogFilterBrandLogo extends StatefulWidget {
  final String normalizedKey;
  final String label;
  final String? networkSvgUrl;
  final double width;
  final double height;

  const CatalogFilterBrandLogo({
    super.key,
    required this.normalizedKey,
    required this.label,
    this.networkSvgUrl,
    required this.width,
    required this.height,
  });

  @override
  State<CatalogFilterBrandLogo> createState() => _CatalogFilterBrandLogoState();
}

class _CatalogFilterBrandLogoState extends State<CatalogFilterBrandLogo> {
  late final List<String> _urls;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _urls = brandLogoCandidateUrls(
      normalizedKey: widget.normalizedKey,
      networkSvgUrl: widget.networkSvgUrl,
      displayWidth: widget.width,
    );
  }

  void _useNextUrl() {
    if (_index + 1 < _urls.length) {
      setState(() => _index++);
    }
  }

  Widget _letterFallback() {
    final letter =
        widget.label.isNotEmpty ? widget.label[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: widget.width / 2,
      backgroundColor: Colors.grey.shade300,
      child: Text(
        letter,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_urls.isEmpty || _index >= _urls.length) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: _letterFallback(),
      );
    }

    final url = _urls[_index];
    final isSvg = url.toLowerCase().contains('.svg');

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: isSvg
          ? SvgPicture.network(
              url,
              fit: BoxFit.contain,
              headers: _brandSvgHeaders,
              placeholderBuilder: (_) => _letterFallback(),
              errorBuilder: (_, __, ___) {
                if (_index + 1 < _urls.length) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _index++);
                  });
                  return const SizedBox.shrink();
                }
                return _letterFallback();
              },
            )
          : Image.network(
              url,
              width: widget.width,
              height: widget.height,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                if (_index + 1 < _urls.length) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _index++);
                  });
                  return const SizedBox.shrink();
                }
                return _letterFallback();
              },
            ),
    );
  }
}
