import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideDetailsScreen extends StatefulWidget {
  final LatLng pickupLocation;
  final LatLng destinationLocation;
  final double distance;
  final double price;
  final List<LatLng> polylineCoordinates;

  RideDetailsScreen({
    required this.pickupLocation,
    required this.destinationLocation,
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
                    LatLngBounds(
                      southwest: LatLng(
                        widget.pickupLocation.latitude < widget.destinationLocation.latitude
                            ? widget.pickupLocation.latitude
                            : widget.destinationLocation.latitude,
                        widget.pickupLocation.longitude < widget.destinationLocation.longitude
                            ? widget.pickupLocation.longitude
                            : widget.destinationLocation.longitude,
                      ),
                      northeast: LatLng(
                        widget.pickupLocation.latitude > widget.destinationLocation.latitude
                            ? widget.pickupLocation.latitude
                            : widget.destinationLocation.latitude,
                        widget.pickupLocation.longitude > widget.destinationLocation.longitude
                            ? widget.pickupLocation.longitude
                            : widget.destinationLocation.longitude,
                      ),
                    ),
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
                Text('Destination: (${widget.destinationLocation.latitude}, ${widget.destinationLocation.longitude})'),
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
      _markers.add(
        Marker(
          markerId: MarkerId('destination'),
          position: widget.destinationLocation,
          infoWindow: InfoWindow(title: 'Destination'),
        ),
      );
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
}
