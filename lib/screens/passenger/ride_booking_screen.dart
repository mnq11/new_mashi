import 'package:flutter/material.dart';
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
  List<LatLng> destinationLocations = [];
  double? _distance;
  double? _price;
  double _minPrice = 5.0;
  double _userPrice = 5.0;
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylines = {};
  String selectedVehicle = 'Car';
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  Position? _currentPosition;
  bool _rideSharing = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await _geolocatorPlatform.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      pickupLocation = LatLng(position.latitude, position.longitude);
      _moveCameraToPosition(pickupLocation!, 15.0); // Initial zoom level
    });
  }

  void _moveCameraToPosition(LatLng position, double zoom) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(position, zoom),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book a Ride'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              // Navigate to booking history screen
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildVehicleSelection(),
          _buildMap(),
          _buildRideSharingOption(),
          if (pickupLocation != null && destinationLocations.isEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Select Destination Point', style: TextStyle(color: Colors.teal)),
            ),
          if (pickupLocation != null && destinationLocations.isNotEmpty)
            _buildDestinationList(),
          if (pickupLocation != null && destinationLocations.isNotEmpty)
            _buildRideDetails(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (destinationLocations.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please add at least one destination'),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RideDetailsScreen(
                  pickupLocation: pickupLocation!,
                  destinationLocations: destinationLocations,
                  distance: _distance!,
                  price: _userPrice,
                  polylineCoordinates: polylineCoordinates,
                ),
              ),
            );
          }
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.check),
      ),
    );
  }

  Widget _buildVehicleSelection() {
    return Container(
      height: 100,
      color: Colors.teal.withOpacity(0.1),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          vehicleButton('Car', Icons.directions_car),
          vehicleButton('Motorbike', Icons.two_wheeler),
          vehicleButton('Bicycle', Icons.directions_bike),
          vehicleButton('Van', Icons.directions_bus),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 400,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194), // Default to San Francisco
          zoom: 12,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
          if (pickupLocation != null) {
            _moveCameraToPosition(pickupLocation!, 15.0); // Move camera to pickup location with zoom
          }
        },
        markers: _buildMarkers(),
        polylines: polylines,
        onTap: onTap,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {
      if (pickupLocation != null)
        Marker(
          markerId: MarkerId('pickup'),
          position: pickupLocation!,
          infoWindow: InfoWindow(title: 'Pickup Location'),
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              pickupLocation = newPosition;
              _calculateDistanceAndUpdatePolylines();
            });
          },
        ),
    };

    for (int i = 0; i < destinationLocations.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId('destination_$i'),
          position: destinationLocations[i],
          infoWindow: InfoWindow(title: 'Destination ${i + 1}'),
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              destinationLocations[i] = newPosition;
              _calculateDistanceAndUpdatePolylines();
            });
          },
        ),
      );
    }
    return markers;
  }

  Widget _buildRideSharingOption() {
    return SwitchListTile(
      title: Text('Enable Ride Sharing'),
      value: _rideSharing,
      onChanged: (value) {
        setState(() {
          _rideSharing = value;
        });
      },
    );
  }

  Widget _buildDestinationList() {
    return Expanded(
      child: ListView.builder(
        itemCount: destinationLocations.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            color: Colors.teal.withOpacity(0.1),
            child: ListTile(
              leading: Icon(Icons.location_on, color: Colors.teal),
              title: Text('Destination ${index + 1}'),
              subtitle: Text('(${destinationLocations[index].latitude}, ${destinationLocations[index].longitude})'),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    destinationLocations.removeAt(index);
                    _calculateDistanceAndUpdatePolylines();
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRideDetails() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text('Distance: ${_distance?.toStringAsFixed(2)} km', style: TextStyle(color: Colors.teal)),
          Text('Price: \$${_price?.toStringAsFixed(2)}', style: TextStyle(color: Colors.teal)),
          _buildPriceOfferCounter(),
          ElevatedButton(
            onPressed: () {
              if (pickupLocation != null && destinationLocations.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RideDetailsScreen(
                      pickupLocation: pickupLocation!,
                      destinationLocations: destinationLocations,
                      distance: _distance!,
                      price: _userPrice,
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal, // Corrected parameter for button color
            ),
            child: Text('Book Ride'),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceOfferCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.remove, color: Colors.teal),
          onPressed: () {
            setState(() {
              if (_userPrice > _minPrice) {
                _userPrice--;
              }
            });
          },
        ),
        Text('Offer: \$${_userPrice.toStringAsFixed(2)}', style: TextStyle(color: Colors.teal)),
        IconButton(
          icon: Icon(Icons.add, color: Colors.teal),
          onPressed: () {
            setState(() {
              _userPrice++;
            });
          },
        ),
      ],
    );
  }

  Widget vehicleButton(String vehicleType, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedVehicle = vehicleType;
          _updatePrice(); // Recalculate distance and price when vehicle type changes
        });
      },
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: selectedVehicle == vehicleType ? Colors.teal : Colors.grey[300],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40.0, color: selectedVehicle == vehicleType ? Colors.white : Colors.black),
            SizedBox(height: 5.0),
            Text(
              vehicleType,
              style: TextStyle(
                color: selectedVehicle == vehicleType ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onTap(LatLng position) async {
    if (pickupLocation == null) {
      setState(() {
        pickupLocation = position;
        _moveCameraToPosition(pickupLocation!, 15.0); // Move camera to pickup location
      });
    } else {
      setState(() {
        destinationLocations.add(position);
      });
      await _calculateDistanceAndUpdatePolylines();
    }
  }

  Future<void> _updatePrice() async {
    await _calculateDistanceAndUpdatePolylines();
  }

  Future<void> _calculateDistanceAndUpdatePolylines() async {
    if (pickupLocation != null && destinationLocations.isNotEmpty) {
      double totalDistance = 0.0;
      LatLng prevLocation = pickupLocation!;

      for (LatLng dest in destinationLocations) {
        totalDistance += Geolocator.distanceBetween(
          prevLocation.latitude,
          prevLocation.longitude,
          dest.latitude,
          dest.longitude,
        );
        prevLocation = dest;
      }

      // Convert distance to km
      totalDistance = totalDistance / 1000;

      // Adjust price based on vehicle type
      double baseRate = selectedVehicle == 'Car'
          ? 1.5
          : selectedVehicle == 'Motorbike'
          ? 1.0
          : selectedVehicle == 'Bicycle'
          ? 0.5
          : 2.0;

      double price = totalDistance * baseRate;

      setState(() {
        _distance = totalDistance;
        _price = price < _minPrice ? _minPrice : price; // Ensure price meets minimum
        _userPrice = _price ?? _minPrice; // Reset user price to calculated price
      });

      await _createPolylines();
    }
  }

  Future<void> _createPolylines() async {
    if (pickupLocation != null && destinationLocations.isNotEmpty) {
      try {
        List<LatLng> allLocations = [pickupLocation!, ...destinationLocations];
        polylineCoordinates.clear();

        for (int i = 0; i < allLocations.length - 1; i++) {
          final response = await http.get(
            Uri.parse(
                'https://maps.googleapis.com/maps/api/directions/json?origin=${allLocations[i].latitude},${allLocations[i].longitude}&destination=${allLocations[i + 1].latitude},${allLocations[i + 1].longitude}&key=YOUR_API_KEY'),
          );

          if (response.statusCode == 200) {
            final Map<String, dynamic> data = json.decode(response.body);
            final List<dynamic> routes = data['routes'];

            if (routes.isNotEmpty) {
              final List<dynamic> legs = routes[0]['legs'];
              final List<dynamic> steps = legs[0]['steps'];

              for (var step in steps) {
                final startLocation = step['start_location'];
                final endLocation = step['end_location'];

                polylineCoordinates.add(
                  LatLng(
                    startLocation['lat'],
                    startLocation['lng'],
                  ),
                );
                polylineCoordinates.add(
                  LatLng(
                    endLocation['lat'],
                    endLocation['lng'],
                  ),
                );
              }
            }
          } else {
            throw Exception('Failed to load directions');
          }
        }

        setState(() {
          polylines = {
            Polyline(
              polylineId: PolylineId('route'),
              points: polylineCoordinates,
              color: Colors.blue,
              width: 5,
            ),
          };
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching directions: $e'),
          ),
        );
      }
    }
  }
}
