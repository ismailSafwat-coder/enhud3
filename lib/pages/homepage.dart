import 'package:enhud/core/core.dart';
import 'package:enhud/main.dart';
import 'package:enhud/models/exam_result.dart';
import 'package:enhud/pages/WeeklyReport.dart';
import 'package:enhud/pages/notificationscreen.dart';
import 'package:enhud/pages/settings/accountinfo_page.dart';
import 'package:enhud/pages/todayschedule.dart';
import 'package:enhud/screens/0_generation_home_screen.dart';
import 'package:enhud/screens/1_material_selection_screen.dart';
import 'package:enhud/screens/6_results_screen.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class StudyMaterial {
  final String title;
  final String unit;
  final double studyProgress;

  StudyMaterial(
      {required this.title, required this.unit, this.studyProgress = 0.0});
}

class TestMaterial {
  final String title;
  final String unit;
  final ExamResult? examResult;

  TestMaterial({required this.title, required this.unit, this.examResult});
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late Future<List<StudyMaterial>> _studyingFuture;
  late Future<List<TestMaterial>> _testsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _studyingFuture = _getStudyingMaterials();
    _testsFuture = _getTestMaterials();
  }

  Future<List<StudyMaterial>> _getStudyingMaterials() async {
    if (mybox == null || !mybox!.isOpen) return [];
    final scheduleItems = mybox!.get('noti', defaultValue: []);
    final studyMaterials = scheduleItems
        .where((item) => item is Map && item['category'] == 'Study')
        .toList();

    List<StudyMaterial> progressList = [];
    for (var material in studyMaterials) {
      double studyProgress = 0.0;
      if (material['description'] is List &&
          (material['description'] as List).isNotEmpty) {
        var tasks = (material['description'] as List);
        var completedTasks = tasks.where((task) => task['done'] == true).length;
        studyProgress = completedTasks / tasks.length;
      }
      progressList.add(StudyMaterial(
        title: material['title'] ?? 'Unknown',
        unit: material['unit'] ?? '',
        studyProgress: studyProgress,
      ));
    }
    return progressList;
  }

  Future<List<TestMaterial>> _getTestMaterials() async {
    if (mybox == null || !mybox!.isOpen) return [];
    final scheduleItems = mybox!.get('noti', defaultValue: []);
    final examResultsData = mybox!.get('exam_results', defaultValue: []);

    final examResults = examResultsData
        .map((data) => data is Map
            ? ExamResult.fromJson(Map<String, dynamic>.from(data))
            : null)
        .where((result) => result != null)
        .cast<ExamResult>()
        .toList();

    final studyMaterials = scheduleItems
        .where((item) => item is Map && item['category'] == 'Study')
        .toList();

    List<TestMaterial> testList = [];
    for (var material in studyMaterials) {
      ExamResult? relatedExam;
      try {
        relatedExam = examResults.lastWhere(
          (result) =>
              result.material.toLowerCase() ==
              (material['title'] as String).toLowerCase(),
        );
      } catch (e) {
        relatedExam = null;
      }
      testList.add(TestMaterial(
        title: material['title'] ?? 'Unknown',
        unit: material['unit'] ?? '',
        examResult: relatedExam,
      ));
    }
    return testList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadData();
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFebebeb))),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const AccountinfoPage()));
                          },
                          child: const CircleAvatar(
                            radius: 25,
                            backgroundImage:
                                AssetImage('images/accountimage.png'),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const WeeklyReport()));
                            },
                            child: Image.asset('images/message.png')),
                        const SizedBox(width: 10),
                        InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationsScreen()));
                            },
                            child: Image.asset('images/notificationvbell.png')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF7d7d7d))),
                    child: const Todayschedule(),
                  ),
                  const SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStudyCard(),
                        const SizedBox(width: 10),
                        _buildTestsCard(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Motivational Messages :',
                              style: commonTextStyle),
                          const SizedBox(height: 10),
                          MotivationalMessages(),
                        ],
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudyCard() {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Materials Studying :',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
          const Divider(height: 20),
          FutureBuilder<List<StudyMaterial>>(
            future: _studyingFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.isEmpty)
                return const Text("No materials to study.");

              final materials = snapshot.data!;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  return materilsfile(materials[index]);
                },
                separatorBuilder: (context, index) => const Divider(height: 20),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTestsCard() {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Materials Tests :',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
          const Divider(height: 20),
          FutureBuilder<List<TestMaterial>>(
            future: _testsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.isEmpty)
                return const Text("No tests available.");

              final materials = snapshot.data!;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  return testfile(materials[index]);
                },
                separatorBuilder: (context, index) => const Divider(height: 20),
              );
            },
          ),
        ],
      ),
    );
  }

  Row materilsfile(StudyMaterial material) {
    return Row(children: [
      Image.asset('images/paper.png',
          fit: BoxFit.contain, width: 35, height: 30),
      const SizedBox(width: 5),
      Text('${material.title} ${material.unit}', style: midTextStyle),
      const Spacer(),
      CircularPercentIndicator(
        animation: true,
        radius: 25,
        percent: material.studyProgress,
        lineWidth: 5,
        progressColor: Colors.green,
        center: Text(
          "${(material.studyProgress * 100).toStringAsFixed(0)}%",
          style: midTextStyle,
        ),
      )
    ]);
  }

  Row testfile(TestMaterial material) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(
        children: [
          Image.asset('images/paper.png',
              fit: BoxFit.contain, width: 35, height: 30),
          const SizedBox(width: 5),
          Text('${material.title} ${material.unit}', style: midTextStyle),
        ],
      ),
      material.examResult != null
          ? CircularPercentIndicator(
              animation: true,
              radius: 25,
              percent: material.examResult!.percentage / 100,
              lineWidth: 5,
              progressColor: Colors.blue,
              center: Text(
                "${material.examResult!.percentage.toStringAsFixed(0)}%",
                style: midTextStyle,
              ),
            )
          : const Text(
              '-',
              style: midTextStyle,
            ),
      MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color:
            material.examResult != null ? Colors.blue : const Color(0xFF58d67e),
        textColor: Colors.white,
        onPressed: () {
          if (material.examResult != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        ResultsScreen(result: material.examResult!)));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const GenerationHomeScreen()));
          }
        },
        child: Text(material.examResult != null ? 'Results' : 'Start'),
      )
    ]);
  }
}

class MotivationalMessages extends StatelessWidget {
  final List<String> messages = [
    "“Be like a star that never stops shining even in the darkest nights.”",
    "“Despite the difficulties you may face, always remember that every success begins with one decision to start.”",
    "“Self-confidence is the most powerful weapon in facing challenges and achieving goals.”",
    "“Success is the accumulationof small efforts day after day, so do not underestimate any small effort you have made.”",
  ];

  MotivationalMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: messages.map((msg) {
          return InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  backgroundColor: const Color(0xFFafcdf8),
                  title: const Text('Motivation',
                      style: TextStyle(
                          color: Color(0xFF4A90E2),
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  content: Text(msg,
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xFF333333)),
                      textAlign: TextAlign.center),
                  actions: [
                    Center(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                        ),
                        child: const Text('Got it!',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                  contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                  actionsPadding: const EdgeInsets.only(bottom: 16),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(16),
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFafcdf8),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(msg,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
