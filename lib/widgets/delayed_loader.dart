import 'dart:async';

import 'package:flutter/material.dart';

/// Affiche un loader seulement si le chargement dépasse [delay] (évite le clignotement).
class DelayedLoader extends StatefulWidget {
  final bool loading;
  final Duration delay;
  final double size;
  final Color? color;
  final Widget? placeholder;

  const DelayedLoader({
    super.key,
    required this.loading,
    this.delay = const Duration(milliseconds: 80),
    this.size = 24,
    this.color,
    this.placeholder,
  });

  @override
  State<DelayedLoader> createState() => _DelayedLoaderState();
}

class _DelayedLoaderState extends State<DelayedLoader> {
  Timer? _timer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _sync(widget.loading);
  }

  @override
  void didUpdateWidget(covariant DelayedLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loading != widget.loading) {
      _sync(widget.loading);
    }
  }

  void _sync(bool loading) {
    _timer?.cancel();
    if (!loading) {
      if (_visible) setState(() => _visible = false);
      return;
    }
    _timer = Timer(widget.delay, () {
      if (!mounted || !widget.loading) return;
      setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) {
      return widget.placeholder ?? const SizedBox.shrink();
    }
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: widget.color,
      ),
    );
  }
}

/// Centre un [DelayedLoader] dans la page.
class DelayedLoaderOverlay extends StatelessWidget {
  final bool loading;
  final Widget child;

  const DelayedLoaderOverlay({
    super.key,
    required this.loading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (loading)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: DelayedLoader(loading: loading),
              ),
            ),
          ),
      ],
    );
  }
}
