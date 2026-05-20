import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tranoo/providers/auth_provider.dart' as myauth;
import 'package:tranoo/providers/counter_provider.dart';

class PageRefreshRegistry {
  PageRefreshRegistry._();

  static final List<Future<void> Function()> _stack = [];

  static void push(Future<void> Function() handler) {
    _stack.remove(handler);
    _stack.add(handler);
  }

  static void pop(Future<void> Function() handler) {
    _stack.remove(handler);
  }

  static Future<void> refresh(BuildContext? context) async {
    if (_stack.isNotEmpty) {
      await _stack.last();
      return;
    }
    if (context != null && context.mounted) {
      await _defaultRefresh(context);
    }
  }

  static Future<void> _defaultRefresh(BuildContext context) async {
    try {
      await Provider.of<myauth.AuthProvider>(context, listen: false)
          .reloadUser();
    } catch (_) {}
    try {
      await Provider.of<CounterProvider>(context, listen: false).loadCounters();
    } catch (_) {}
  }
}

mixin RegisterPageRefresh<T extends StatefulWidget> on State<T> {
  Future<void> onPagePullRefresh();

  late final Future<void> Function() _refreshHandler = () async {
    if (!mounted) return;
    await onPagePullRefresh();
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) PageRefreshRegistry.push(_refreshHandler);
    });
  }

  @override
  void dispose() {
    PageRefreshRegistry.pop(_refreshHandler);
    super.dispose();
  }
}
