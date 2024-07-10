import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:new_mashi/screens/passenger/ride_booking_screen.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp(
        title: 'Ride Sharing App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: RideBookingScreen(),
      ),
    );
  }
}
