import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryMapArea extends StatelessWidget {
  final LatLng selectedLocation;
  final void Function(LatLng) onLocationChanged;
  final void Function(GoogleMapController) onMapCreated;

  const DeliveryMapArea({
    super.key,
    required this.selectedLocation,
    required this.onLocationChanged,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: selectedLocation, zoom: 15),
      onMapCreated: onMapCreated,
      onTap: onLocationChanged,
      markers: {
        Marker(
          markerId: const MarkerId('selected_pos'),
          position: selectedLocation,
          draggable: true,
          onDragEnd: onLocationChanged,
        )
      },
    );
  }
}
