import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tranoo/config/backend_config.dart';
import 'package:tranoo/utils/auth_dialog.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter/rendering.dart';
import 'package:tranoo/l10n/app_localizations.dart';

void _showInvoiceToast(
  BuildContext context, {
  required String message,
  required bool success,
}) {
  final color = success ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
  final icon = success ? Icons.check_circle : Icons.error;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: color,
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}

class MesFacturesPage extends StatefulWidget {
  const MesFacturesPage({super.key});

  @override
  State<MesFacturesPage> createState() => _MesFacturesPageState();
}

class _MesFacturesPageState extends State<MesFacturesPage> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  final Color primaryColor = const Color(0xFFF8BF13);
  List<Map<String, String>> factures = [];
  bool _isLoading = true;
  String? _loadError;
  int _unreadCount = 0;

  int selectedTab = 1; // 0 = pending, 1 = completed, 2 = canceled
  DateTime? selectedDate;
  String selectedFilter = 'all';
  bool _authDialogShown = false;

  @override
  void initState() {
    super.initState();
    _loadFactures();
  }

  String _formatAmount(dynamic value) {
    final amount = (value as num?)?.toDouble() ?? 0;
    return '${amount.toStringAsFixed(0)} FCFA';
  }

  String _formatDate(dynamic raw) {
    final dt = DateTime.tryParse(raw?.toString() ?? '');
    if (dt == null) return '--';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  List<Map<String, String>> _mapInvoicesToUi(
    List<Map<String, dynamic>> invoices,
    AppLocalizations l10n,
  ) {
    return invoices.map((inv) {
      final items = (inv['items'] as List?) ?? const [];
      final firstTitle = items.isNotEmpty
          ? (items.first as Map)['title']?.toString() ?? l10n.articleLabel
          : l10n.articleLabel;
      final subtotal = (inv['subtotal'] as num?)?.toDouble() ?? 0;
      final deliveryFee = (inv['deliveryFee'] as num?)?.toDouble() ?? 0;
      final total = (inv['total'] as num?)?.toDouble() ?? 0;
      return {
        "id": (inv['_id'] ?? '').toString(),
        "numero": (inv['invoiceNumber'] ?? '--').toString(),
        "date": _formatDate(inv['issueDate'] ?? inv['createdAt']),
        "produit": firstTitle,
        "montant": _formatAmount(total),
        "statut": (inv['paymentStatus'] == 'paid')
            ? l10n.paidStatus
            : l10n.pendingPaymentStatus,
        "vendeur": (inv['sellerName'] ?? l10n.sellerDefault).toString(),
        "boutique":
            (inv['shopName'] ?? inv['company'] ?? l10n.shopDefault).toString(),
        "entreprise": (inv['shopName'] ?? inv['company'] ?? 'Tranoo').toString(),
        "prixProduit": _formatAmount(subtotal),
        "livraison": _formatAmount(deliveryFee),
        "tva": "0% (0 FCFA)",
        "reference": (inv['reference'] ?? '--').toString(),
        "adresse": (inv['deliveryAddress'] ?? '--').toString(),
        "paiement": ((inv['paymentMethod'] ?? 'online').toString()),
        "isRead": ((inv['isRead'] == true) ? 'true' : 'false'),
      };
    }).toList();
  }

  Future<void> _loadFactures() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showAuthPopupIfNeeded();
        throw Exception('Utilisateur non connecté');
      }
      final token = await user.getIdToken();
      final dio = Dio(
        BaseOptions(
          baseUrl: getApiBaseUrl(),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      debugPrint('[FACTURES] BaseURL: ${getApiBaseUrl()}');
      debugPrint('[FACTURES] GET /invoices/my');
      final response = await dio.get('/invoices/my');
      debugPrint('[FACTURES] Status: ${response.statusCode}');
      debugPrint('[FACTURES] Body type: ${response.data.runtimeType}');
      final data = response.data;
      final invoices = (data is Map<String, dynamic> && data['invoices'] is List)
          ? List<Map<String, dynamic>>.from(
              (data['invoices'] as List).whereType<Map>(),
            )
          : <Map<String, dynamic>>[];
      final l10n = AppLocalizations.of(context)!;
      final mapped = _mapInvoicesToUi(invoices, l10n);
      if (!mounted) return;
      setState(() {
        factures = mapped;
        _unreadCount = (data is Map<String, dynamic>)
            ? ((data['unreadCount'] as num?)?.toInt() ?? 0)
            : 0;
      });
    } catch (e) {
      debugPrint('[FACTURES] Exception: $e');
      if (!mounted) return;
      setState(() {
        if (e is DioException) {
          final status = e.response?.statusCode;
          debugPrint('[FACTURES] DioException status: $status');
          debugPrint('[FACTURES] DioException body: ${e.response?.data}');
          final code = (e.response?.data is Map<String, dynamic>)
              ? e.response?.data['code']?.toString()
              : null;
          if (status == 401 &&
              (code == 'USER_NOT_FOUND' || FirebaseAuth.instance.currentUser == null)) {
            _showAuthPopupIfNeeded();
          }
          if (status == 404) {
            factures = [];
            _unreadCount = 0;
            _loadError = null;
            return;
          }
          final message = (e.response?.data is Map<String, dynamic>)
              ? (e.response?.data['message']?.toString() ?? '')
              : '';
          final l10n = AppLocalizations.of(context)!;
          _loadError = message.isNotEmpty
              ? l10n.invoicesLoadErrorDetail(
                  '${status ?? ''}', message)
              : l10n.invoicesLoadError;
        } else {
          _loadError = AppLocalizations.of(context)!.invoicesLoadError;
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAuthPopupIfNeeded() {
    if (_authDialogShown || !mounted) return;
    _authDialogShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showAuthDialog(
        context,
        message: AppLocalizations.of(context)!.signInForInvoices,
      );
    });
  }

  Future<Dio> _authorizedDio() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');
    final token = await user.getIdToken();
    return Dio(
      BaseOptions(
        baseUrl: getApiBaseUrl(),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Future<void> _markInvoiceAsRead(String? invoiceId) async {
    if (invoiceId == null || invoiceId.isEmpty) return;
    try {
      final dio = await _authorizedDio();
      await dio.patch('/invoices/$invoiceId/read');
    } catch (_) {}
  }

  Future<void> _markAllInvoicesAsRead() async {
    try {
      final dio = await _authorizedDio();
      await dio.patch('/invoices/my/read-all');
      if (!mounted) return;
      setState(() {
        for (final f in factures) {
          f['isRead'] = 'true';
        }
        _unreadCount = 0;
      });
    } catch (_) {}
  }

  String _dateFilterLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'today':
        return l10n.filterToday;
      case 'week':
        return l10n.filterThisWeek;
      case 'month':
        return l10n.filterThisMonth;
      case 'custom':
        return l10n.filterCustom;
      default:
        return l10n.filterAllDates;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false, // Pas de flèche back
        title: Center(
          child: Text(
            l10n.myInvoices,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '$_unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: l10n.markAllRead,
            onPressed: _unreadCount > 0 ? _markAllInvoicesAsRead : null,
            icon: const Icon(Icons.done_all, color: Colors.black),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// 📅 FILTRES DE DATE
            _buildDateFilters(),

            const SizedBox(height: 20),

            /// 📄 LISTE FACTURES
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _loadError != null
                      ? Center(child: Text(_loadError!))
                      : factures.isEmpty
                          ? Center(
                              child: Text(
                                l10n.noInvoicesYet,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                      : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: factures.length,
                itemBuilder: (context, index) {
                  final f = factures[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      _markInvoiceAsRead(f["id"]);
                      f["isRead"] = 'true';
                      if (_unreadCount > 0) {
                        setState(() => _unreadCount -= 1);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InvoicePreviewPage(
                            facture: f,
                            accentColor: primaryColor,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          /// ICON
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.receipt_long,
                              color: primaryColor,
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// INFOS
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  f["numero"] ?? "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${f["date"]} • ${f["produit"]}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if ((f["isRead"] ?? 'true') == 'false')
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      l10n.unreadLabel,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                Text(
                                  f["montant"] ?? "",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// BTN TELECHARGER
                          ElevatedButton(
                            onPressed: () {
                              _showDownloadOptionsFromList(f);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              l10n.download,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 TAB BUTTON
  Widget _buildTab(String text, int index) {
    final isSelected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => selectedTab = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 📅 FILTRES DE DATE
  Widget _buildDateFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.filterByDate,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['all', 'today', 'week', 'month', 'custom'].map((filter) {
                final l10n = AppLocalizations.of(context)!;
                final isSelected = filter == selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (filter == 'custom')
                          Icon(Icons.calendar_today, size: 14, color: isSelected ? Colors.white : primaryColor),
                        if (filter == 'custom') const SizedBox(width: 4),
                        Text(
                          _dateFilterLabel(l10n, filter),
                          style: TextStyle(
                            color: isSelected ? Colors.white : primaryColor,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = filter;
                        if (filter == 'custom') {
                          _selectCustomDate();
                        }
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: primaryColor,
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (selectedDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 14,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.selectedDateLabel(
                      '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 📅 SÉLECTION DE DATE PERSONNALISÉE
  Future<void> _selectCustomDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            colorScheme: ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// ⚙️ OPTIONS TELECHARGEMENT
  void _showDownloadOptionsFromList(Map<String, String> facture) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.downloadInvoice),
          content: Text(l10n.chooseFormat),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _downloadInvoiceAsImage(facture);
              },
              child: Text(l10n.imageFormat),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _downloadInvoiceAsPDF(facture);
              },
              child: Text(l10n.documentFormat),
            ),
          ],
        );
      },
    );
  }

  Future<Uint8List> _buildInvoiceImageBytes(
    Map<String, String> facture,
    AppLocalizations l10n,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const width = 1080.0;
    const height = 1350.0;
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), paint);

    final headerPaint = Paint()..color = const Color(0xFFF8BF13);
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, 160), headerPaint);
    final tp = TextPainter(textDirection: TextDirection.ltr);

    void draw(String text, double x, double y,
        {double size = 36, FontWeight w = FontWeight.w500, Color c = Colors.black}) {
      tp.text = TextSpan(
        text: text,
        style: TextStyle(fontSize: size, fontWeight: w, color: c),
      );
      tp.layout(maxWidth: width - 80);
      tp.paint(canvas, Offset(x, y));
    }

    draw(l10n.invoiceTitle(facture['numero'] ?? '--'), 40, 52,
        size: 42, w: FontWeight.bold);
    draw('${l10n.dateTimeLabel}: ${facture['date'] ?? '--'}', 40, 190);
    draw('${l10n.productLabel}: ${facture['produit'] ?? '--'}', 40, 260);
    draw('${l10n.sellerLabel}: ${facture['vendeur'] ?? '--'}', 40, 330);
    draw('${l10n.shopLabel}: ${facture['boutique'] ?? '--'}', 40, 400);
    draw('${l10n.addressLabel}: ${facture['adresse'] ?? '--'}', 40, 470,
        size: 30);
    draw('${l10n.subtotal}: ${facture['prixProduit'] ?? '--'}', 40, 560);
    draw('${l10n.deliveryLabelShort}: ${facture['livraison'] ?? '--'}', 40, 630);
    draw('${l10n.tvaLabel}: ${facture['tva'] ?? '--'}', 40, 700);
    draw('${l10n.totalLabelShort}: ${facture['montant'] ?? '--'}', 40, 790,
        size: 44, w: FontWeight.w800);
    draw('${l10n.referenceLabel}: ${facture['reference'] ?? '--'}', 40, 880,
        size: 28, c: Colors.black54);

    final image = await recorder.endRecording().toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _downloadInvoiceAsImage(Map<String, String> facture) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await _buildInvoiceImageBytes(facture, l10n);
      final path = await FilePicker.saveFile(
        dialogTitle: l10n.saveInvoiceImage,
        fileName:
            'facture_${facture["numero"] ?? DateTime.now().millisecondsSinceEpoch}.png',
        bytes: bytes,
      );
      if (path == null) return;
      if (mounted) {
        _showInvoiceToast(
          context,
          message: l10n.imageSavedSuccess,
          success: true,
        );
      }
    } catch (e) {
      if (mounted) {
        _showInvoiceToast(
          context,
          message: l10n.imageSaveFailed,
          success: false,
        );
      }
    }
  }

  Future<void> _downloadInvoiceAsPDF(Map<String, String> facture) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final imageBytes = await _buildInvoiceImageBytes(facture, l10n);
      final doc = pw.Document();
      final img = pw.MemoryImage(imageBytes);
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (_) => pw.Center(
            child: pw.Image(img, fit: pw.BoxFit.contain),
          ),
        ),
      );
      final bytes = await doc.save();
      final path = await FilePicker.saveFile(
        dialogTitle: l10n.saveInvoiceDocument,
        fileName:
            'facture_${facture["numero"] ?? DateTime.now().millisecondsSinceEpoch}.pdf',
        bytes: bytes,
      );
      if (path == null) return;
      if (mounted) {
        _showInvoiceToast(
          context,
          message: l10n.documentSavedSuccess,
          success: true,
        );
      }
    } catch (e) {
      if (mounted) {
        _showInvoiceToast(
          context,
          message: l10n.documentSaveFailed,
          success: false,
        );
      }
    }
  }
}

class InvoicePreviewPage extends StatefulWidget {
  final Map<String, String> facture;
  final Color accentColor;

  const InvoicePreviewPage({
    super.key,
    required this.facture,
    required this.accentColor,
  });

  @override
  State<InvoicePreviewPage> createState() => _InvoicePreviewPageState();
}

class _InvoicePreviewPageState extends State<InvoicePreviewPage> {
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  final GlobalKey _ticketCaptureKey = GlobalKey();

  Future<Uint8List> _captureTicketBytes() async {
    final boundary = _ticketCaptureKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    final l10n = AppLocalizations.of(context)!;
    if (boundary == null) {
      throw Exception(l10n.captureUnavailable);
    }
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception(l10n.cannotGenerateImage);
    }
    return byteData.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFF0B1022),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8BF13), // Jaune Tranoo
        elevation: 0,
        automaticallyImplyLeading: false, // Pas de flèche back
        centerTitle: true,
        title: Text(
          l10n.invoicePreview,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: _buildTicketPage(),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketPage() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        RepaintBoundary(
          key: _ticketCaptureKey,
          child: _buildTicketContent(),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _shareInvoice();
                },
                icon: const Icon(Icons.share_outlined),
                label: Text(l10n.share),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showDownloadOptions();
                },
                icon: const Icon(Icons.download_rounded),
                label: Text(l10n.download),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTicketContent() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Section entreprise
          _sectionCard(
            color: const Color(0xFFF8BF13), // Jaune Tranoo
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified, color: Colors.black, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      l10n.transactionSuccessTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: Colors.black),
                    ),
                    const Spacer(),
                    Text(
                      widget.facture["numero"] ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  (widget.facture["entreprise"] ?? "Tranoo").toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.transactionNumber(widget.facture['reference'] ?? '-'),
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Section produit
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row(l10n.dateTimeLabel, widget.facture['date'] ?? '-'),
                _row(l10n.productLabel, widget.facture['produit'] ?? '-'),
                _row(l10n.sellerLabel, widget.facture['vendeur'] ?? '-'),
                _row(l10n.shopLabel, widget.facture['boutique'] ?? '-'),
                _row(l10n.fundsSourceLabel, widget.facture['paiement'] ?? '-'),
                _row(l10n.destinationLabel, widget.facture['adresse'] ?? '-'),
                _row(l10n.referenceLabel, widget.facture['reference'] ?? '-'),
                
                // Exemple multi-produits (démo)
                if (widget.facture["numero"] == "FAC-2026-001") ...[
                  const SizedBox(height: 16),
                  const Divider(height: 20, thickness: 1),
                  const SizedBox(height: 8),
                  Text(
                    l10n.productDetails,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF0A1F44),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildProductItem('Toyota Land Cruiser 2022', '1', '800 000 FCFA'),
                  _buildProductItem('Kit de réparation complet', '2', '150 000 FCFA'),
                  _buildProductItem('Housses de protection', '1', '50 000 FCFA'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Section prix
          _sectionCard(
            child: Column(
              children: [
                _row(l10n.productPriceLabel, widget.facture['prixProduit'] ?? '-'),
                _row(l10n.deliveryPriceLabel, widget.facture['livraison'] ?? '-'),
                _row(l10n.tvaLabel, widget.facture['tva'] ?? '-'),
                const Divider(height: 24, thickness: 1),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.totalTransaction,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      widget.facture["montant"] ?? "-",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: widget.accentColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Pied de page
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child, Color? color}) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color ?? Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: child,
        ),
        Positioned(
          left: -7,
          top: 36,
          child: _cutCircle(),
        ),
        Positioned(
          right: -7,
          top: 36,
          child: _cutCircle(),
        ),
      ],
    );
  }

  Widget _cutCircle() {
    return Container(
      width: 14,
      height: 14,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F6FA),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _row(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              key,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour les items de produits (multi-produits)
  Widget _buildProductItem(String productName, String quantity, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              productName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              quantity,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              price,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Color(0xFF0A1F44),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Pied de page de la facture
  Widget _buildFooter() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          // Ligne de séparation
          Container(
            height: 1,
            color: Colors.black.withOpacity(0.1),
            margin: const EdgeInsets.only(bottom: 16),
          ),
          
          // Titre du support
          Text(
            l10n.tranooSupport,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A1F44),
            ),
          ),
          const SizedBox(height: 12),
          
          // Informations de contact
          const Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 8),
                  Text(
                    '+229 00 00 00 00',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 8),
                  Text(
                    'support@tranoo.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 8),
                  Text(
                    'Cotonou, Bénin',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Message de remerciement
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.thankYouForTrust,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0A1F44),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  '❤️',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Ligne de séparation inférieure
          Container(
            height: 1,
            color: Colors.black.withOpacity(0.1),
          ),
          
          const SizedBox(height: 12),
          
          // Message légal
          Text(
            l10n.officialInvoiceDisclaimer,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Fonction pour afficher les options de téléchargement
  void _showDownloadOptions() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.downloadInvoice),
          content: Text(l10n.chooseDownloadFormat),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _downloadInvoiceAsImage();
              },
              child: Text(l10n.imageGallery),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _downloadInvoiceAsPDF();
              },
              child: Text(l10n.documentFormat),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour partager la facture
  void _shareInvoice() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.share, color: Colors.white),
              const SizedBox(width: 8),
              Text(l10n.preparingShare),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );

      // Simuler la préparation du partage
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.invoiceReadyToShare),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                        AppLocalizations.of(context)!.shareError('$e'))),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _downloadInvoiceAsImage() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final bytes = await _captureTicketBytes();
      final path = await FilePicker.saveFile(
        dialogTitle: l10n.saveInvoiceImage,
        fileName:
            'facture_${widget.facture["numero"] ?? DateTime.now().millisecondsSinceEpoch}.png',
        bytes: bytes,
      );
      if (path == null) return;
      if (!mounted) return;
      _showInvoiceToast(
        context,
        message: l10n.imageSavedSuccess,
        success: true,
      );
    } catch (e) {
      if (mounted) {
        _showInvoiceToast(
          context,
          message: l10n.imageSaveFailed,
          success: false,
        );
      }
    }
  }

  // Fonction pour télécharger en PDF
  void _downloadInvoiceAsPDF() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final imageBytes = await _captureTicketBytes();
      final doc = pw.Document();
      final img = pw.MemoryImage(imageBytes);
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (_) => pw.Center(
            child: pw.Image(img, fit: pw.BoxFit.contain),
          ),
        ),
      );
      final bytes = await doc.save();
      final path = await FilePicker.saveFile(
        dialogTitle: l10n.saveInvoiceDocument,
        fileName:
            'facture_${widget.facture["numero"] ?? DateTime.now().millisecondsSinceEpoch}.pdf',
        bytes: bytes,
      );
      if (path == null) return;
      if (!mounted) return;
      _showInvoiceToast(
        context,
        message: l10n.documentSavedSuccess,
        success: true,
      );
    } catch (e) {
      if (mounted) {
        _showInvoiceToast(
          context,
          message: l10n.documentSaveFailed,
          success: false,
        );
      }
    }
  }
}
