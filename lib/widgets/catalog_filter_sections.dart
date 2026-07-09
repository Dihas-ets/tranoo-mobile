import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tranoo/l10n/app_localizations.dart';
import 'package:tranoo/utils/catalog_filter_options.dart';
import 'package:tranoo/widgets/catalog_filter_brand_logo.dart';
import 'package:tranoo/widgets/skeleton/app_skeleton.dart';

const Color _kFilterSelected = Color(0xFFF8BF13);
const Color _kFilterBg = Color(0xFFF9FAFB);
const Color _kFilterBorder = Color(0xFFE0E0E0);

const Map<String, String> _brandSvgHeaders = {
  'User-Agent': 'TranooApp/1.0 (Flutter; catalog filters)',
};

class CatalogFilterImage extends StatelessWidget {
  final CatalogFilterOption option;
  final double width;
  final double height;
  final bool isLocation;

  const CatalogFilterImage({
    super.key,
    required this.option,
    this.width = 36,
    this.height = 36,
    this.isLocation = false,
  });

  Widget _networkSvg(String svgUrl, double boxHeight) {
    return SizedBox(
      width: width,
      height: boxHeight,
      child: SvgPicture.network(
        svgUrl,
        fit: BoxFit.contain,
        headers: _brandSvgHeaders,
        placeholderBuilder: (_) => _letterFallback(),
        errorBuilder: (_, __, ___) => _letterFallback(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final boxHeight = isLocation ? height * 0.66 : height;
    final svgUrl = option.networkSvgUrl;

    if (!isLocation) {
      return CatalogFilterBrandLogo(
        normalizedKey: option.normalizedKey,
        label: option.label,
        networkSvgUrl: svgUrl,
        width: width,
        height: boxHeight,
      );
    }

    if (svgUrl != null && svgUrl.isNotEmpty) {
      return _networkSvg(svgUrl, boxHeight);
    }
    return _letterFallback();
  }

  Widget _letterFallback() {
    final letter =
        option.label.isNotEmpty ? option.label[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: width / 2,
      backgroundColor: Colors.grey.shade300,
      child: Text(
        letter,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}

class CatalogFilterHorizSkeleton extends StatelessWidget {
  final double itemWidth;
  final double height;
  final int count;

  const CatalogFilterHorizSkeleton({
    super.key,
    this.itemWidth = 70,
    this.height = 70,
    this.count = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: height + 16,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: count,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, __) => SkeletonBox(
            width: itemWidth,
            height: height,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class CatalogMarqueFilterGrid extends StatelessWidget {
  final List<CatalogFilterOption> options;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final bool highlightSelection;

  const CatalogMarqueFilterGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.highlightSelection = true,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 86,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: options.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final item = options[index];
            final isSelected = selected != null &&
                normalizeCatalogKey(selected!) == item.normalizedKey;
            return GestureDetector(
              onTap: () => onSelected(isSelected ? null : item.label),
              child: Container(
                width: 70,
                decoration: BoxDecoration(
                  color: highlightSelection && isSelected
                      ? _kFilterSelected
                      : _kFilterBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: highlightSelection && isSelected
                        ? _kFilterSelected
                        : _kFilterBorder,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CatalogFilterImage(option: item),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: highlightSelection && isSelected
                            ? Colors.black
                            : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
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

IconData _pieceTypeIcon(String normalizedKey) {
  switch (normalizedKey) {
    case 'pneus':
      return Icons.trip_origin;
    case 'huiles_lubrifiants':
      return Icons.water_drop_outlined;
    case 'batteries':
      return Icons.battery_charging_full_outlined;
    case 'accessoires':
      return Icons.shopping_bag_outlined;
    default:
      return Icons.build_circle_outlined;
  }
}

class CatalogPieceTypeFilterGrid extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;
  final bool highlightSelection;

  const CatalogPieceTypeFilterGrid({
    super.key,
    required this.selected,
    required this.onSelected,
    this.highlightSelection = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 86,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: kPieceTypeFilters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final item = kPieceTypeFilters[index];
            final isSelected =
                selected != null && selected == item.normalizedKey;
            return GestureDetector(
              onTap: () =>
                  onSelected(isSelected ? null : item.normalizedKey),
              child: Container(
                width: 76,
                decoration: BoxDecoration(
                  color: highlightSelection && isSelected
                      ? _kFilterSelected
                      : _kFilterBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: highlightSelection && isSelected
                        ? _kFilterSelected
                        : _kFilterBorder,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _pieceTypeIcon(item.normalizedKey),
                      size: 26,
                      color: highlightSelection && isSelected
                          ? Colors.black
                          : Colors.black87,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pieceTypeFilterLabel(l10n, item.normalizedKey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                        color: highlightSelection && isSelected
                            ? Colors.black
                            : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
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

class CatalogModeleFilterGrid extends StatelessWidget {
  final List<String> modeles;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final bool highlightSelection;

  const CatalogModeleFilterGrid({
    super.key,
    required this.modeles,
    required this.selected,
    required this.onSelected,
    this.highlightSelection = true,
  });

  @override
  Widget build(BuildContext context) {
    if (modeles.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 76,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: modeles.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final name = modeles[index];
            final isSelected = selected != null &&
                normalizeCatalogKey(selected!) == normalizeCatalogKey(name);
            return GestureDetector(
              onTap: () => onSelected(isSelected ? null : name),
              child: Container(
                width: 88,
                decoration: BoxDecoration(
                  color: highlightSelection && isSelected
                      ? _kFilterSelected
                      : _kFilterBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: highlightSelection && isSelected
                        ? _kFilterSelected
                        : _kFilterBorder,
                  ),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: highlightSelection && isSelected
                        ? Colors.black
                        : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CatalogLocationFilterGrid extends StatelessWidget {
  final List<CatalogFilterOption> options;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final bool highlightSelection;

  const CatalogLocationFilterGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.highlightSelection = true,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 86,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: options.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final item = options[index];
            final isSelected = selected != null &&
                normalizeCatalogKey(selected!) == item.normalizedKey;
            return GestureDetector(
              onTap: () => onSelected(isSelected ? null : item.label),
              child: Container(
                width: 70,
                decoration: BoxDecoration(
                  color: highlightSelection && isSelected
                      ? _kFilterSelected
                      : _kFilterBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: highlightSelection && isSelected
                        ? _kFilterSelected
                        : _kFilterBorder,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CatalogFilterImage(
                      option: item,
                      isLocation: true,
                      width: 28,
                      height: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: highlightSelection && isSelected
                            ? Colors.black
                            : Colors.black87,
                      ),
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

/// Filtre budget affiché directement dans l'onglet (slider + champs placeholder).
class CatalogBudgetFilterPanel extends StatefulWidget {
  final List<dynamic> articles;
  final double? budgetMin;
  final double? budgetMax;
  final String Function(int count) countLabel;
  final void Function(double? min, double? max) onApply;
  final VoidCallback onReset;

  const CatalogBudgetFilterPanel({
    super.key,
    required this.articles,
    required this.budgetMin,
    required this.budgetMax,
    required this.countLabel,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<CatalogBudgetFilterPanel> createState() =>
      _CatalogBudgetFilterPanelState();
}

class _CatalogBudgetFilterPanelState extends State<CatalogBudgetFilterPanel> {
  late double _minPrice;
  late double _maxPrice;
  late double _currentMin;
  late double _currentMax;
  late TextEditingController _minCtl;
  late TextEditingController _maxCtl;

  @override
  void initState() {
    super.initState();
    _initRange();
  }

  void _initRange({bool recreateControllers = true}) {
    final prixList = <double>[];
    for (final raw in widget.articles) {
      double? p;
      if (raw is Map) {
        p = parseArticlePrice(raw['prix']);
      } else {
        try {
          p = parseArticlePrice((raw as dynamic).prix);
        } catch (_) {}
      }
      if (p != null) prixList.add(p);
    }
    prixList.sort();
    _minPrice = prixList.isNotEmpty ? prixList.first : 0;
    _maxPrice = prixList.isNotEmpty ? prixList.last : 20000000;
    _currentMin = widget.budgetMin ?? _minPrice;
    _currentMax = widget.budgetMax ?? _maxPrice;
    if (_currentMin < _minPrice) _currentMin = _minPrice;
    if (_currentMax > _maxPrice) _currentMax = _maxPrice;
    if (_currentMin > _currentMax) _currentMin = _minPrice;
    if (recreateControllers) {
      _minCtl = TextEditingController(
        text: widget.budgetMin != null ? _currentMin.toStringAsFixed(0) : '',
      );
      _maxCtl = TextEditingController(
        text: widget.budgetMax != null ? _currentMax.toStringAsFixed(0) : '',
      );
    }
  }

  @override
  void dispose() {
    _minCtl.dispose();
    _maxCtl.dispose();
    super.dispose();
  }

  int _countInRange(double a, double b) {
    return widget.articles.where((raw) {
      double? p;
      if (raw is Map) {
        p = parseArticlePrice(raw['prix']);
      } else {
        try {
          p = parseArticlePrice((raw as dynamic).prix);
        } catch (_) {}
      }
      if (p == null) return false;
      return p >= a && p <= b;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hintStyle = TextStyle(color: Colors.grey.shade500, fontSize: 14);
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );
    final disponibles = _countInRange(_currentMin, _currentMax);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.priceFcfa,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minCtl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.minLabel,
                    hintText: l10n.budgetMinHint,
                    hintStyle: hintStyle,
                    border: fieldBorder,
                    enabledBorder: fieldBorder,
                  ),
                  onChanged: (val) {
                    final v = double.tryParse(val);
                    if (v == null) return;
                    setState(() {
                      _currentMin = v.clamp(_minPrice, _currentMax);
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _maxCtl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.maxLabel,
                    hintText: l10n.budgetMaxHint,
                    hintStyle: hintStyle,
                    border: fieldBorder,
                    enabledBorder: fieldBorder,
                  ),
                  onChanged: (val) {
                    final v = double.tryParse(val);
                    if (v == null) return;
                    setState(() {
                      _currentMax = v.clamp(_currentMin, _maxPrice);
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: RangeValues(_currentMin, _currentMax),
            min: _minPrice,
            max: _maxPrice,
            activeColor: _kFilterSelected,
            onChanged: (values) {
              setState(() {
                _currentMin = values.start;
                _currentMax = values.end;
                if (_minCtl.text.isNotEmpty) {
                  _minCtl.text = _currentMin.toStringAsFixed(0);
                }
                if (_maxCtl.text.isNotEmpty) {
                  _maxCtl.text = _currentMax.toStringAsFixed(0);
                }
              });
            },
          ),
          Text(widget.countLabel(disponibles)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onReset();
                    setState(() {
                      _currentMin = _minPrice;
                      _currentMax = _maxPrice;
                      _minCtl.clear();
                      _maxCtl.clear();
                    });
                  },
                  child: Text(l10n.reset),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kFilterSelected,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    widget.onApply(_currentMin, _currentMax);
                    _minCtl.text = _currentMin.toStringAsFixed(0);
                    _maxCtl.text = _currentMax.toStringAsFixed(0);
                  },
                  child: Text(l10n.apply),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> showCatalogBudgetBottomSheet({
  required BuildContext context,
  required List<dynamic> articles,
  required double? budgetMin,
  required double? budgetMax,
  required String Function(int count) countLabel,
  required void Function(double? min, double? max) onApply,
  required VoidCallback onReset,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final prixList = <double>[];
  for (final raw in articles) {
    double? p;
    if (raw is Map) {
      p = parseArticlePrice(raw['prix']);
    } else {
      try {
        p = parseArticlePrice((raw as dynamic).prix);
      } catch (_) {}
    }
    if (p != null) prixList.add(p);
  }
  prixList.sort();

  final double minPrice = prixList.isNotEmpty ? prixList.first : 0;
  final double maxPrice = prixList.isNotEmpty ? prixList.last : 20000000;
  double currentMin = budgetMin ?? minPrice;
  double currentMax = budgetMax ?? maxPrice;
  if (currentMin < minPrice) currentMin = minPrice;
  if (currentMax > maxPrice) currentMax = maxPrice;
  if (currentMin > currentMax) currentMin = minPrice;

  final minCtl = TextEditingController(text: currentMin.toStringAsFixed(0));
  final maxCtl = TextEditingController(text: currentMax.toStringAsFixed(0));

  int countInRange(double a, double b) {
    return articles.where((raw) {
      double? p;
      if (raw is Map) {
        p = parseArticlePrice(raw['prix']);
      } else {
        try {
          p = parseArticlePrice((raw as dynamic).prix);
        } catch (_) {}
      }
      if (p == null) return false;
      return p >= a && p <= b;
    }).length;
  }

  final hintStyle = TextStyle(color: Colors.grey.shade500, fontSize: 14);
  final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: Colors.grey.shade300),
  );

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          final disponibles = countInRange(currentMin, currentMax);
          return SafeArea(
            top: false,
            child: Padding(
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
                  Text(
                    l10n.priceFcfa,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minCtl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.minLabel,
                            hintText: l10n.budgetMinHint,
                            hintStyle: hintStyle,
                            border: fieldBorder,
                            enabledBorder: fieldBorder,
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
                            labelText: l10n.maxLabel,
                            hintText: l10n.budgetMaxHint,
                            hintStyle: hintStyle,
                            border: fieldBorder,
                            enabledBorder: fieldBorder,
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
                    activeColor: _kFilterSelected,
                    onChanged: (values) {
                      setModalState(() {
                        currentMin = values.start;
                        currentMax = values.end;
                        minCtl.text = currentMin.toStringAsFixed(0);
                        maxCtl.text = currentMax.toStringAsFixed(0);
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(countLabel(disponibles)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            onReset();
                            Navigator.pop(sheetContext);
                          },
                          child: Text(l10n.reset),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kFilterSelected,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            onApply(currentMin, currentMax);
                            Navigator.pop(sheetContext);
                          },
                          child: Text(l10n.apply),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
