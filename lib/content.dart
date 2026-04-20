import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'configurations.dart';

class Content extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ContentState();
  }
}

class ContentState extends State<Content> {
  late List<ValueNotifier<bool>> attendanceNotifiers;

  @override
  void initState() {
    super.initState();
    // Create a ValueNotifier for each attendance record
    attendanceNotifiers = List.generate(
      Configurations.attendance.length,
      (index) => ValueNotifier(
        Configurations.attendance[index][1] == 0 ? false : true,
      ),
    );
  }

  @override
  void dispose() {
    for (var notifier in attendanceNotifiers) {
      notifier.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Content"),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: Configurations.attendance.length,
          itemBuilder: (context, count) {
            String date = Configurations.attendance[count][0].toString();
            return ValueListenableBuilder<bool>(
              valueListenable: attendanceNotifiers[count],
              builder: (context, pamarker, child) {
                return GestureDetector(
                  onTap: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) => CupertinoActionSheet(
                        title: Text("Change Attendance"),
                        message: Text(
                          "Mark as ${pamarker ? "Absent" : "Present"}?",
                        ),
                        actions: <CupertinoActionSheetAction>[
                          CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pop(context);
                              attendanceNotifiers[count].value =
                                  !attendanceNotifiers[count].value;
                              Configurations.attendance[count][1] =
                                  attendanceNotifiers[count].value ? 1 : 0;
                            },
                            child: Text("Confirm"),
                          ),
                        ],
                        cancelButton: CupertinoActionSheetAction(
                          onPressed: () => Navigator.pop(context),
                          isDefaultAction: true,
                          child: Text("Cancel"),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(date, style: TextStyle(fontSize: 20)),
                        CircleAvatar(
                          backgroundColor: pamarker ? Colors.green : Colors.red,
                          child: Text(
                            pamarker ? "P" : "A",
                            style: pamarker
                                ? null
                                : TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
