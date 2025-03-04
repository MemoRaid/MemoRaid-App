import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  _HelpCenterScreenState createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FAQItem> _filteredFAQs = [];
  String _selectedCategory = 'All';

  final List<FAQItem> _allFAQs = [
    // Account FAQs
    FAQItem(
      category: 'Account',
      question: 'How do I reset my password?',
      answer:
          'To reset your password, go to the login screen and tap "Forgot Password". Follow the instructions sent to your email address to create a new password.',
    ),
    FAQItem(
      category: 'Account',
      question: 'How can I update my profile information?',
      answer:
          'Go to Settings > Profile to update your personal information including name, email, profile picture, and other details.',
    ),
    FAQItem(
      category: 'Account',
      question: 'How can I delete my account?',
      answer:
          'Go to Settings > Account > Delete Account. Please note that this action is permanent and all your data will be lost.',
    ),

    // Memory Training FAQs
    FAQItem(
      category: 'Memory Training',
      question: 'How does the memory training work?',
      answer:
          'MemoRaid uses scientifically proven spaced repetition techniques to help improve memory retention. Regular practice with increasing difficulty helps strengthen your memory over time.',
    ),
    FAQItem(
      category: 'Memory Training',
      question: 'How often should I practice?',
      answer:
          'For optimal results, we recommend daily practice sessions of 10-15 minutes. Consistent practice yields better results than occasional longer sessions.',
    ),
    FAQItem(
      category: 'Memory Training',
      question: 'Can I track my progress?',
      answer:
          'Yes, you can view your progress in the Leaderboard section. It shows your improvements over time, achievements, and how you compare with others.',
    ),

    // Technical Support FAQs
    FAQItem(
      category: 'Technical Support',
      question: 'The app is crashing, what should I do?',
      answer:
          'First, try restarting the app. If the problem persists, restart your device. Make sure your app is updated to the latest version. If issues continue, please contact our support team.',
    ),
    FAQItem(
      category: 'Technical Support',
      question: 'How do I report a bug?',
      answer:
          'You can report bugs by going to Settings > Help Center > Report a Bug. Please provide as much detail as possible including steps to reproduce the issue.',
    ),
    FAQItem(
      category: 'Technical Support',
      question: 'Does MemoRaid work offline?',
      answer:
          'Yes, most features work offline. However, leaderboards, syncing across devices, and some advanced features require an internet connection.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredFAQs = _allFAQs;
    _searchController.addListener(_filterFAQs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFAQs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty && _selectedCategory == 'All') {
        _filteredFAQs = _allFAQs;
      } else if (query.isEmpty) {
        _filteredFAQs =
            _allFAQs.where((faq) => faq.category == _selectedCategory).toList();
      } else if (_selectedCategory == 'All') {
        _filteredFAQs = _allFAQs
            .where((faq) =>
                faq.question.toLowerCase().contains(query) ||
                faq.answer.toLowerCase().contains(query))
            .toList();
      } else {
        _filteredFAQs = _allFAQs
            .where((faq) =>
                faq.category == _selectedCategory &&
                (faq.question.toLowerCase().contains(query) ||
                    faq.answer.toLowerCase().contains(query)))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer for rebuilding when theme changes
    return Consumer<ThemeProvider>(builder: (context, themeProvider, _) {
      return Scaffold(
        backgroundColor: themeProvider.primaryBackgroundColor,
        appBar: AppBar(
          backgroundColor: themeProvider.primaryBackgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: themeProvider.primaryTextColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Help Center",
            style: TextStyle(
              color: themeProvider.primaryTextColor,
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
              colors: themeProvider.getGradientColors(),
            ),
          ),
          child: Column(
            children: [
              _buildSearchBar(themeProvider),
              SizedBox(height: 15),
              _buildCategories(themeProvider),
              SizedBox(height: 15),
              Expanded(
                child: _buildFAQList(themeProvider),
              ),
              _buildSupportButton(themeProvider),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSearchBar(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: themeProvider.primaryTextColor),
        decoration: InputDecoration(
          hintText: 'Search for help...',
          hintStyle:
              TextStyle(color: themeProvider.primaryTextColor.withOpacity(0.6)),
          prefixIcon: Icon(Icons.search, color: themeProvider.primaryTextColor),
          fillColor: themeProvider.cardColor.withOpacity(0.2),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildCategories(ThemeProvider themeProvider) {
    final Set<String> categories = _allFAQs
        .map((faq) => faq.category)
        .toSet()
        .toList()
        .cast<String>()
        .toSet();

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1, // +1 for "All" category
        itemBuilder: (context, index) {
          final isAllCategory = index == 0;
          final category =
              isAllCategory ? 'All' : categories.elementAt(index - 1);
          final isSelected = _selectedCategory == category;

          return Container(
            margin: EdgeInsets.only(right: 10),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = category;
                  _filterFAQs();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSelected ? Colors.white : themeProvider.accentColor,
                foregroundColor:
                    isSelected ? themeProvider.accentColor : Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Text(category),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAQList(ThemeProvider themeProvider) {
    if (_filteredFAQs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: themeProvider.primaryTextColor.withOpacity(0.6),
            ),
            SizedBox(height: 16),
            Text(
              'No matching results found',
              style: TextStyle(
                color: themeProvider.primaryTextColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try different search terms or categories',
              style: TextStyle(
                color: themeProvider.primaryTextColor.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _filteredFAQs.length,
      itemBuilder: (context, index) {
        return _buildFAQItem(_filteredFAQs[index], themeProvider);
      },
    );
  }

  Widget _buildFAQItem(FAQItem faq, ThemeProvider themeProvider) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Color(0xFF0D3445),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
            faq.question,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: themeProvider.accentColor,
            child: Icon(
              Icons.question_mark,
              color: Colors.white,
              size: 16,
            ),
          ),
          childrenPadding: EdgeInsets.all(16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          children: [
            Text(
              faq.answer,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.thumb_up_outlined, size: 16),
                  label: Text('Helpful'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withOpacity(0.7),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Thank you for your feedback!')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportButton(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        icon: Icon(Icons.support_agent),
        label: Text('Contact Support'),
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.accentColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          minimumSize: Size(double.infinity, 55),
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: themeProvider.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => _buildContactSupportSheet(themeProvider),
          );
        },
      ),
    );
  }

  Widget _buildContactSupportSheet(ThemeProvider themeProvider) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Support',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _buildContactOption(
            icon: Icons.email_outlined,
            title: 'Email Support',
            subtitle: 'Get help via email (response within 24 hours)',
            themeProvider: themeProvider,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildContactOption(
            icon: Icons.chat_bubble_outline,
            title: 'Live Chat',
            subtitle: 'Chat with our support team (available 9AM-5PM)',
            themeProvider: themeProvider,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildContactOption(
            icon: Icons.forum_outlined,
            title: 'Community Forum',
            subtitle: 'Browse help topics and user discussions',
            themeProvider: themeProvider,
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeProvider themeProvider,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: themeProvider.accentColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
      onTap: onTap,
    );
  }
}

class FAQItem {
  final String category;
  final String question;
  final String answer;

  FAQItem({
    required this.category,
    required this.question,
    required this.answer,
  });
}
