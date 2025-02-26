import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'password_security_screen.dart';
import 'notifications_screen.dart';
import 'help_center_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';
  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese'
  ];

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
          "Settings",
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
          child: Column(
            children: [
              SizedBox(height: 5),

              // Profile Section
              Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                AssetImage("lib/assets/images/kushen.png"),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFF4E6077),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child:
                                Icon(Icons.edit, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Mr.John',
                      style: TextStyle(
                        color: Color(0xFF0D3445),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@johnfern3',
                      style: TextStyle(
                        color: Color(0xFF0D3445).withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Settings Sections
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSection('Account', [
                      SettingItemNavigation(
                        icon: Icons.person_outline,
                        title: 'Profile',
                        subtitle: 'Edit your profile information',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen()),
                        ),
                      ),
                      SettingItemNavigation(
                        icon: Icons.lock_outline,
                        title: 'Password & Security',
                        subtitle: 'Manage your security settings',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PasswordSecurityScreen()),
                        ),
                      ),
                      SettingItemNavigation(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Customize your notifications',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotificationsScreen()),
                        ),
                      ),
                    ]),
                    SizedBox(height: 16),
                    _buildSection('Preferences', [
                      SettingItemSwitch(
                        icon: Icons.palette_outlined,
                        title: 'Dark Mode',
                        subtitle: 'Toggle dark mode on/off',
                        value: _isDarkMode,
                        onChanged: (value) {
                          setState(() {
                            _isDarkMode = value;
                          });
                          // Apply dark mode changes here
                        },
                      ),
                      SettingItemDropdown(
                        icon: Icons.language_outlined,
                        title: 'Language',
                        subtitle: 'Select your preferred language',
                        value: _selectedLanguage,
                        items: _languages,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedLanguage = value;
                            });
                            // Apply language changes here
                          }
                        },
                      ),
                    ]),
                    SizedBox(height: 16),
                    _buildSection('Support', [
                      SettingItemNavigation(
                        icon: Icons.help_outline,
                        title: 'Help Center',
                        subtitle: 'Get help and support',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HelpCenterScreen()),
                        ),
                      ),
                      SettingItemNavigation(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'Read our privacy policy',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PrivacyPolicyScreen()),
                        ),
                      ),
                      SettingItemNavigation(
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        subtitle: 'Read our terms of service',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TermsOfServiceScreen()),
                        ),
                      ),
                    ]),
                    SizedBox(height: 24),
                    _buildLogoutButton(),
                    SizedBox(height: 22),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF0D3445),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (index != items.length - 1)
                    Divider(
                      height: 1,
                      color: Colors.white.withOpacity(0.1),
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4E6077),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Log Out',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class SettingItemNavigation extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingItemNavigation({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFF4E6077),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.7),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingItemSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;

  const SettingItemSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFF4E6077),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFF4E6077),
            activeTrackColor: Colors.white.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}

class SettingItemDropdown extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final List<String> items;
  final Function(String?) onChanged;

  const SettingItemDropdown({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFF4E6077),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Color(0xFF4E6077),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                style: TextStyle(color: Colors.white),
                dropdownColor: Color(0xFF4E6077),
                icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                isExpanded: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
