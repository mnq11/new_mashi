import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideDetailsScreen extends StatefulWidget {
  final LatLng pickupLocation;
  final List<LatLng> destinationLocations;
  final double distance;
  final double price;
  final List<LatLng> polylineCoordinates;

  RideDetailsScreen({
    required this.pickupLocation,
    required this.destinationLocations,
    required this.distance,
    required this.price,
    required this.polylineCoordinates,
  });

  @override
  _RideDetailsScreenState createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _addMarkers();
    _addPolylines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Details'),
      ),
      body: Column(
        children: [
          Container(
            height: 400,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.pickupLocation,
                zoom: 12,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngBounds(
                    _calculateBounds(),
                    50,
                  ),
                );
              },
              markers: _markers,
              polylines: _polylines,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('Pickup Location: (${widget.pickupLocation.latitude}, ${widget.pickupLocation.longitude})'),
                ...widget.destinationLocations.map((dest) => Text('Destination: (${dest.latitude}, ${dest.longitude})')).toList(),
                Text('Distance: ${widget.distance.toStringAsFixed(2)} km'),
                Text('Price: \$${widget.price.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addMarkers() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('pickup'),
          position: widget.pickupLocation,
          infoWindow: InfoWindow(title: 'Pickup Location'),
        ),
      );
      for (int i = 0; i < widget.destinationLocations.length; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId('destination_$i'),
            position: widget.destinationLocations[i],
            infoWindow: InfoWindow(title: 'Destination ${i + 1}'),
          ),
        );
      }
    });
  }

  void _addPolylines() {
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          points: widget.polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }

  LatLngBounds _calculateBounds() {
    List<LatLng> allLocations = [widget.pickupLocation, ...widget.destinationLocations];
    double southWestLat = allLocations.map((e) => e.latitude).reduce((a, b) => a < b ? a : b);
    double southWestLng = allLocations.map((e) => e.longitude).reduce((a, b) => a < b ? a : b);
    double northEastLat = allLocations.map((e) => e.latitude).reduce((a, b) => a > b ? a : b);
    double northEastLng = allLocations.map((e) => e.longitude).reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );
  }
}
