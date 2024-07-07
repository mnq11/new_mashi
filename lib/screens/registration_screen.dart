import 'package:flutter/material.dart';
import '../test_users.dart'; // Import the test users map

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _phoneNumber = '';
  String _accountType = 'passenger';
  String _name = '';
  String _address = '';

  // Driver-specific fields
  String _vehicleModel = '';
  String _vehicleLicensePlate = '';
  String _driverLicenseNumber = '';
  String _insurancePolicyNumber = '';

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_password == _confirmPassword) {
        setState(() {
          testUsers.add(User(
            email: _email,
            password: _password,
            phoneNumber: _phoneNumber,
            accountType: _accountType,
            name: _name,
            address: _address,
            vehicleModel: _accountType == 'driver' ? _vehicleModel : null,
            vehicleLicensePlate: _accountType == 'driver' ? _vehicleLicensePlate : null,
            driverLicenseNumber: _accountType == 'driver' ? _driverLicenseNumber : null,
            insurancePolicyNumber: _accountType == 'driver' ? _insurancePolicyNumber : null,
          ));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) {
                  _email = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                onSaved: (value) {
                  _phoneNumber = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (value) {
                  _name = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Address'),
                onSaved: (value) {
                  _address = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _accountType,
                decoration: InputDecoration(labelText: 'Account Type'),
                items: [
                  DropdownMenuItem(
                    value: 'passenger',
                    child: Text('Passenger'),
                  ),
                  DropdownMenuItem(
                    value: 'driver',
                    child: Text('Driver'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _accountType = value!;
                  });
                },
                onSaved: (value) {
                  _accountType = value!;
                },
              ),
              if (_accountType == 'driver') ...[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Vehicle Model'),
                  onSaved: (value) {
                    _vehicleModel = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your vehicle model';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Vehicle License Plate'),
                  onSaved: (value) {
                    _vehicleLicensePlate = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your vehicle license plate';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Driver License Number'),
                  onSaved: (value) {
                    _driverLicenseNumber = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your driver license number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Insurance Policy Number'),
                  onSaved: (value) {
                    _insurancePolicyNumber = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your insurance policy number';
                    }
                    return null;
                  },
                ),
              ],
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (value) {
                  _password = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                onSaved: (value) {
                  _confirmPassword = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
