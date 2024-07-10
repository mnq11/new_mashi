import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ride_details_screen.dart';

class RideBookingScreen extends StatefulWidget {
  @override
  RideBookingScreenState createState() => RideBookingScreenState();
}

class RideBookingScreenState extends State<RideBookingScreen> {
  GoogleMapController? _mapController;
  LatLng? pickupLocation;
  LatLng? destinationLocation;
  double? _distance;
  double? _price;
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylines = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book a Ride'),
      ),
      body: Column(
        children: [
          Container(
            height: 400,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(37.7749, -122.4194), // Default to San Francisco
                zoom: 12,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: pickupLocation != null && destinationLocation != null
                  ? {
                Marker(
                  markerId: MarkerId('pickup'),
                  position: pickupLocation!,
                  infoWindow: InfoWindow(title: 'Pickup Location'),
                ),
                Marker(
                  markerId: MarkerId('destination'),
                  position: destinationLocation!,
                  infoWindow: InfoWindow(title: 'Destination'),
                ),
              }
                  : Set(),
              polylines: polylines,
              onTap: onTap,
            ),
          ),
          if (pickupLocation != null && destinationLocation == null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Select Destination Point'),
            ),
          if (pickupLocation != null && destinationLocation != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text('Distance: ${_distance?.toStringAsFixed(2)} km'),
                  Text('Price: \$${_price?.toStringAsFixed(2)}'),
                  ElevatedButton(
                    onPressed: () {
                      if (pickupLocation != null &&
                          destinationLocation != null &&
                          _distance != null &&
                          _price != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RideDetailsScreen(
                              pickupLocation: pickupLocation!,
                              destinationLocation: destinationLocation!,
                              distance: _distance!,
                              price: _price!,
                              polylineCoordinates: polylineCoordinates,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Please select both pickup and destination locations',
                            ),
                          ),
                        );
                      }
                    },
                    child: Text('Book Ride'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void onTap(LatLng position) async {
    if (pickupLocation == null) {
      setState(() {
        pickupLocation = position;
      });
    } else if (destinationLocation == null) {
      setState(() {
        destinationLocation = position;
      });
      await _calculateDistance();
      await _createPolylines();
    }
  }

  Future<void> _calculateDistance() async {
    if (pickupLocation != null && destinationLocation != null) {
      double distance = Geolocator.distanceBetween(
        pickupLocation!.latitude,
        pickupLocation!.longitude,
        destinationLocation!.latitude,
        destinationLocation!.longitude,
      );

      // Convert distance to km
      distance = distance / 1000;

      // Assume price is $1.5 per km
      double price = distance * 1.5;

      setState(() {
        _distance = distance;
        _price = price;
      });
    }
  }

  Future<void> _createPolylines() async {
    String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${pickupLocation!.latitude},${pickupLocation!.longitude}&destination=${destinationLocation!.latitude},${destinationLocation!.longitude}&key=$apiKey';

    var response = await http.get(Uri.parse(url));
    var json = jsonDecode(response.body);

    if (json['routes'].isNotEmpty) {
      var points = json['routes'][0]['overview_polyline']['points'];
      polylineCoordinates = _decodePolyline(points);

      setState(() {
        polylines.add(
          Polyline(
            polylineId: PolylineId('route'),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ),
        );
      });
    }
  }

  List<LatLng> _decodePolyline(String poly) {
    List<LatLng> points = [];
    int index = 0, len = poly.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
    }

    return points;
  }
}
