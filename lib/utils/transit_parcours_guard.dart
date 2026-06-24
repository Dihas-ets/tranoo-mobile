/// Vérifie que l'acheteur a renseigné le parcours avant de parcourir / choisir un transitaire.
class TransitParcoursGuard {
  static String? validateBrowse({
    required bool transitChecked,
    required bool consommationChecked,
    required String? paysDestination,
  }) {
    if (!transitChecked && !consommationChecked) {
      return 'Choisissez d\'abord un mode de livraison (En transit ou En consommation).';
    }
    if (paysDestination == null || paysDestination.trim().isEmpty) {
      return 'Indiquez le pays de destination avant de consulter les transitaires.';
    }
    return null;
  }

  static String? validateSelect({
    required bool transitChecked,
    required bool consommationChecked,
    required String? paysDestination,
  }) {
    return validateBrowse(
      transitChecked: transitChecked,
      consommationChecked: consommationChecked,
      paysDestination: paysDestination,
    );
  }
}
