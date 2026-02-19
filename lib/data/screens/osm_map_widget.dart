import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

/// Carte gratuite OpenStreetMap (Flutter Map) pour affichage + bouton "Naviguer"
/// vers Google Maps / Waze pour la navigation voix.
class OsmMapWidget extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final List<OsmMarkerData> markers;
  final List<LatLng>? polylinePoints;
  final VoidCallback? onTapMyLocation;
  final LatLng? navigateToDestination;

  const OsmMapWidget({
    super.key,
    required this.center,
    this.zoom = 14,
    this.markers = const [],
    this.polylinePoints,
    this.onTapMyLocation,
    this.navigateToDestination,
  });

  /// Ouvre Google Maps ou Waze pour la navigation vers [destination].
  /// [destination] ex: LatLng(14.716677, -17.467686)
  static Future<void> openNavigation(LatLng destination,
      {bool useWaze = false}) async {
    final lat = destination.latitude;
    final lng = destination.longitude;
    Uri uri;
    if (useWaze) {
      uri = Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=yes');
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
      );
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: zoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.tranoo.tranoo',
            ),
            if (polylinePoints != null && polylinePoints!.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: polylinePoints!,
                    color: Colors.blue,
                    strokeWidth: 4,
                  ),
                ],
              ),
            MarkerLayer(
              markers: markers
                  .map(
                    (m) => Marker(
                      point: m.point,
                      width: 40,
                      height: 40,
                      child: Icon(
                        m.iconData ?? Icons.place,
                        color: m.color ?? Colors.blue,
                        size: 40,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        if (onTapMyLocation != null)
          Positioned(
            right: 16,
            bottom: 100,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              child: IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: onTapMyLocation,
              ),
            ),
          ),
        if (navigateToDestination != null)
          Positioned(
            right: 16,
            bottom: 40,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              child: InkWell(
                onTap: () => openNavigation(navigateToDestination!),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Naviguer',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class OsmMarkerData {
  final LatLng point;
  final IconData? iconData;
  final Color? color;

  OsmMarkerData({required this.point, this.iconData, this.color});
}

/// Convertit les coordonnées [Position] (geolocator) en [LatLng] (latlong2).
LatLng positionToLatLng(Position p) => LatLng(p.latitude, p.longitude);

/// Crée un [LatLng] depuis un map (ex: lieuDepart / lieuDestination).
LatLng? latLngFromMap(Map<String, dynamic>? place) {
  if (place == null) return null;
  final lat = place['latitude'] as num?;
  final lng = place['longitude'] as num?;
  if (lat == null || lng == null) return null;
  return LatLng(lat.toDouble(), lng.toDouble());
}
