import 'package:flutter/material.dart';

/// Chips de filtres (Marque / Motos / Localisation / Budget / Stats).
class MarqueFilterTabRow extends StatelessWidget {
  const MarqueFilterTabRow({
    super.key,
    required this.screenWidth,
    required this.selectedIndex,
    required this.isVendeur,
    required this.isMotoSeller,
    required this.marqueTabIndex,
    required this.modeleTabIndex,
    required this.statistiquesTabIndex,
    required this.localisationTabIndex,
    required this.budgetTabIndex,
    required this.onTabSelected,
  });

  final double screenWidth;
  final int selectedIndex;
  final bool isVendeur;
  final bool isMotoSeller;
  final int marqueTabIndex;
  final int modeleTabIndex;
  final int statistiquesTabIndex;
  final int localisationTabIndex;
  final int budgetTabIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    void addChip(String title, int index, {bool wide = false}) {
      const selectedColor = Color(0xFFF8BF13);
      const unselectedBorderColor = Color(0xFF000000);
      final isSelected = selectedIndex == index;
      chips.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: GestureDetector(
            onTap: () => onTabSelected(index),
            child: Container(
              height: 40,
              width: wide ? 100 : 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? selectedColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? selectedColor : unselectedBorderColor,
                  width: 0.8,
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (isMotoSeller || isVendeur) {
      addChip('Marque', marqueTabIndex);
      addChip('Statistiques', statistiquesTabIndex, wide: true);
    } else {
      addChip('Marque', marqueTabIndex);
      addChip('Motos', modeleTabIndex);
      addChip('Localisation', localisationTabIndex, wide: true);
      addChip('Budget', budgetTabIndex, wide: true);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.02),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      ),
    );
  }
}

/// Grille horizontale des zones (filtre localisation).
class MarqueLocalisationSection extends StatelessWidget {
  const MarqueLocalisationSection({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String? selected;
  final ValueChanged<String> onSelected;

  static const _zones = <Map<String, String>>[
    {"name": "Bénin", "image": "assets/images/benin.png"},
    {"name": "Mali", "image": "assets/images/mali.png"},
    {"name": "Niger", "image": "assets/images/niger.png"},
    {"name": "Burkina-Faso", "image": "assets/images/burkina.png"},
    {"name": "Côte d'Ivoire", "image": "assets/images/ci.webp"},
    {"name": "Sénégal", "image": "assets/images/senegal.png"},
    {"name": "Togo", "image": "assets/images/togo.webp"},
    {"name": "Ghana", "image": "assets/images/ghana.png"},
    {"name": "Nigéria", "image": "assets/images/nigeria.png"},
    {"name": "Maroc", "image": "assets/images/maroc.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 106,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 120,
          ),
          itemCount: _zones.length,
          itemBuilder: (context, index) {
            final item = _zones[index];
            final name = item["name"]!;
            final isSelected = selected == name;
            return GestureDetector(
              onTap: () => onSelected(name),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFF8BF13)
                        : const Color(0xFFE0E0E0),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 36,
                      height: 24,
                      child: Image.asset(item["image"]!, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      name,
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Bouton d'ouverture du filtre budget.
class MarqueBudgetFilterButton extends StatelessWidget {
  const MarqueBudgetFilterButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF8BF13),
            foregroundColor: const Color(0xFF000000),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: onPressed,
          child: const Text('Filtrer par budget'),
        ),
      ),
    );
  }
}

/// Bottom sheet budget (min/max + compteur).
Future<void> showMarqueBudgetSheet({
  required BuildContext context,
  required List<double> onlinePrices,
  required double? initialMin,
  required double? initialMax,
  required void Function(double min, double max) onApply,
}) {
  final sorted = List<double>.from(onlinePrices)..sort();
  final double minPrice = sorted.isNotEmpty ? sorted.first : 0;
  final double maxPrice = sorted.isNotEmpty ? sorted.last : 200000;
  double currentMin = initialMin ?? minPrice;
  double currentMax = initialMax ?? maxPrice;

  final minCtl = TextEditingController(text: currentMin.toStringAsFixed(0));
  final maxCtl = TextEditingController(text: currentMax.toStringAsFixed(0));

  int countInRange(double a, double b) {
    return onlinePrices.where((p) => p >= a && p <= b).length;
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final disponibles = countInRange(currentMin, currentMax);
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              top: 8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Prix (FCFA)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: minCtl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Min.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (val) {
                          final v = double.tryParse(val) ?? currentMin;
                          setModalState(() {
                            currentMin = v.clamp(minPrice, currentMax);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: maxCtl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Max.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (val) {
                          final v = double.tryParse(val) ?? currentMax;
                          setModalState(() {
                            currentMax = v.clamp(currentMin, maxPrice);
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                RangeSlider(
                  values: RangeValues(currentMin, currentMax),
                  min: minPrice,
                  max: maxPrice,
                  onChanged: (values) {
                    setModalState(() {
                      currentMin = values.start;
                      currentMax = values.end;
                      minCtl.text = currentMin.toStringAsFixed(0);
                      maxCtl.text = currentMax.toStringAsFixed(0);
                    });
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setModalState(() {
                            currentMin = minPrice;
                            currentMax = maxPrice;
                            minCtl.text = currentMin.toStringAsFixed(0);
                            maxCtl.text = currentMax.toStringAsFixed(0);
                          });
                        },
                        child: const Text('Réinitialiser'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onApply(currentMin, currentMax);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF8BF13),
                          foregroundColor: const Color(0xFF000000),
                        ),
                        child: Text('Afficher $disponibles véhicule(s)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
