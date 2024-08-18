import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../customer_screens/daytimeSelection.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String role = 'customer';
  bool _isLoading = false;

  // Form-specific fields
  String firstName = '';
  String lastName = '';
  String address = '';
  String phoneNumber = '';
  String postalCode = '';
  String nic = '';
  String city = '';
  String vehicleDetails = '';

  // List of Sri Lankan cities for the dropdown
  final List<String> _sriLankanCities = [
    'Colombo',
    'Kandy',
    'Galle',
    'Gampaha',
    'Jaffna',
    'Matara',
    'Trincomalee',
    'Ratnapura',
    'Badulla',
    'Kurunegala',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = await _authService.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (user != null) {
        await user.sendEmailVerification();
        await _saveUserDetails(user);

        await FirebaseAuth.instance.signOut();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Registration successful. Please verify your email before logging in.',
              ),
            ),
          );

          // Navigate to DayTimeSelectionPage only for customers
          if (role == 'customer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DayTimeSelectionPage(userId: user.uid),
              ),
            );
          } else {
            _navigateToHome(); // Navigate to the appropriate home page for other roles
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveUserDetails(User user) async {
    // Save common user details
    await _firestore.collection('users').doc(user.uid).set({
      'email': _emailController.text.trim(),
      'role': role,
      'verified': false,
      'created_at': FieldValue.serverTimestamp(),
      'first_time': true,
    });

    // Additional logic based on user role
    if (role == 'customer') {
      await _firestore.collection('users').doc(user.uid).update({
        'first_name': firstName,
        'last_name': lastName,
        'address': address,
        'phone_number': phoneNumber,
        'postal_code': postalCode,
        'nic_no': nic,
        'city': city,
      });
    } else if (role == 'garbage_collector') {
      await _firestore.collection('users').doc(user.uid).update({
        'name': '$firstName $lastName',
        'phone_number': phoneNumber,
        'vehicle_details': vehicleDetails,
        'nic_no': nic,
        'collector_address': address,
        'collector_city': city,
        'collector_postal_code': postalCode,
      });
    }
  }

  void _navigateToHome() {
    String route = '/';
    if (role == 'customer') {
      route = '/customerHome';
    } else if (role == 'garbage_collector') {
      route = '/garbageCollectorHome';
    } else if (role == 'admin') {
      route = '/adminHome';
    }

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10.0,
        title: Text(
          'REGISTER',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black26,
                offset: Offset(3, 3),
              ),
            ],
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.yellow[700]!, Colors.orange[800]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/pic9.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Center(
                    child: SingleChildScrollView(
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            padding: EdgeInsets.all(24.0),
                            margin: EdgeInsets.only(top: 50), // Brings the form down
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10.0,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: 40), // Space for the logo
                                  _buildRoleSelection(), // Updated role selection
                                  SizedBox(height: 24.0), // Added space between buttons and form
                                  _buildForm(),
                                  SizedBox(height: 24.0),
                                  buildButton(context, 'Register', registerUser),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12), // Rounded corners for the logo
                              child: Image.asset(
                                'assets/images/pic15.png',
                                height: 90,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextEditingController? controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged ?? (value) {},
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Email',
          icon: Icons.email,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                .hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        SizedBox(height: 16.0),
        _buildTextField(
          label: 'Password',
          icon: Icons.lock,
          controller: _passwordController,
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters long';
            }
            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{6,}$')
                .hasMatch(value)) {
              return 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
            }
            return null;
          },
        ),
        SizedBox(height: 16.0),
        _buildTextField(
          label: 'Confirm Password',
          icon: Icons.lock,
          controller: _confirmPasswordController,
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
        SizedBox(height: 16.0),
        _buildTextField(
          label: 'First Name',
          icon: Icons.person,
          onChanged: (value) => firstName = value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your first name';
            }
            return null;
          },
        ),
        SizedBox(height: 16.0),
        _buildTextField(
          label: 'Last Name',
          icon: Icons.person,
          onChanged: (value) => lastName = value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your last name';
            }
            return null;
          },
        ),
        SizedBox(height: 16.0),
        _buildTextField(
          label: 'NIC',
          icon: Icons.badge,
          onChanged: (value) => nic = value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your NIC';
            }
            if (!RegExp(r'^[0-9]{9}[vVxX]|[0-9]{12}$').hasMatch(value)) {
              return 'Please enter a valid NIC number';
            }
            return null;
          },
        ),
        SizedBox(height: 16.0),
        _buildTextField(
          label: 'Phone Number',
          icon: Icons.phone,
          onChanged: (value) => phoneNumber = value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            if (!RegExp(r'^\d{10}$').hasMatch(value)) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
        SizedBox(height: 16.0),
        _buildTextField(
          label: 'Address',
          icon: Icons.home,
          onChanged: (value) => address = value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your address';
            }
            return null;
          },
        ),
        SizedBox(height: 16.0),
        DropdownButtonFormField<String>(
          value: city.isEmpty ? null : city,
          icon: Icon(Icons.arrow_downward),
          decoration: InputDecoration(
            labelText: 'City',
            prefixIcon: Icon(Icons.location_city),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20), // Rounded corners
            ),
          ),
          items: _sriLankanCities.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              city = newValue!;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your city';
            }
            return null;
          },
        ),
        SizedBox(height: 16.0),
        _buildTextField(
          label: 'Postal Code',
          icon: Icons.markunread_mailbox,
          onChanged: (value) => postalCode = value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your postal code';
            }
            if (!RegExp(r'^\d{5}$').hasMatch(value)) {
              return 'Please enter a valid postal code';
            }
            return null;
          },
        ),
        SizedBox(height: 16.0),
        if (role == 'garbage_collector')
          _buildTextField(
            label: 'Vehicle Details',
            icon: Icons.directions_car,
            onChanged: (value) => vehicleDetails = value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your vehicle details';
              }
              return null;
            },
          ),
      ],
    );
  }

  Widget _buildRoleSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        AnimatedRoleButton(
          title: 'Customer',
          roleValue: 'customer',
          currentRole: role,
          onSelected: (value) {
            setState(() {
              role = value;
            });
          },
        ),
        AnimatedRoleButton(
          title: 'Garbage Collector',
          roleValue: 'garbage_collector',
          currentRole: role,
          onSelected: (value) {
            setState(() {
              role = value;
            });
          },
        ),
        AnimatedRoleButton(
          title: 'Admin',
          roleValue: 'admin',
          currentRole: role,
          onSelected: (value) {
            setState(() {
              role = value;
            });
          },
        ),
      ],
    );
  }

  Widget buildButton(BuildContext context, String title, Function onPressed) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[600]!, Colors.red[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 5.0,
                  color: Colors.black45,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedRoleButton extends StatefulWidget {
  final String title;
  final String roleValue;
  final String currentRole;
  final Function(String) onSelected;

  AnimatedRoleButton({
    required this.title,
    required this.roleValue,
    required this.currentRole,
    required this.onSelected,
  });

  @override
  _AnimatedRoleButtonState createState() => _AnimatedRoleButtonState();
}

class _AnimatedRoleButtonState extends State<AnimatedRoleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _sizeAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _colorAnimation = ColorTween(
      begin: Colors.grey[400],
      end: Colors.yellow[700],
    ).animate(_controller);

    _elevationAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.roleValue == widget.currentRole) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedRoleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.roleValue == widget.currentRole) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onSelected(widget.roleValue);
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _sizeAnimation.value,
            child: Material(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(12.0),
              elevation: _elevationAnimation.value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
