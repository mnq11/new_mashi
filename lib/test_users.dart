// lib/test_users.dart

class User {
  final String email;
  final String password;
  final String phoneNumber;
  final String accountType;
  final String name;
  final String address;

  // Driver-specific information
  final String? vehicleModel;
  final String? vehicleLicensePlate;
  final String? driverLicenseNumber;
  final String? insurancePolicyNumber;

  User({
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.accountType,
    required this.name,
    required this.address,
    this.vehicleModel,
    this.vehicleLicensePlate,
    this.driverLicenseNumber,
    this.insurancePolicyNumber,
  });
}

List<User> testUsers = [];
