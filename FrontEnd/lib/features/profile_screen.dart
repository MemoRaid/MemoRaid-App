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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
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
            fontSize: 20,
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                _buildProfileImageSection(),
                _buildFormSection(),
                SizedBox(height: 30),
                _buildSaveButton(context),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: _profileImage == null
                    ? Image.asset(
                        "lib/assets/images/kushen.png",
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(_profileImage!.path),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: _pickImage,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF4E6077),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        Center(
          child: Text(
            "Tap to change profile picture",
            style: TextStyle(
              color: Color(0xFF0D3445),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            "Basic Information",
            [
              _buildTextField(
                initialValue: _profileName,
                labelText: 'Profile Name',
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your profile name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _profileName = value ?? '';
                },
              ),
              _buildTextField(
                initialValue: _username,
                labelText: 'Username',
                prefixIcon: Icons.alternate_email,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                onSaved: (value) {
                  _username = value ?? '';
                },
              ),
              _buildDateField(
                initialValue: _dateOfBirth,
                labelText: 'Date of Birth',
                prefixIcon: Icons.cake,
                onTap: () => _selectDate(context),
                onSaved: (value) {
                  _dateOfBirth = value;
                },
              ),
              _buildDropdownField(
                value: _country,
                items: _countries,
                labelText: 'Country',
                prefixIcon: Icons.public,
                onChanged: (value) {
                  setState(() {
                    _country = value;
                  });
                },
                onSaved: (value) {
                  _country = value;
                },
              ),
              _buildDropdownField(
                value: _gender,
                items: _genders,
                labelText: 'Gender',
                prefixIcon: Icons.people,
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
                onSaved: (value) {
                  _gender = value;
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildSectionCard(
            "Contact Information",
            [
              _buildTextField(
                initialValue: _email,
                labelText: 'Email',
                prefixIcon: Icons.email,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegExp.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value;
                },
              ),
              _buildTextField(
                initialValue: _phoneNumber,
                labelText: 'Phone Number',
                prefixIcon: Icons.phone,
                onSaved: (value) {
                  _phoneNumber = value;
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildSectionCard(
            "About Me",
            [
              _buildTextField(
                initialValue: _bio,
                labelText: 'Bio',
                hintText: 'Tell us about yourself',
                maxLines: 3,
                prefixIcon: Icons.info_outline,
                onSaved: (value) {
                  _bio = value;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Color(0xFF0D3445), // Updated background color
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white, // Updated text color for better contrast
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...children
                .expand((widget) => [widget, SizedBox(height: 16)])
                .toList()
              ..removeLast(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    String? initialValue,
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    int maxLines = 1,
    Function(String?)? onSaved,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      style: TextStyle(color: Colors.white), // Updated text color
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white), // Updated label text color
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white70), // Updated hint text color
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: Colors.white) : null,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50.withOpacity(0.1),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }

  Widget _buildDateField({
    String? initialValue,
    required String labelText,
    IconData? prefixIcon,
    required Function() onTap,
    Function(String?)? onSaved,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          initialValue: initialValue,
          style: TextStyle(color: Colors.white), // Updated text color
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle:
                TextStyle(color: Colors.white), // Updated label text color
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.white)
                : null,
            suffixIcon: Icon(Icons.calendar_today, color: Colors.white),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50.withOpacity(0.1),
          ),
          onSaved: onSaved,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    String? value,
    required List<String> items,
    required String labelText,
    IconData? prefixIcon,
    required Function(String?) onChanged,
    Function(String?)? onSaved,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      style: TextStyle(color: Colors.white), // Updated text color
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white), // Updated label text color
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: Colors.white) : null,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50.withOpacity(0.1),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: TextStyle(color: Colors.black)),
              ))
          .toList(),
      onChanged: onChanged,
      onSaved: onSaved,
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            _formKey.currentState?.save();
            Provider.of<UserProvider>(context, listen: false).updateUser(
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
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          shadowColor: Color(0xFF4E6077).withOpacity(0.5),
          minimumSize: Size(double.infinity, 55),
        ),
        child: Text(
          'Save Changes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
