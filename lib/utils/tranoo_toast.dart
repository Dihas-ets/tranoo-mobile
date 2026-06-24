import 'package:flutter/material.dart';

const Color kTranooToastNavy = Color(0xFF1B2B4B);
const Color kTranooToastAmber = Color(0xFFF8BF13);

Widget _tranooLoadingBody() {
  return PopScope(
    canPop: false,
    child: Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
          decoration: BoxDecoration(
            color: kTranooToastNavy,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kTranooToastAmber.withOpacity(0.45)),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: kTranooToastAmber,
                ),
              ),
              SizedBox(height: 14),
              Text(
                'Veuillez patienter…',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Affiche le loader puis exécute [action]. Ne pas `await showDialog` avant l'API.
Future<T> withTranooLoading<T>(
  BuildContext context,
  Future<T> Function() action,
) async {
  if (!context.mounted) return action();

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) => _tranooLoadingBody(),
  );

  try {
    return await action();
  } finally {
    hideTranooLoading(context);
  }
}

void hideTranooLoading(BuildContext context) {
  if (!context.mounted) return;
  final navigator = Navigator.of(context, rootNavigator: true);
  if (navigator.canPop()) {
    navigator.pop();
  }
}

void showTranooToast(
  BuildContext context, {
  required String message,
  bool isError = false,
  bool isSuccess = false,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) {
      return Positioned(
        top: MediaQuery.of(ctx).padding.top + 16,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            builder: (_, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * -12),
                child: child,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isError
                    ? const Color(0xFFB3261E)
                    : kTranooToastNavy,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: isError
                      ? Colors.white.withOpacity(0.2)
                      : kTranooToastAmber.withOpacity(0.45),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isError
                        ? Icons.error_outline_rounded
                        : isSuccess
                            ? Icons.check_circle_rounded
                            : Icons.info_outline_rounded,
                    color: isError ? Colors.white : kTranooToastAmber,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 3), () {
    if (entry.mounted) entry.remove();
  });
}
