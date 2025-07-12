import 'package:enhud/core/core.dart';
import 'package:enhud/main.dart';
import 'package:enhud/models/exam_result.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class WeeklyReport extends StatefulWidget {
  const WeeklyReport({super.key});

  @override
  State<WeeklyReport> createState() => _WeeklyReportState();
}

class _WeeklyReportState extends State<WeeklyReport> {
  String _calculateDuration(String timeSlot) {
    try {
      final parts = timeSlot.split(' - ');
      final DateFormat format = DateFormat.jm();
      final DateTime startTime = format.parse(parts[0]);
      final DateTime endTime = format.parse(parts[1]);
      final Duration difference = endTime.difference(startTime);
      if (difference.isNegative) return '0h 0m';
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      return '${hours}h ${minutes}m';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getDayName(int colIndex) {
    switch (colIndex) {
      case 1:
        return 'Saturday';
      case 2:
        return 'Sunday';
      case 3:
        return 'Monday';
      case 4:
        return 'Tuesday';
      case 5:
        return 'Wednesday';
      case 6:
        return 'Thursday';
      case 7:
        return 'Friday';
      default:
        return 'Unknown Day';
    }
  }

  DateTime getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Weekly Report', style: commonTextStyle),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline))
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([
          mybox != null
              ? Future.value(mybox!.get('noti', defaultValue: []))
              : Future.value([]),
          mybox != null
              ? Future.value(mybox!.get('exam_results', defaultValue: []))
              : Future.value([])
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Safely convert schedule items
          final scheduleItems = <Map<String, dynamic>>[];
          if (snapshot.data != null &&
              snapshot.data!.isNotEmpty &&
              snapshot.data![0] is List) {
            for (var item in snapshot.data![0]) {
              if (item is Map) {
                final Map<String, dynamic> typedMap = {};
                item.forEach((key, value) {
                  if (key is String) {
                    typedMap[key] = value;
                  }
                });
                scheduleItems.add(typedMap);
              }
            }
          }

          // Safely convert exam results
          final examResults = <ExamResult>[];
          if (snapshot.data != null &&
              snapshot.data!.length > 1 &&
              snapshot.data![1] is List) {
            for (var data in snapshot.data![1]) {
              try {
                if (data is Map) {
                  final Map<String, dynamic> typedMap = {};
                  data.forEach((key, value) {
                    if (key is String) {
                      typedMap[key] = value;
                    }
                  });

                  final result = ExamResult.fromJson(typedMap);
                  examResults.add(result);
                }
              } catch (e) {
                print('Error converting exam result: $e');
              }
            }
          }

          final now = DateTime.now();
          final weekStartDate = now
              .add(Duration(days: (currentWeekOffset * 7) - (now.weekday - 1)));
          final weekEndDate = weekStartDate.add(const Duration(days: 7));

          List<Map<String, dynamic>> currentWeekStudyItems = scheduleItems
              .where((item) =>
                  item['week'] == currentWeekOffset &&
                  (item['category'] == 'Material' ||
                      item['category'] == 'Study'))
              .toList();

          List<ExamResult> currentWeekExams = examResults
              .where((result) =>
                  result.timestamp.isAfter(weekStartDate) &&
                  result.timestamp.isBefore(weekEndDate))
              .toList();

          List<Map<String, dynamic>> studiedSubjects = currentWeekStudyItems
              .where((item) => item['done'] == true)
              .toList();
          List<Map<String, dynamic>> notStudiedSubjects = currentWeekStudyItems
              .where((item) => item['done'] == false || item['done'] == null)
              .toList();
          List<Map<String, dynamic>> freeTimeSlots = scheduleItems
              .where((item) =>
                  item['week'] == currentWeekOffset &&
                  (item['title'] == 'Free Time' || item['title'] == 'Empty'))
              .toList();
          int studiedLastWeekCount = scheduleItems
              .where((item) =>
                  item['week'] == currentWeekOffset - 1 &&
                  item['done'] == true &&
                  (item['category'] == 'Material' ||
                      item['category'] == 'Study'))
              .length;

          return SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                      child: Text(
                          "Here's a look at what you covered & not covered this week.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey))),
                  const SizedBox(height: 24),
                  const Text('Your Progress', style: commonTextStyle),
                  const SizedBox(height: 8),
                  _buildProgressCard(
                      studiedSubjects.length, studiedLastWeekCount),
                  const SizedBox(height: 24),
                  const Text('Exams Taken', style: commonTextStyle),
                  const SizedBox(height: 8),
                  _buildExamsTakenCard(currentWeekExams),
                  const SizedBox(height: 24),
                  const Text('Subjects Studied', style: commonTextStyle),
                  const SizedBox(height: 8),
                  _buildStudiedList(studiedSubjects),
                  const SizedBox(height: 24),
                  const Text('Subjects Not Studied', style: commonTextStyle),
                  const SizedBox(height: 8),
                  _buildNotStudiedList(notStudiedSubjects),
                  const SizedBox(height: 24),
                  const Text(
                      'Based on your availability, we have some suggestions for when you could study the subjects you missed this week.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 15)),
                  const SizedBox(height: 24),
                  const Text('Suggested Study Times', style: commonTextStyle),
                  const SizedBox(height: 8),
                  _buildSuggestionsList(notStudiedSubjects, freeTimeSlots),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExamsTakenCard(List<ExamResult> exams) {
    if (exams.isEmpty) {
      return const Text("  No exams were taken this week.");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        final exam = exams[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                "${exam.percentage.toStringAsFixed(0)}%",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.blue),
              ),
            ),
            title: Text(exam.material,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle:
                Text('Score: ${exam.correctAnswers} / ${exam.totalQuestions}'),
            trailing: Icon(
              exam.percentage >= 50 ? Icons.check_circle : Icons.cancel,
              color: exam.percentage >= 50 ? Colors.green : Colors.red,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressCard(int currentWeekCount, int lastWeekCount) {
    if (currentWeekOffset == 0) {
      return const Card(
        elevation: 1,
        child: ListTile(
          leading: Icon(Icons.info_outline, color: Colors.blue),
          title: Text("Your first week!"),
          subtitle:
              Text("Your progress will be shown here starting next week."),
        ),
      );
    }

    double percentageChange = 0;
    if (lastWeekCount > 0) {
      percentageChange =
          ((currentWeekCount - lastWeekCount) / lastWeekCount) * 100;
    } else if (currentWeekCount > 0) {
      percentageChange = 100;
    }

    String progressText;
    Color progressColor;
    IconData progressIcon;

    if (percentageChange > 0) {
      progressText =
          "You've improved by ${percentageChange.toStringAsFixed(0)}% from last week. Keep it up!";
      progressColor = Colors.green;
      progressIcon = Icons.arrow_upward;
    } else if (percentageChange < 0) {
      progressText =
          "A slight dip of ${percentageChange.abs().toStringAsFixed(0)}% this week. You can do better!";
      progressColor = Colors.red;
      progressIcon = Icons.arrow_downward;
    } else {
      progressText =
          "You've maintained the same pace as last week. Consistency is key!";
      progressColor = Colors.orange;
      progressIcon = Icons.trending_flat;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: progressColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(progressIcon, color: progressColor, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                progressText,
                style: TextStyle(
                    color: progressColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudiedList(List<Map<String, dynamic>> subjects) {
    if (subjects.isEmpty) {
      return const Text("  No subjects studied this week.");
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final timeSlot = timeSlots[subject['row']];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(bookimagepath),
            ),
            title: Text(subject['title'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_calculateDuration(timeSlot)),
          ),
        );
      },
    );
  }

  Widget _buildNotStudiedList(List<Map<String, dynamic>> subjects) {
    if (subjects.isEmpty) {
      return const Text("  Great job! You've studied all your subjects.");
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final timeSlot = timeSlots[subject['row']];

        String descriptionText = 'No specific points were listed.';
        if (subject['description'] != null &&
            subject['description'] is List &&
            subject['description'].isNotEmpty) {
          var points = (subject['description'] as List)
              .map((task) => task['title'])
              .join(', ');
          descriptionText = 'Missed: $points';
        } else if (subject['description'] != null &&
            subject['description'] is String &&
            subject['description'].isNotEmpty) {
          descriptionText = 'Missed: ${subject['description']}';
        }

        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(bookimagepath),
            ),
            title: Text(subject['title'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_calculateDuration(timeSlot)),
                Text(
                  descriptionText,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestionsList(List<Map<String, dynamic>> notStudied,
      List<Map<String, dynamic>> freeSlots) {
    if (notStudied.isEmpty) {
      return const Text("  Great job! Everything is studied.");
    }
    if (freeSlots.isEmpty) {
      return const Text("  No free time slots available to make suggestions.");
    }

    int suggestionsCount = min(notStudied.length, freeSlots.length);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: suggestionsCount,
      itemBuilder: (context, index) {
        final subject = notStudied[index];
        final freeSlot = freeSlots[index];
        final timeSlot = timeSlots[freeSlot['row']];

        String materialDetails = subject['title'];
        if (subject['unit'] != null && subject['unit'].isNotEmpty) {
          materialDetails += ' - ${subject['unit']}';
        }

        String missedPoints = 'Points to cover: ';
        if (subject['description'] != null &&
            subject['description'] is List &&
            subject['description'].isNotEmpty) {
          missedPoints += (subject['description'] as List)
              .map((task) => task['title'])
              .join(', ');
        } else if (subject['description'] != null &&
            subject['description'] is String &&
            subject['description'].isNotEmpty) {
          missedPoints += subject['description'];
        } else {
          missedPoints += 'All points in this section.';
        }

        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            leading: const Icon(Icons.calendar_today_outlined,
                color: Colors.blue, size: 28),
            title: Text(
                '${_getDayName(freeSlot['column'])}: Study $materialDetails',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(timeSlot,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  missedPoints,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
