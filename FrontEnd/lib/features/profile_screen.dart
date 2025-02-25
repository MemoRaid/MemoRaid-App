import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _username;
  late String _profileName;
  late String? _dateOfBirth;
  late String? _country;
  late String? _bio;
  late String? _gender;
  late String? _email;
  late String? _phoneNumber;
  XFile? _profileImage;
  final List<String> _countries = [
    'United States',
    'Canada',
    'United Kingdom',
    'Australia',
    'Germany',
    'France',
    'Japan',
    'India',
    'Brazil',
    'Other'
  ];
  final List<String> _genders = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say'
  ];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _username = user.username;
    _profileName = user.profileName;
    _dateOfBirth = user.dateOfBirth;
    _country = user.country;
    _bio = user.bio;
    _gender = user.gender;
    _email = user.email;
    _phoneNumber = user.phoneNumber;
    _profileImage =
        user.profileImage != null ? XFile(user.profileImage!) : null;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth != null
          ? DateFormat('yyyy-MM-dd').parse(_dateOfBirth!)
          : DateTime.now().subtract(Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF0D3445)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Color(0xFF0D3445),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFF0D3445),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: _profileImage == null
                            ? AssetImage("lib/assets/images/kushen.png")
                            : FileImage(File(_profileImage!.path))
                                as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Color(0xFF4E6077),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                _buildSectionTitle("Basic Information"),
                TextFormField(
                  initialValue: _profileName,
                  decoration: InputDecoration(
                    labelText: 'Profile Name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSaved: (value) {
                    _profileName = value ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your profile name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  initialValue: _username,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSaved: (value) {
                    _username = value ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      initialValue: _dateOfBirth,
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onSaved: (value) {
                        _dateOfBirth = value;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _country,
                  items: _countries
                      .map((country) => DropdownMenuItem(
                            value: country,
                            child: Text(country),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _country = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Country',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSaved: (value) {
                    _country = value;
                  },
                ),
                SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _gender,
                  items: _genders
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSaved: (value) {
                    _gender = value;
                  },
                ),
                SizedBox(height: 20),
                _buildSectionTitle("Contact Information"),
                TextFormField(
                  initialValue: _email,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSaved: (value) {
                    _email = value;
                  },
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegExp.hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  initialValue: _phoneNumber,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSaved: (value) {
                    _phoneNumber = value;
                  },
                ),
                SizedBox(height: 20),
                _buildSectionTitle("About Me"),
                TextFormField(
                  initialValue: _bio,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Bio',
                    hintText: 'Tell us about yourself',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSaved: (value) {
                    _bio = value;
                  },
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _formKey.currentState?.save();
                        Provider.of<UserProvider>(context, listen: false)
                            .updateUser(
                          username: _username,
                          profileName: _profileName,
                          profileImage: _profileImage?.path,
                          dateOfBirth: _dateOfBirth,
                          country: _country,
                          bio: _bio,
                          gender: _gender,
                          email: _email,
                          phoneNumber: _phoneNumber,
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4E6077),
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
