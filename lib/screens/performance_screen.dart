import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaveChartScreen extends StatefulWidget {
  @override
  _LeaveChartScreenState createState() => _LeaveChartScreenState();
}

class _LeaveChartScreenState extends State<LeaveChartScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, int> leaveCount = {};
  bool isLoading = true;

  final List<Color> gradientColors = [
    Color(0xff23b6e6),
    Color(0xff02d39a),
    Color(0xffffa726),
    Color(0xffff6b6b),
    Color(0xff8e24aa),
  ];

  @override
  void initState() {
    super.initState();
    fetchLeaveData();
  }

  Future<void> fetchLeaveData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final querySnapshot = await _firestore
          .collection('leave_applications')
          .where('userEmail', isEqualTo: user.email)
          .get();

      Map<String, int> tempLeaveCount = {};

      for (var doc in querySnapshot.docs) {
        String leaveType = doc['leaveType'];
        tempLeaveCount[leaveType] = (tempLeaveCount[leaveType] ?? 0) + 1;
      }

      setState(() {
        leaveCount = tempLeaveCount;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Leave Applications Chart"),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Leave Distribution",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      isLoading
                          ? Center(child: CircularProgressIndicator())
                          : Container(
                              height: 300, // Reduced height of the graph
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: leaveCount.values
                                      .reduce((a, b) => a > b ? a : b)
                                      .toDouble(),
                                  barTouchData: BarTouchData(
                                    touchTooltipData: BarTouchTooltipData(
                                      tooltipBgColor:
                                          Colors.blueGrey.withOpacity(0.8),
                                      getTooltipItem:
                                          (group, groupIndex, rod, rodIndex) {
                                        String leaveType = leaveCount.keys
                                            .elementAt(group.x.toInt());
                                        return BarTooltipItem(
                                          '$leaveType\n${rod.toY.round()} days',
                                          TextStyle(color: Colors.white),
                                        );
                                      },
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget:
                                            (double value, TitleMeta meta) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              leaveCount.keys
                                                  .elementAt(value.toInt()),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          );
                                        },
                                        reservedSize: 38,
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                        reservedSize: 28,
                                      ),
                                    ),
                                    topTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    checkToShowHorizontalLine: (value) =>
                                        value % 1 == 0,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Colors.black12,
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  borderData: FlBorderData(
                                    show: false,
                                  ),
                                  barGroups: leaveCount.entries.map((entry) {
                                    return BarChartGroupData(
                                      x: leaveCount.keys
                                          .toList()
                                          .indexOf(entry.key),
                                      barRods: [
                                        BarChartRodData(
                                          toY: entry.value.toDouble(),
                                          gradient: LinearGradient(
                                            colors: [
                                              gradientColors[leaveCount.keys
                                                      .toList()
                                                      .indexOf(entry.key) %
                                                  gradientColors.length],
                                              gradientColors[(leaveCount.keys
                                                          .toList()
                                                          .indexOf(entry.key) +
                                                      1) %
                                                  gradientColors.length],
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                          width: 16,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Divider(thickness: 2),
              SizedBox(height: 16),
              Text(
                "Future graphs and statistics will be added here.",
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
