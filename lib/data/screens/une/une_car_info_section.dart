import 'package:flutter/material.dart';
import 'package:tranoo/data/screens/une/une_labels.dart';
import 'package:tranoo/l10n/app_localizations.dart';

/// Champs véhicule/pièce pour une pub sponsorisée.
class UneCarInfoSection extends StatelessWidget {
  const UneCarInfoSection({
    super.key,
    required this.nameController,
    required this.yearController,
    required this.locationController,
    required this.priceController,
    required this.descriptionController,
    required this.companyController,
    required this.fuelTypes,
    required this.models,
    required this.types,
    required this.selectedFuelType,
    required this.selectedModel,
    required this.selectedType,
    required this.onFuelChanged,
    required this.onModelChanged,
    required this.onTypeChanged,
  });

  final TextEditingController nameController;
  final TextEditingController yearController;
  final TextEditingController locationController;
  final TextEditingController priceController;
  final TextEditingController descriptionController;
  final TextEditingController companyController;
  final List<String> fuelTypes;
  final List<String> models;
  final List<String> types;
  final String? selectedFuelType;
  final String? selectedModel;
  final String? selectedType;
  final ValueChanged<String?> onFuelChanged;
  final ValueChanged<String?> onModelChanged;
  final ValueChanged<String?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 40, thickness: 2),
        Text(
          l10n.carInfoSection,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: l10n.partOrCarName,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return l10n.enterName;
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: yearController,
          decoration: InputDecoration(
            labelText: l10n.year,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.enterYearValidator;
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: locationController,
          decoration: InputDecoration(
            labelText: l10n.defaultLocation,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.enterLocationValidator;
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: priceController,
          decoration: InputDecoration(
            labelText: l10n.price,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.enterPriceValidator;
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l10n.carDescription,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.enterDescriptionValidator;
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: companyController,
          decoration: InputDecoration(
            labelText: l10n.defaultCompanyName,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.enterCompanyValidator;
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          value: selectedFuelType,
          items: fuelTypes
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(UneLabels.fuel(l10n, type)),
                ),
              )
              .toList(),
          decoration: InputDecoration(
            labelText: l10n.engineType,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.selectEngineTypeValidator;
            }
            return null;
          },
          onChanged: onFuelChanged,
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          value: selectedModel,
          items: models
              .map((model) => DropdownMenuItem(value: model, child: Text(model)))
              .toList(),
          decoration: InputDecoration(
            labelText: l10n.model,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.selectModelValidator;
            }
            return null;
          },
          onChanged: onModelChanged,
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          value: selectedType,
          items: types
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(UneLabels.condition(l10n, type)),
                ),
              )
              .toList(),
          decoration: InputDecoration(
            labelText: l10n.typeLabel,
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null) return l10n.selectTypeValidator;
            return null;
          },
          onChanged: onTypeChanged,
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
