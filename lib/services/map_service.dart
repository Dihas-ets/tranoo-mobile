import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Service pour gérer les fonctionnalités de cartographie
class MapService {
  
  /// Système de mapping utilisé
  /// 
  /// **OpenStreetMap (OSM)** - Recommandé pour cette application
  /// - ✅ Gratuit et open source
  /// - ✅ Pas de clé API requise
  /// - �️ Couverture mondiale complète
  /// - �️ Mises à jour communautaires
  /// - ✅ Idéal pour le suivi en temps réel
  /// 
  /// **Google Maps** - Alternative (nécessite clé API)
  /// - ❌ Nécessite clé API facturante
  /// - �️ Limites d'utilisation
  /// - �️ Très précis
  /// - �️ Traffic en temps réel
  /// 
  /// **MapBox** - Alternative premium
  /// - �️ Nécessite clé API
  /// - �️ Très personnalisable
  /// - �️ Bonne performance
  static const MapProvider mapProvider = MapProvider.openStreetMap;
  
  /// Configuration des tuiles de carte selon le provider
  static String getTileUrl() {
    switch (mapProvider) {
      case MapProvider.openStreetMap:
        return 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
      case MapProvider.googleMaps:
        return 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}';
      case MapProvider.mapBox:
        return 'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token=YOUR_TOKEN';
      default:
        return 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }
  
  /// Sous-domaines pour répartir la charge (OSM)
  static List<String> getTileSubdomains() {
    switch (mapProvider) {
      case MapProvider.openStreetMap:
        return ['a', 'b', 'c'];
      case MapProvider.googleMaps:
        return ['mt1', 'mt2', 'mt3'];
      case MapProvider.mapBox:
        return ['a', 'b', 'c', 'd'];
      default:
        return ['a', 'b', 'c'];
    }
  }
  
  /// Configuration d'attribution pour respecter les licences
  static String getAttribution() {
    switch (mapProvider) {
      case MapProvider.openStreetMap:
        return '© OpenStreetMap contributors';
      case MapProvider.googleMaps:
        return '© Google Maps';
      case MapProvider.mapBox:
        return '© MapBox';
      default:
        return '© OpenStreetMap contributors';
    }
  }
  
  /// Configuration maximale du zoom selon le provider
  static double getMaxZoom() {
    switch (mapProvider) {
      case MapProvider.openStreetMap:
        return 19.0;
      case MapProvider.googleMaps:
        return 20.0;
      case MapProvider.mapBox:
        return 22.0;
      default:
        return 19.0;
    }
  }
  
  /// Couleurs pour les différents éléments de la carte
  static class MapColors {
    static const Color routeColor = Color(0xFF4CAF50); // Vert
    static const Color driverColor = Color(0xFFFFD700); // Jaune/or
    static const Color restaurantColor = Color(0xFFF44336); // Rouge
    static const Color destinationColor = Color(0xFF2196F3); // Bleu
    static const Color checkpointColor = Color(0xFFFF9800); // Orange
  }
  
  /// Icônes pour les marqueurs
  static class MapIcons {
    static const IconData restaurant = Icons.store;
    static const IconData destination = Icons.home;
    static const IconData driver = Icons.motorcycle;
    static const IconData checkpoint = Icons.location_on;
  }
  
  /// Calcul de distance entre deux points (en km)
  static double calculateDistance(LatLng point1, LatLng point2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, point1, point2);
  }
  
  /// Génération de points intermédiaires pour une route réaliste
  static List<LatLng> generateRoutePoints(LatLng start, LatLng end, {int segments = 5}) {
    final List<LatLng> points = [start];
    
    for (int i = 1; i < segments; i++) {
      final double ratio = i / segments;
      final double lat = start.latitude + (end.latitude - start.latitude) * ratio;
      final double lng = start.longitude + (end.longitude - start.longitude) * ratio;
      points.add(LatLng(lat, lng));
    }
    
    points.add(end);
    return points;
  }
  
  /// Animation de mouvement entre deux points
  static LatLng interpolatePosition(LatLng start, LatLng end, double progress) {
    return LatLng(
      start.latitude + (end.latitude - start.latitude) * progress,
      start.longitude + (end.longitude - start.longitude) * progress,
    );
  }
}

enum MapProvider {
  openStreetMap,
  googleMaps,
  mapBox,
}
