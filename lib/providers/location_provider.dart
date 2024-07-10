// lib/providers/location_provider.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;

  Position? get currentPosition => _currentPosition;

  LocationProvider() {
    _startListening();
  }

  void _startListening() {
    Geolocator.getPositionStream().listen((Position position) {
      _currentPosition = position;
      notifyListeners();
    });
  }
}
