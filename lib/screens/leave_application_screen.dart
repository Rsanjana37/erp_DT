import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class LeaveApplicationScreen extends StatefulWidget {
  @override
  _LeaveApplicationScreenState createState() => _LeaveApplicationScreenState();
}

class _LeaveApplicationScreenState extends State<LeaveApplicationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  int leaveBalance = 0;
  String employeeId = '';
  String employeeName = '';
  String _editedEmployeeId = '';
  String _editedEmployeeName = '';
  DateTime? fromDate;
  DateTime? toDate;
  String leaveType = 'Sick Leave';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    user = _auth.currentUser;
    if (user != null) {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: user!.email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs[0].data() as Map<String, dynamic>;
        setState(() {
          employeeId = userData['empid'] ?? '';
          employeeName = userData['name'] ?? '';
          _editedEmployeeId = employeeId;
          _editedEmployeeName = employeeName;

          leaveBalance =
              int.tryParse(userData['leave_balance'].toString()) ?? 0;
        });
      }
    }
  }

  Future<void> _submitLeaveApplication() async {
    if (_formKey.currentState!.validate()) {
      if (fromDate == null || toDate == null) {
        _showSnackBar('Please select both From and To dates.');
        return;
      }

      if (fromDate!.isAfter(toDate!)) {
        _showSnackBar('From date cannot be after To date.');
        return;
      }

      int leaveDuration = toDate!.difference(fromDate!).inDays + 1;

      if (leaveDuration > leaveBalance) {
        _showSnackBar('Insufficient leave balance.');
        return;
      }

      try {
        await _firestore.collection('leave_applications').add({
          'employeeId':
              _editedEmployeeId.isNotEmpty ? _editedEmployeeId : employeeId,
          'employeeName': _editedEmployeeName.isNotEmpty
              ? _editedEmployeeName
              : employeeName,
          'fromDate': fromDate,
          'toDate': toDate,
          'leaveType': leaveType,
          'userEmail': user!.email,
          'status': 'Pending',
        });

        await _firestore
            .collection('users')
            .where('email', isEqualTo: user!.email)
            .limit(1)
            .get()
            .then((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            snapshot.docs[0].reference
                .update({'leave_balance': leaveBalance - leaveDuration});
          }
        });

        setState(() {
          leaveBalance -= leaveDuration;
          fromDate = null;
          toDate = null;
          leaveType = 'Sick Leave';
          _formKey.currentState!.reset();
        });

        _showSnackBar('Leave application submitted successfully.');
      } catch (e) {
        _showSnackBar('Error submitting application: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Application'),
        backgroundColor: const Color.fromARGB(255, 12, 13, 27),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              _buildLeaveBalanceCard(),
              SizedBox(height: 55),
              _buildTextField(
                  'Employee ID', employeeId, (val) => _editedEmployeeId = val),
              SizedBox(height: 10),
              _buildTextField('Employee Name', employeeName,
                  (val) => _editedEmployeeName = val),
              SizedBox(height: 20),
              _buildDatePicker('From Date', fromDate,
                  (date) => setState(() => fromDate = date)),
              SizedBox(height: 10),
              _buildDatePicker(
                  'To Date', toDate, (date) => setState(() => toDate = date)),
              SizedBox(height: 20),
              _buildDropdownField(
                label: 'Leave Type',
                value: leaveType,
                items: [
                  'Sick Leave',
                  'Paternity Leave',
                  'Unpaid Leave',
                  'Maternity Leave'
                ],
                onChanged: (val) => setState(() => leaveType = val!),
              ),
              SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveBalanceCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color.fromARGB(255, 12, 13, 27),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Leave Balance',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text('$leaveBalance days',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, String initialValue, Function(String) onChanged) {
    return TextFormField(
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color.fromARGB(255, 50, 169, 159),
            fontStyle: FontStyle.normal, // Italic font style
            fontSize: 16, // Optional: Change font size
            fontWeight: FontWeight.bold, // Optional: Make text bold
          ),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey.shade100),
      initialValue: initialValue,
      onChanged: onChanged,
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildDatePicker(
      String label, DateTime? date, Function(DateTime) onDateSelected) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101));
        if (picked != null) onDateSelected(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              color: Color.fromARGB(255, 50, 169, 159), // Black color
              fontStyle: FontStyle.normal, // Italic font style
              fontSize: 16, // Optional: Change font size
              fontWeight: FontWeight.bold, // Optional: Make text bold
            ),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey.shade100),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null
                  ? 'Select Date'
                  : DateFormat('yyyy-MM-dd').format(date),
              style: const TextStyle(color: Colors.black),
            ),
            Icon(Icons.calendar_today, color: Colors.teal.shade600),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return SizedBox(
      height: 50, // Adjust the dropdown height
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 5), // Reduce padding
        ),
        value: value,
        isDense: true,
        style:
            const TextStyle(color: Colors.black), // Makes dropdown more compact
        // Smaller dropdown arrow
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: TextStyle(fontSize: 14)), // Smaller text
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _submitLeaveApplication,
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 12, 13, 27),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30))),
        child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            child: Text('Submit Application', style: TextStyle(fontSize: 18))),
      ),
    );
  }
}
