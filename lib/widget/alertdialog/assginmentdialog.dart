import 'package:enhud/main.dart';
import 'package:enhud/widget/studytabletextform.dart';
import 'package:flutter/material.dart';

class StudyDialog extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController taskController;
  final TextEditingController descriptioncontroller;
  final TextEditingController chapter;

  final String type;
  const StudyDialog(
      {super.key,
      required this.formKey,
      required this.taskController,
      required this.descriptioncontroller,
      required this.type,
      required this.chapter});

  @override
  Widget build(BuildContext context) {
    TextEditingController att = TextEditingController();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Material',
                  style: commonTextStyle,
                ),
                const SizedBox(
                  width: 10,
                ),
                Flexible(
                    child: Studytabletextform(
                        controller: taskController,
                        hintText: 'Enter $type Title')),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('unit', style: commonTextStyle),
                const SizedBox(
                  width: 10,
                ),
                Studytabletextform(
                    controller: descriptioncontroller,
                    hintText: 'Enter Description'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('description', style: commonTextStyle),
                const SizedBox(
                  width: 10,
                ),
                Studytabletextform(controller: att, hintText: 'chpter name'),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
