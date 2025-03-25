import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp_test_ui/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmployeeDashboard extends StatefulWidget {
  final FirebaseService _firebaseService = FirebaseService();
  EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Dashboard"),
        backgroundColor: const Color.fromARGB(255, 12, 13, 27),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Your Tasks',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<Map<String, String>>>(
              stream: widget._firebaseService.getUserTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                  return const Center(child: Text('Error loading tasks'));
                }

                final events = snapshot.data ?? [];
                print('Tasks: $events');

                if (events.isEmpty) {
                  return const Center(child: Text('No tasks available.'));
                }

                return TaskBox(events: events);
              },
            ),
            const SizedBox(height: 16),
            Text(
              'User Info',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const UserInfoCard(),
          ],
        ),
      ),
    );
  }
}

class TaskBox extends StatelessWidget {
  final List<Map<String, String>> events;

  const TaskBox({Key? key, required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Keep the SingleChildScrollView if your content might overflow
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: events.map((event) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['task'] ?? 'Untitled Task',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event['time'] ?? 'No Deadline',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (events.indexOf(event) < events.length - 1)
                    const Divider(),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class UserInfoCard extends StatefulWidget {
  const UserInfoCard({Key? key}) : super(key: key);

  @override
  State<UserInfoCard> createState() => _UserInfoCardState();
}

class _UserInfoCardState extends State<UserInfoCard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, String> userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs[0].data() as Map<String, dynamic>;

        setState(() {
          userData['leaveBalance'] = data['leave_balance'] as String? ?? '-';
          userData['loginTime'] =
              _formatTimestamp(data['login_time'] as Timestamp?);
          userData['logoutTime'] =
              _formatTimestamp(data['logout_time'] as Timestamp?);
        });
      }
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp != null) {
      final dateTime = timestamp.toDate();
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow('Leave Balance', userData['leaveBalance'] ?? '-'),
            const Divider(),
            _buildRow('Recent Login', userData['loginTime'] ?? '-'),
            const Divider(),
            _buildRow('Last Logout', userData['logoutTime'] ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 16), // Space between title and value
        Text(value),
      ],
    );
  }
}


// In your EmployeeDashboard:
