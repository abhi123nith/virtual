import 'package:flutter/material.dart';
import 'package:virtual/screens/add_number_screen.dart';
import 'package:virtual/screens/number_management_screen.dart';
import 'package:virtual/services/db.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail; // Accept the userEmail as a parameter

  const HomeScreen(
      {super.key, required this.userEmail}); // Constructor for HomeScreen

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  int? userId;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final user =
        await _databaseHelper.getUser(widget.userEmail); // Use widget.userEmail
    if (user != null) {
      setState(() {
        userId = user['id']; // Fetching user_id from the database
        print(user['email']); // Logging email to console
      });
    } else {
      print('User not found');
      // Handle user not found case, if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: SingleChildScrollView(
        // Allow the content to scroll
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.userEmail.isNotEmpty) // Check for null before printing
                Text(
                  widget.userEmail,
                  style: const TextStyle(fontSize: 18),
                ),
              if (userId != null) // Check if userId is not null
                Text(
                  userId.toString(),
                  style: const TextStyle(fontSize: 23),
                ),
              const SizedBox(
                  height: 20), // Space between user text and button area
              const SizedBox(height: 200), // Keeps a fixed space
              HomeButton(
                label: 'Add Numbers',
                icon: Icons.add,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddNumbersScreen()),
                  );
                },
              ),
              const SizedBox(height: 20), // Space between buttons
              HomeButton(
                label: 'Manage Numbers',
                icon: Icons.manage_accounts,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManageNumbersScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              HomeButton(
                label: 'Message',
                icon: Icons.message,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MessageScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const HomeButton(
      {super.key,
      required this.label,
      required this.icon,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }
}

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: const Center(child: Text('Messages Screen')),
    );
  }
}
