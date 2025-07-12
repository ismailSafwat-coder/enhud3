import 'package:enhud/pages/notifications/notifications.dart';
import 'package:enhud/main.dart';
import 'package:enhud/widget/alertdialog/dropdownbuttoms.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Sleep extends StatefulWidget {
  const Sleep({super.key});

  @override
  State<Sleep> createState() => _SleepState();
}

class _SleepState extends State<Sleep> {
  TimeOfDay? sleepTime;
  TimeOfDay? wakeUpTime;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadSavedTimes();
  }

  void _initNotifications() async {
    await Notifications().initNotification();
  }

  void _loadSavedTimes() async {
    if (mybox != null && mybox!.isOpen) {
      final savedSleepTime = mybox!.get('sleepTime');
      final savedWakeUpTime = mybox!.get('wakeUpTime');

      if (savedSleepTime != null) {
        setState(() {
          sleepTime = TimeOfDay(
              hour: savedSleepTime['hour'], minute: savedSleepTime['minute']);
        });
      }

      if (savedWakeUpTime != null) {
        setState(() {
          wakeUpTime = TimeOfDay(
              hour: savedWakeUpTime['hour'], minute: savedWakeUpTime['minute']);
        });
      }
    }
  }

  Future<void> _saveAndScheduleNotifications() async {
    if (mybox != null && mybox!.isOpen) {
      // Save sleep time
      if (sleepTime != null) {
        await mybox!.put('sleepTime',
            {'hour': sleepTime!.hour, 'minute': sleepTime!.minute});

        // Schedule sleep notification
        await Notifications().scheduleNotification(
          week: 0,
          row: 0,
          column: 0,
          title: "Time to Sleep",
          body: "It's your bedtime. Good night!",
          hour: sleepTime!.hour,
          minute: sleepTime!.minute,
        );
      }

      // Save wake-up time
      if (wakeUpTime != null) {
        await mybox!.put('wakeUpTime',
            {'hour': wakeUpTime!.hour, 'minute': wakeUpTime!.minute});

        // Schedule wake-up notification
        await Notifications().scheduleNotification(
          week: 0,
          row: 1,
          column: 0,
          title: "Time to Wake Up",
          body: "Good morning! It's time to start your day.",
          hour: wakeUpTime!.hour,
          minute: wakeUpTime!.minute,
        );
      }
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Sleep schedule saved and notifications set')));
    }
  }

  Future<void> _selectTime(BuildContext context, bool isSleepTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isSleepTime
          ? sleepTime ?? TimeOfDay.now()
          : wakeUpTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isSleepTime) {
          sleepTime = picked;
        } else {
          wakeUpTime = picked;
        }
      });
    }
  }

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat('h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFFdedede))),
            child: Image.asset(
              'images/sleep.png',
              width: 150,
              height: 150,
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            width: 300,
            margin: const EdgeInsets.only(left: 5),
            height: MediaQuery.sizeOf(context).height * 0.39,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFdedede))),
            child: Column(
              children: [
                const Text(
                  'Enter Your Available Time',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Sleep Time',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () => _selectTime(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFdedede)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          sleepTime != null
                              ? formatTimeOfDay(sleepTime!)
                              : 'Default',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Wake-Up Time',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () => _selectTime(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFdedede)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          wakeUpTime != null
                              ? formatTimeOfDay(wakeUpTime!)
                              : 'Default',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Snooze Duration',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    MyDropdownbuttoms()
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Remind Before Time',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    MyDropdownbuttoms()
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _saveAndScheduleNotifications,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'Save and Set Notifications',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
