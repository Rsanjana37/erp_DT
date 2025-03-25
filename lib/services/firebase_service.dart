import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Stream<DocumentSnapshot> getUserDetails() {
    final user = _auth.currentUser;
    return _firestore.collection('users').doc(user?.uid).snapshots();
  }

  Future<String?> getUserName() async {
    final user = _auth.currentUser;
    if (user == null) {
      print("No authenticated user found!");
      return null;
    }
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();
    print(querySnapshot.docs.first.data());
    if (querySnapshot.docs.isEmpty) {
      print("No matching document found!");
      return null;
    }

    final userData = querySnapshot.docs.first.data();
    print(userData);
    return userData['name'];
  }

  Stream<List<Map<String, String>>> getUserEvents() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('events')
          .where('email', isEqualTo: user.email)
          .snapshots()
          .map((snapshot) => snapshot.docs.expand((doc) {
                Map<String, dynamic> data = doc.data();
                data.remove("email");
                return data.entries.map((entry) => {
                      "title": entry.key,
                      "time": entry.value.toString(),
                    });
              }).toList());
    }
    return Stream.value([]);
  }

  Stream<List<Map<String, String>>> getUserTasks() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('tasks')
          .where('email', isEqualTo: user.email)
          .snapshots()
          .map((snapshot) => snapshot.docs.expand((doc) {
                Map<String, dynamic> data = doc.data();
                data.remove("email");
                return data.entries.map((entry) => {
                      "task": entry.key,
                      "time": entry.value.toString(),
                    });
              }).toList());
    }
    return Stream.value([]);
  }

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
