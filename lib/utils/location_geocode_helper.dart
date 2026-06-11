import 'package:dio/dio.dart';
import 'package:tranoo/services/user_service.dart';
import 'package:tranoo/utils/catalog_filter_options.dart';

class ResolvedLocation {
  final String localisation;
  final String lieu;
  final String pays;
  final String city;
  final bool geocoded;

  const ResolvedLocation({
    required this.localisation,
    required this.lieu,
    this.pays = '',
    this.city = '',
    this.geocoded = false,
  });
}

ResolvedLocation _fromLocal(String raw) {
  final trimmed = raw.trim();
  final known = knownCountryLabel(trimmed);
  if (known != null) {
    return ResolvedLocation(
      localisation: trimmed,
      lieu: known,
      pays: known,
    );
  }
  final parts = trimmed.split(RegExp(r'[,;/|]'));
  if (parts.length >= 2) {
    final countryPart = parts.last.trim();
    final knownCountry = knownCountryLabel(countryPart);
    if (knownCountry != null) {
      final city = parts.sublist(0, parts.length - 1).join(', ').trim();
      final display = city.isNotEmpty ? '$city, $knownCountry' : knownCountry;
      return ResolvedLocation(
        localisation: display,
        lieu: knownCountry,
        pays: knownCountry,
        city: city,
      );
    }
  }
  return ResolvedLocation(localisation: trimmed, lieu: trimmed);
}

Future<ResolvedLocation> resolveLocationInput(String input) async {
  final raw = input.trim();
  if (raw.isEmpty) {
    return const ResolvedLocation(localisation: '', lieu: '');
  }

  final local = _fromLocal(raw);
  if (knownCountryLabel(raw) != null ||
      (raw.contains(',') && local.pays.isNotEmpty)) {
    return local;
  }

  try {
    final dio = UserService().dio;
    final resp = await dio.post(
      '/geo/normalize',
      data: {'input': raw},
      options: Options(
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    final data = resp.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final loc = (map['localisation'] ?? raw).toString();
      final lieu = (map['lieu'] ?? loc).toString();
      return ResolvedLocation(
        localisation: loc,
        lieu: lieu,
        pays: (map['pays'] ?? map['country'] ?? '').toString(),
        city: (map['city'] ?? '').toString(),
        geocoded: map['geocoded'] == true,
      );
    }
  } catch (_) {}

  return local;
}
