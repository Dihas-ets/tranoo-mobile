import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tranoo/utils/tranoo_image_utils.dart';
import 'package:tranoo/widgets/tranoo_network_image.dart';

/// Palette unique — jaune doux Tranoo.
const Color kVerifyYellow = Color(0xFFFBBF24);
const Color kVerifyYellowSoft = Color(0xFFFFF8E7);
const Color kVerifyYellowBorder = Color(0xFFFDE68A);
const Color kVerifyText = Color(0xFF1F2937);
const Color kVerifyTextMuted = Color(0xFF6B7280);

/// Numéro support Tranoo (aligné sur cars_info « Acheter cette voiture »).
const String kTranooWhatsAppPhone = '22941839801';

String resolveCloudinaryDownloadUrl(String url) {
  var u = url.trim();
  if (u.isEmpty) return u;
  if (u.contains('/image/upload/') &&
      RegExp(r'\.pdf(\?|$)', caseSensitive: false).hasMatch(u)) {
    u = u.replaceAll('/image/upload/', '/raw/upload/');
  }
  if (u.contains('res.cloudinary.com') && !u.contains('fl_attachment')) {
    u = u.contains('?') ? '$u&fl_attachment' : '$u?fl_attachment';
  }
  return u;
}

List<String> cloudinaryDownloadCandidates(String url) {
  final base = resolveCloudinaryDownloadUrl(url);
  final raw = url.contains('/image/upload/')
      ? url.replaceAll('/image/upload/', '/raw/upload/')
      : url;
  return [...{base, raw, url}.where((e) => e.trim().isNotEmpty)];
}

Future<void> openTranooWhatsApp({String? text}) async {
  final phone = kTranooWhatsAppPhone.replaceAll(RegExp(r'[^0-9]'), '');
  final uri = (text != null && text.trim().isNotEmpty)
      ? Uri.parse(
          'https://wa.me/$phone?text=${Uri.encodeComponent(text.trim())}',
        )
      : Uri.parse('https://wa.me/$phone');

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return;
  }
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
}

Future<void> openRemoteAttachment(
  BuildContext context,
  String url, {
  String? label,
}) async {
  final name = label ??
      url.split('/').last.split('?').first.split('%2F').last;
  final candidates = cloudinaryDownloadCandidates(url);

  for (final candidate in candidates) {
    try {
      final dio = Dio();
      final resp = await dio.get<List<int>>(
        candidate,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (s) => s != null && s < 500,
        ),
      );
      if (resp.statusCode != 200) continue;
      final bytes = resp.data;
      if (bytes == null || bytes.isEmpty) continue;
      final xfile = XFile.fromData(
        bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
        name: name.contains('.') ? name : '$name.pdf',
        mimeType: _guessMime(name),
      );
      final l10n = AppLocalizations.of(context);
      await Share.shareXFiles(
        [xfile],
        text: l10n?.tranooDocumentShare ?? 'Document Tranoo',
      );
      return;
    } catch (_) {}
  }

  if (!context.mounted) return;
  for (final candidate in candidates) {
    try {
      final uri = Uri.parse(candidate);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}
  }
  if (!context.mounted) return;
  final l10n = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.fileDownloadFailed)),
  );
}

String? _guessMime(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.pdf')) return 'application/pdf';
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
    return 'image/jpeg';
  }
  return null;
}

String? notifString(Map<String, dynamic> n, String key) {
  final v = n[key];
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

String? notifNestedString(dynamic obj, String key) {
  if (obj is! Map) return null;
  return notifString(Map<String, dynamic>.from(obj), key);
}

String _fileLabel(String url, String fallback) {
  final raw = url.split('/').last.split('?').first;
  if (raw.isEmpty || raw.length > 48) return fallback;
  return Uri.decodeComponent(raw);
}

void showVerificationImagePreview(
  BuildContext context, {
  required String url,
  required String title,
}) {
  final l10n = AppLocalizations.of(context)!;
  showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: kVerifyText,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.45,
            width: double.infinity,
            child: InteractiveViewer(
              child: TranooNetworkImage(
                url: url,
                fit: BoxFit.contain,
                cloudinaryWidthPx: cloudinaryWidthPx(ctx),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                openRemoteAttachment(context, url, label: title);
              },
              icon: const Icon(Icons.download_outlined, size: 20),
              label: Text(l10n.download),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _compactAttachmentTile({
  required BuildContext context,
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return Material(
    color: kVerifyYellowSoft,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kVerifyYellow.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 22, color: kVerifyText),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: kVerifyText,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: kVerifyTextMuted),
          ],
        ),
      ),
    ),
  );
}

/// Carte + contenu vérification (mobile).
Widget buildVerificationNotificationContent({
  required BuildContext context,
  required Map<String, dynamic> notification,
  required String bodyHtml,
  required List<String> images,
  required List<String> documents,
  String? stampUrl,
  String? signatureUrl,
  String? pdfUrl,
  bool showLogo = false,
  String Function(DateTime)? formatDate,
  VoidCallback? onApprove,
  VoidCallback? onReject,
}) {
  final l10n = AppLocalizations.of(context)!;
  final title = notifString(notification, 'title') ?? l10n.verificationAction;
  final details = notifString(notification, 'details');
  final status = notifString(notification, 'status') ?? 'pending';
  final date = notification['date'];
  final dateLabel = date is DateTime && formatDate != null
      ? formatDate(date)
      : '';

  final articleId = notifNestedString(notification['verificationData'], 'articleId') ??
      notifString(notification, 'relatedId');

  final stamp = stampUrl?.trim();
  final signature = signatureUrl?.trim();
  final docsOnly = documents
      .where((u) => u.trim().isNotEmpty && u != stamp && u != signature)
      .toList();

  return buildVerificationDocumentCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLogo)
          Row(
            children: [
              Image.asset('assets/images/logo_tramoo.png', height: 36),
              const Spacer(),
              if (dateLabel.isNotEmpty)
                Text(dateLabel,
                    style: const TextStyle(fontSize: 11, color: kVerifyTextMuted)),
            ],
          ),
        if (showLogo) const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: kVerifyText,
          ),
        ),
        if (articleId != null) ...[
          const SizedBox(height: 4),
          Text(
            l10n.refWithId(articleId),
            style: const TextStyle(fontSize: 12, color: kVerifyTextMuted),
          ),
        ],
        if (details != null) ...[
          const SizedBox(height: 6),
          Text(details,
              style: const TextStyle(fontSize: 13, color: kVerifyTextMuted)),
        ],
        const SizedBox(height: 10),
        buildVerificationHtmlBody(bodyHtml),
        if (images.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            l10n.attachedImages,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kVerifyText,
            ),
          ),
          const SizedBox(height: 6),
          ...images.asMap().entries.map((e) {
            final label = _fileLabel(
              e.value,
              l10n.imageWithIndex(e.key + 1),
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _compactAttachmentTile(
                context: context,
                icon: Icons.image_outlined,
                title: label,
                onTap: () => showVerificationImagePreview(
                  context,
                  url: e.value,
                  title: label,
                ),
              ),
            );
          }),
        ],
        if (docsOnly.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            l10n.attachedDocuments,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kVerifyText,
            ),
          ),
          const SizedBox(height: 6),
          ...docsOnly.asMap().entries.map((e) {
            final label = _fileLabel(
              e.value,
              l10n.documentWithIndex(e.key + 1),
            );
            final isPdf = label.toLowerCase().endsWith('.pdf');
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _compactAttachmentTile(
                context: context,
                icon: isPdf ? Icons.picture_as_pdf_outlined : Icons.insert_drive_file_outlined,
                title: label,
                onTap: () => openRemoteAttachment(context, e.value, label: label),
              ),
            );
          }),
        ],
        if (stamp != null || signature != null) ...[
          const SizedBox(height: 14),
          Text(
            l10n.stampAndSignature,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kVerifyText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (stamp != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: TranooNetworkImage(
                    url: stamp,
                    height: 48,
                    width: 48,
                    fit: BoxFit.contain,
                    cloudinaryWidthPx: cloudinaryWidthPx(
                      context,
                      logicalWidth: 48,
                    ),
                  ),
                ),
              if (signature != null)
                TranooNetworkImage(
                  url: signature,
                  height: 36,
                  fit: BoxFit.contain,
                  cloudinaryWidthPx: cloudinaryWidthPx(
                    context,
                    logicalWidth: 36,
                  ),
                ),
            ],
          ),
        ],
        if (status == 'pending' && onApprove != null && onReject != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kVerifyText,
                    side: const BorderSide(color: kVerifyYellowBorder),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(l10n.reject),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kVerifyYellow,
                    foregroundColor: kVerifyText,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    l10n.validate,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
        if (pdfUrl != null && pdfUrl.isNotEmpty) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => openRemoteAttachment(
              context,
              pdfUrl,
              label: 'rapport-verification-tranoo.pdf',
            ),
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
            label: Text(l10n.downloadReportPdf),
            style: OutlinedButton.styleFrom(
              foregroundColor: kVerifyText,
              side: const BorderSide(color: kVerifyYellow),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ],
    ),
  );
}

Widget buildVerificationDocumentCard({required Widget child}) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: kVerifyYellowBorder),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: child,
    ),
  );
}

/// Corps HTML sans images inline (pièces jointes en tuiles séparées).
Widget buildVerificationHtmlBody(String bodyHtml) {
  if (bodyHtml.isEmpty || bodyHtml == '-') {
    return const SizedBox.shrink();
  }
  return Html(
    data: bodyHtml,
    style: {
      'body': Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        fontSize: FontSize(14),
        lineHeight: const LineHeight(1.45),
        color: kVerifyText,
      ),
      'h2': Style(
        fontSize: FontSize(16),
        fontWeight: FontWeight.w600,
        color: kVerifyText,
        margin: Margins.only(bottom: 6),
      ),
      'p': Style(margin: Margins.only(bottom: 6)),
      'img': Style(display: Display.none),
      'table': Style(width: Width(100, Unit.percent)),
    },
  );
}

/// AppBar + fond écran vérification.
PreferredSizeWidget buildVerificationAppBar(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return AppBar(
    backgroundColor: kVerifyYellowSoft,
    foregroundColor: kVerifyText,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    title: Text(
      l10n.verificationAction,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 17,
        color: kVerifyText,
      ),
    ),
  );
}
