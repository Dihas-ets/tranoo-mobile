import 'package:flutter/material.dart';
import 'package:tranoo/utils/page_refresh_registry.dart';

/// Pull-to-refresh avec affichage optionnel d'un skeleton pendant le rechargement.
class PagePullRefresh extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Widget? refreshSkeleton;
  final Color? color;

  const PagePullRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.refreshSkeleton,
    this.color,
  });

  factory PagePullRefresh.fromRegistry({
    Key? key,
    required BuildContext context,
    Future<void> Function()? fallback,
    required Widget child,
    Widget? refreshSkeleton,
    Color? color,
  }) {
    return PagePullRefresh(
      key: key,
      color: color,
      refreshSkeleton: refreshSkeleton,
      onRefresh: () async {
        await PageRefreshRegistry.refresh(context);
        if (fallback != null) await fallback();
      },
      child: child,
    );
  }

  @override
  State<PagePullRefresh> createState() => _PagePullRefreshState();
}

class _PagePullRefreshState extends State<PagePullRefresh> {
  bool _refreshing = false;

  Future<void> _handleRefresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _refreshing && widget.refreshSkeleton != null
        ? widget.refreshSkeleton!
        : widget.child;

    return RefreshIndicator(
      color: widget.color ?? const Color(0xFFFFCC00),
      onRefresh: _handleRefresh,
      child: body,
    );
  }
}
