import 'package:flutter/material.dart';
import 'package:tranoo/utils/page_refresh_registry.dart';

class AppRefreshShell extends StatefulWidget {
  final Widget? child;

  const AppRefreshShell({super.key, required this.child});

  @override
  State<AppRefreshShell> createState() => _AppRefreshShellState();
}

class _AppRefreshShellState extends State<AppRefreshShell> {
  bool _refreshing = false;

  Future<void> _handleRefresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      await PageRefreshRegistry.refresh(context);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<OverscrollNotification>(
          onNotification: (notification) {
            if (_refreshing) return false;
            if (notification.overscroll >= 0) return false;
            if (notification.metrics.pixels > 0) return false;
            if (notification.depth > 2) return false;
            _handleRefresh();
            return false;
          },
          child: widget.child ?? const SizedBox.shrink(),
        ),
        if (_refreshing)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 2,
              child: SafeArea(
                bottom: false,
                child: LinearProgressIndicator(minHeight: 3),
              ),
            ),
          ),
      ],
    );
  }
}
