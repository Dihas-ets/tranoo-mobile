import 'package:flutter/material.dart';

/// Champ de recherche des listes catalogue (voitures / motos / pièces).
class CatalogListSearchField extends StatelessWidget {
  const CatalogListSearchField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

/// Onglet filtre style pastille (listes catalogue).
class CatalogFilterTabButton extends StatelessWidget {
  const CatalogFilterTabButton({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.isWide = false,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;
  final bool isWide;

  static const selectedColor = Color(0xFFF8BF13);
  static const unselectedBorderColor = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isWide ? 100 : 70,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.transparent,
          border: Border.all(
            color: selected ? selectedColor : unselectedBorderColor,
            width: 0.8,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

/// Rangée TabBar des filtres catalogue (sans indicateur Material).
class CatalogFilterTabBar extends StatelessWidget {
  const CatalogFilterTabBar({
    super.key,
    required this.controller,
    required this.tabs,
  });

  final TabController controller;
  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          indicator: const BoxDecoration(),
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          tabs: tabs,
        ),
      ),
    );
  }
}
