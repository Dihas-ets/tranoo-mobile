import 'package:flutter/material.dart';

/// Barre de recherche globale (accueil acheteur).
class MarqueSearchBar extends StatelessWidget {
  const MarqueSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onFilterPressed,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onFilterPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final hasTyped = controller.text.trim().isNotEmpty;
              return IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: hasTyped
                      ? Container(
                          key: const Key('filter_active'),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.filter_list,
                            color: Colors.white,
                            size: 20,
                          ),
                        )
                      : const Icon(
                          Icons.filter_list,
                          color: Colors.grey,
                          key: Key('filter_inactive'),
                        ),
                ),
                onPressed: onFilterPressed,
              );
            },
          ),
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
