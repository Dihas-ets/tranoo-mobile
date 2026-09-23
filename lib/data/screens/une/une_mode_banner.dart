import 'package:flutter/material.dart';
import 'package:tranoo/l10n/app_localizations.dart';

/// Bannière mode (standalone vs article) + états chargement article.
class UneModeBanner extends StatelessWidget {
  const UneModeBanner({
    super.key,
    required this.isStandalone,
    required this.hasArticleId,
    required this.isLoadingArticle,
  });

  final bool isStandalone;
  final bool hasArticleId;
  final bool isLoadingArticle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isStandalone ? Colors.orange.shade50 : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isStandalone ? Colors.orange.shade200 : Colors.blue.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isStandalone ? Icons.campaign : Icons.article,
                    color: isStandalone
                        ? Colors.orange.shade700
                        : Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isStandalone ? l10n.standaloneAd : l10n.existingArticleAd,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isStandalone
                          ? Colors.orange.shade700
                          : Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isStandalone
                    ? l10n.standaloneAdDesc
                    : !hasArticleId
                        ? l10n.nonExistingPubDesc
                        : l10n.existingArticlePubDesc,
                style: TextStyle(
                  fontSize: 14,
                  color: isStandalone
                      ? Colors.orange.shade600
                      : !hasArticleId
                          ? Colors.orange.shade600
                          : Colors.blue.shade600,
                ),
              ),
            ],
          ),
        ),
        if (!isStandalone && isLoadingArticle) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.loadingArticleInfo,
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (!isStandalone && hasArticleId && !isLoadingArticle) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.articleLoadedSuccess,
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
