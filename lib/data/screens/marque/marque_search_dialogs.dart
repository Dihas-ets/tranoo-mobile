import 'package:flutter/material.dart';
import 'package:tranoo/data/screens/piece.dart';
import 'package:tranoo/data/screens/voitures.dart';
import 'package:tranoo/l10n/app_localizations.dart';

void _pushSearch(
  BuildContext context, {
  required Widget page,
  required String searchQuery,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => page,
      settings: RouteSettings(
        arguments: {'searchQuery': searchQuery},
      ),
    ),
  );
}

/// Dialogue « type de recherche » (icône filtre).
Future<void> showMarqueSearchTypeDialog({
  required BuildContext context,
  required String searchQuery,
  void Function(Object error, StackTrace stackTrace)? onError,
}) async {
  final l10n = AppLocalizations.of(context)!;
  try {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.tune, color: Color(0xFFB45309)),
              const SizedBox(width: 8),
              Text(l10n.searchTypeTitle),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.whatDoYouWantToSearch),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _pushSearch(
                      context,
                      page: const VoituresPage(),
                      searchQuery: searchQuery,
                    );
                  },
                  icon: const Icon(Icons.directions_car),
                  label: Text(l10n.vehicles),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB45309),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _pushSearch(
                      context,
                      page: const PiecePage(),
                      searchQuery: searchQuery,
                    );
                  },
                  icon: const Icon(Icons.build),
                  label: Text(l10n.pieces),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  } catch (e, stackTrace) {
    onError?.call(e, stackTrace);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorGeneric('$e')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Dialogue hint après saisie dans la barre de recherche.
Future<void> showMarqueSearchHintDialog({
  required BuildContext context,
  required String searchQuery,
}) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          const Icon(Icons.lightbulb, color: Color(0xFFB45309)),
          const SizedBox(width: 8),
          Text(l10n.chooseTypeTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.youTyped(searchQuery)),
          const SizedBox(height: 12),
          Text(l10n.whatArticleTypeSearch),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _pushSearch(
                      context,
                      page: const VoituresPage(),
                      searchQuery: searchQuery,
                    );
                  },
                  icon: const Icon(Icons.directions_car),
                  label: Text(l10n.vehicleSingular),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB45309),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _pushSearch(
                      context,
                      page: const PiecePage(),
                      searchQuery: searchQuery,
                    );
                  },
                  icon: const Icon(Icons.build),
                  label: Text(l10n.partSingular),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    ),
  );
}
