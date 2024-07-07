import 'package:flutter/material.dart';

class HomeDriverScreen extends StatelessWidget {
  const HomeDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 20),
            Text(
              'Welcome Back, Driver!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Here\'s your dashboard:',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to ride requests
              },
              icon: const Icon(Icons.receipt),
              label: const Text('View Ride Requests'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to earnings
              },
              icon: const Icon(Icons.monetization_on),
              label: const Text('Earnings'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to profile settings
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
                subtitle: const Text('You had 3 rides today.'),
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
