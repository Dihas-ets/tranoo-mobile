import 'package:flutter/material.dart';

class MesFacturesPage extends StatefulWidget {
  const MesFacturesPage({super.key});

  @override
  State<MesFacturesPage> createState() => _MesFacturesPageState();
}

class _MesFacturesPageState extends State<MesFacturesPage> {
  final Color primaryColor = const Color(0xFFF8BF13);

  final List<Map<String, String>> factures = [
    {
      "numero": "FAC-2026-001",
      "date": "15 MAR 2026",
      "produit": "Toyota Land Cruiser 2022",
      "montant": "850 000 FCFA",
      "statut": "Payée",
      "vendeur": "Auto Plus Bénin",
      "boutique": "Auto Plus Store",
      "prixProduit": "800 000 FCFA",
      "livraison": "50 000 FCFA",
      "tva": "16% (128 000 FCFA)",
      "reference": "TRN-2026-03-001",
      "adresse": "Abomey-Calavi, Benin",
      "paiement": "Mobile Money"
    },
    {
      "numero": "FAC-2026-002",
      "date": "20 MAR 2026",
      "produit": "Kit de réparation moteur",
      "montant": "450 000 FCFA",
      "statut": "Payée",
      "vendeur": "Mécanique Express",
      "boutique": "Mécanique Pro",
      "prixProduit": "400 000 FCFA",
      "livraison": "50 000 FCFA",
      "tva": "18% (72 000 FCFA)",
      "reference": "TRN-2026-03-002",
      "adresse": "Cotonou, Benin",
      "paiement": "Carte Bancaire"
    },
    {
      "numero": "FAC-2026-003",
      "date": "25 MAR 2026",
      "produit": "Nissan Patrol 2023",
      "montant": "1 200 000 FCFA",
      "statut": "En attente",
      "vendeur": "Véhicules du Bénin",
      "boutique": "Auto Premium",
      "prixProduit": "1 150 000 FCFA",
      "livraison": "50 000 FCFA",
      "tva": "18% (207 000 FCFA)",
      "reference": "TRN-2026-03-003",
      "adresse": "Parakou, Benin",
      "paiement": "Espèces"
    },
    {
      "numero": "FAC-2026-004",
      "date": "30 MAR 2026",
      "produit": "Batterie automobile",
      "montant": "120 000 FCFA",
      "statut": "Payée",
      "vendeur": "Pièces Auto Market",
      "boutique": "Auto Parts Store",
      "prixProduit": "120 000 FCFA",
      "livraison": "0 FCFA",
      "tva": "18% (21 600 FCFA)",
      "reference": "TRN-2026-03-004",
      "adresse": "Porto-Novo, Benin",
      "paiement": "Carte Bancaire"
    },
  ];

  int selectedTab = 1; // 0 = pending, 1 = completed, 2 = canceled
  DateTime? selectedDate;
  String selectedFilter = 'Toutes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false, // Pas de flèche back
        title: const Center(
          child: Text(
            "Mes Factures",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: factures.length,
                itemBuilder: (context, index) {
                  final f = factures[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
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
                            child: const Text(
                              "Télécharger",
                              style: TextStyle(
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
          const Text(
            "Filtrer par date",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Toutes', 'Aujourd\'hui', 'Cette semaine', 'Ce mois', 'Personnalisée'].map((filter) {
                final isSelected = filter == selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (filter == 'Personnalisée')
                          Icon(Icons.calendar_today, size: 14, color: isSelected ? Colors.white : primaryColor),
                        if (filter == 'Personnalisée') const SizedBox(width: 4),
                        Text(
                          filter,
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
                        if (filter == 'Personnalisée') {
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
                    'Date sélectionnée: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Télécharger la facture'),
          content: const Text('Choisissez le format :'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _downloadInvoiceAsImage(facture);
              },
              child: const Text('Image'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _downloadInvoiceAsPDF(facture);
              },
              child: const Text('PDF'),
            ),
          ],
        );
      },
    );
  }

  void _downloadInvoiceAsImage(Map<String, String> facture) async {
    // Afficher un message stylisé
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.image,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Téléchargement en cours",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Génération de l'image...",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );

    // Simuler le téléchargement
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Message de succès stylisé
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Succès !",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Image sauvegardée dans la galerie",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _downloadInvoiceAsPDF(Map<String, String> facture) async {
    // Afficher un message stylisé
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Téléchargement en cours",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Génération du PDF...",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );

    // Simuler le téléchargement
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Message de succès stylisé
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Succès !",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "PDF sauvegardé dans Documents",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1022),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8BF13), // Jaune Tranoo
        elevation: 0,
        automaticallyImplyLeading: false, // Pas de flèche back
        centerTitle: true,
        title: const Text(
          'Aperçu facture',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: _buildTicket(),
          ),
        ),
      ),
    );
  }

  Widget _buildTicket() {
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
                    const Text(
                      'Transaction Success',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
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
                  "Transaction number ${widget.facture["reference"] ?? "-"}",
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
                _row('Date & time', widget.facture["date"] ?? "-"),
                _row('Produit', widget.facture["produit"] ?? "-"),
                _row('Vendeur', widget.facture["vendeur"] ?? "-"),
                _row('Boutique', widget.facture["boutique"] ?? "-"),
                _row('Source de fonds', widget.facture["paiement"] ?? "-"),
                _row('Destination', widget.facture["adresse"] ?? "-"),
                _row('Référence', widget.facture["reference"] ?? "-"),
                
                // Exemple multi-produits (démo)
                if (widget.facture["numero"] == "FAC-2026-001") ...[
                  const SizedBox(height: 16),
                  const Divider(height: 20, thickness: 1),
                  const SizedBox(height: 8),
                  const Text(
                    'Détails des produits:',
                    style: TextStyle(
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
                _row('Prix du produit', widget.facture["prixProduit"] ?? "-"),
                _row('Prix de livraison', widget.facture["livraison"] ?? "-"),
                _row('TVA', widget.facture["tva"] ?? "-"),
                const Divider(height: 24, thickness: 1),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total transaction',
                        style: TextStyle(fontWeight: FontWeight.w700),
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
          const SizedBox(height: 20),
          
          // Boutons d'action en bas
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _shareInvoice();
                  },
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Partager'),
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
                  label: const Text('Télécharger'),
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
          const Text(
            'Support Tranoo',
            style: TextStyle(
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
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Merci pour votre confiance ',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF0A1F44),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
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
          const Text(
            'Cette facture est un document officiel. En cas de litige, veuillez contacter notre support.',
            style: TextStyle(
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Télécharger la facture'),
          content: const Text('Choisissez le format de téléchargement:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _downloadInvoiceAsImage();
              },
              child: const Text('Image (Galerie)'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _downloadInvoiceAsPDF();
              },
              child: const Text('Document (PDF)'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour partager la facture
  void _shareInvoice() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.share, color: Colors.white),
              SizedBox(width: 8),
              Text('Préparation du partage...'),
            ],
          ),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );

      // Simuler la préparation du partage
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Facture prête à partager !'),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 3),
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
                Expanded(child: Text('Erreur lors du partage: ${e.toString()}')),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Fonction pour télécharger en image
  void _downloadInvoiceAsImage() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.image, color: Colors.white),
              SizedBox(width: 8),
              Text('Génération de l\'image en cours...'),
            ],
          ),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );

      // Simuler la génération de l'image
      await Future.delayed(const Duration(seconds: 2));

      // Simuler la sauvegarde dans la galerie
      // En réalité, vous utiliseriez un package comme 'screenshot' ou 'flutter_to_pdf'
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Image sauvegardée dans la galerie !'),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 3),
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
                Expanded(child: Text('Erreur: ${e.toString()}')),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Fonction pour télécharger en PDF
  void _downloadInvoiceAsPDF() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.white),
              SizedBox(width: 8),
              Text('Génération du PDF en cours...'),
            ],
          ),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );

      // Simuler la génération du PDF
      await Future.delayed(const Duration(seconds: 2));

      // Simuler la sauvegarde dans les documents locaux
      // En réalité, vous utiliseriez un package comme 'pdf' ou 'flutter_to_pdf'
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('PDF sauvegardé dans Documents !'),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 3),
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
                Expanded(child: Text('Erreur: ${e.toString()}')),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
