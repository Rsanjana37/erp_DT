import 'package:erp_test_ui/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      print("No authenticated user found!");
      return;
    }
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();
    if (querySnapshot.docs.isEmpty) {
      print("No matching document found!");
      return;
    }

    final document = querySnapshot.docs.first;
    setState(() {
      userData = document.data();
    });
  }

  @override
  Widget build(BuildContext context) {
    return userData == null
        ? const Center(child: CircularProgressIndicator())
        : CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 60,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          (userData!['name'] as String?)?.isNotEmpty == true
                              ? (userData!['name'] as String)
                                  .substring(0, 1)
                                  .toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userData!['name'] ?? 'User Profile',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userData!['email'] ?? '',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground
                                      .withOpacity(0.7),
                                ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoCard(context),
                    ],
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(context, Icons.person, 'Name',
                userData!['name'] ?? 'Not provided'),
            const Divider(),
            _buildInfoRow(context, Icons.email, 'Email',
                userData!['email'] ?? 'Not provided'),
            const Divider(),
            _buildInfoRow(context, Icons.phone, 'Phone',
                userData!['phone'] ?? 'Not provided'),
            ElevatedButton(
              onPressed: () async {
                // Get the current user
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // Get the current timestamp for logout
                  DateTime logoutTime = DateTime.now();

                  // Query Firestore to get the user document
                  final querySnapshot = await _firestore
                      .collection('users')
                      .where('email', isEqualTo: user.email)
                      .limit(1)
                      .get();

                  if (querySnapshot.docs.isNotEmpty) {
                    // Get the first document (there should only be one document based on email)
                    final document = querySnapshot.docs.first;

                    // Update the logout time in the Firestore document
                    await document.reference.update({
                      'logout_time': logoutTime, // Store the logout time
                    });

                    // Log out from Firebase
                    await _auth.signOut();

                    // Navigate back to the login page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const LoginPage()), // Replace with your login page widget
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Background color
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white, // Text color
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
