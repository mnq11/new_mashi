import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_mashi/main.dart';
import 'package:new_mashi/screens/passenger/ride_booking_screen.dart';
import 'package:new_mashi/screens/passenger/ride_details_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  testWidgets('Ride booking screen initial state test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Check if the app bar title is correct.
    expect(find.text('Book a Ride'), findsOneWidget);

    // Check if the initial map is displayed.
    expect(find.byType(GoogleMap), findsOneWidget);

    // Verify that no markers are present initially.
    final GoogleMap googleMap = tester.widget(find.byType(GoogleMap));
    expect(googleMap.markers.length, 0);
  });

  testWidgets('Select pickup and destination on map', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Check if the map is displayed.
    expect(find.byType(GoogleMap), findsOneWidget);

    // Simulate a tap to select a pickup location.
    RideBookingScreenState rideBookingScreenState = tester.state(find.byType(RideBookingScreen));
    rideBookingScreenState.onTap(LatLng(37.7749, -122.4194));
    await tester.pump();

    // Simulate a tap to select a destination location.
    rideBookingScreenState.onTap(LatLng(37.7849, -122.4094));
    await tester.pump();

    // Verify that markers are added for pickup and destination.
    expect(rideBookingScreenState.pickupLocation, isNotNull);
    expect(rideBookingScreenState.destinationLocation, isNotNull);

    // Verify the distance and price are displayed.
    expect(find.textContaining('Distance'), findsOneWidget);
    expect(find.textContaining('Price'), findsOneWidget);
  });

  testWidgets('Booking a ride navigates to RideDetailsScreen', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Ensure the map is displayed
    expect(find.byType(GoogleMap), findsOneWidget);

    // Simulate map taps by directly calling the onTap callback in the RideBookingScreen
    RideBookingScreenState rideBookingScreenState = tester.state(find.byType(RideBookingScreen));

    // Simulate selecting a pickup location
    rideBookingScreenState.onTap(LatLng(37.7749, -122.4194));
    await tester.pump();

    // Simulate selecting a destination location
    rideBookingScreenState.onTap(LatLng(37.7849, -122.4094));
    await tester.pump();

    // Verify that the "Book Ride" button is displayed
    expect(find.text('Book Ride'), findsOneWidget);

    // Tap the "Book Ride" button
    await tester.tap(find.text('Book Ride'));
    await tester.pumpAndSettle();

    // Verify that the RideDetailsScreen is displayed
    expect(find.byType(RideDetailsScreen), findsOneWidget);
    expect(find.textContaining('Pickup Location'), findsOneWidget);
    expect(find.textContaining('Destination'), findsOneWidget);
    expect(find.textContaining('Distance'), findsOneWidget);
    expect(find.textContaining('Price'), findsOneWidget);
  });
}
