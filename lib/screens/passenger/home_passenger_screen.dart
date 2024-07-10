import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login_screen.dart';
import 'ProfileSettingsScreen.dart';
import 'RideHistoryScreen.dart';
import 'ride_booking_screen.dart';

class HomePassengerScreen extends StatelessWidget {
  const HomePassengerScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passenger Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'Welcome Back, Passenger!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Where would you like to go today?',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RideBookingScreen()),
                );
              },
              icon: const Icon(Icons.book),
              label: const Text('Book a Ride'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RideHistoryScreen()),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('Ride History'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileSettingsScreen()),
                );
              },
              icon: const Icon(Icons.person),
              label: const Text('Profile Settings'),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Recent Activity'),
                subtitle: const Text('You booked a ride to downtown yesterday.'),
                trailing: Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.primary),
                onTap: () {
                  // Navigate to recent activity
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                subtitle: const Text('No new notifications'),
                trailing: Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.primary),
                onTap: () {
                  // Navigate to notifications
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
