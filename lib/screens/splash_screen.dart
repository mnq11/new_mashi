import 'package:flutter/material.dart';
import 'package:new_mashi/screens/passenger/home_passenger_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'driver/home_driver_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? accountType = prefs.getString('accountType');

    await Future.delayed(const Duration(seconds: 2)); // Simulate authentication check

    if (isLoggedIn) {
      if (accountType == 'passenger') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePassengerScreen()),
        );
      } else if (accountType == 'driver') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeDriverScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
