import 'package:flutter/material.dart';
import 'package:tranoo/utils/catalog_filter_options.dart';

/// Champ localisation avec suggestions de pays uniquement.
class CountryLocationField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final ValueChanged<String>? onChanged;

  const CountryLocationField({
    super.key,
    required this.controller,
    this.label = 'Localisation',
    this.hint,
    this.onChanged,
  });

  @override
  State<CountryLocationField> createState() => _CountryLocationFieldState();
}

class _CountryLocationFieldState extends State<CountryLocationField> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _updateSuggestions(widget.controller.text);
      _showOverlay();
    } else {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!_focusNode.hasFocus) _removeOverlay();
      });
    }
  }

  void _onTextChange() {
    _updateSuggestions(widget.controller.text);
    widget.onChanged?.call(widget.controller.text);
    if (_focusNode.hasFocus) {
      _overlayEntry?.markNeedsBuild();
    }
  }

  void _updateSuggestions(String text) {
    final query = text.trim();
    final lastComma = query.lastIndexOf(',');
    final segment =
        lastComma >= 0 ? query.substring(lastComma + 1).trim() : query;
    _suggestions = filterCountrySuggestions(segment);
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = OverlayEntry(builder: (context) => _buildOverlay());
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _applySuggestion(String country) {
    final text = widget.controller.text;
    final lastComma = text.lastIndexOf(',');
    if (lastComma >= 0) {
      final prefix = text.substring(0, lastComma + 1);
      widget.controller.text = '$prefix $country';
    } else {
      widget.controller.text = country;
    }
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.controller.text.length),
    );
    widget.onChanged?.call(widget.controller.text);
    _removeOverlay();
    _focusNode.unfocus();
  }

  Widget _buildOverlay() {
    if (_suggestions.isEmpty) return const SizedBox.shrink();
    final renderBox = context.findRenderObject() as RenderBox?;
    final width = renderBox?.size.width ?? MediaQuery.of(context).size.width - 32;

    return Positioned(
      width: width,
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 52),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final country = _suggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(country),
                  onTap: () => _applySuggestion(country),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint ?? 'Ex. Bénin ou Cotonou, Bénin',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onTap: () {
          _updateSuggestions(widget.controller.text);
          _showOverlay();
        },
      ),
    );
  }
}
