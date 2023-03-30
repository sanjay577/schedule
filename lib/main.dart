import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MaterialApp(
        debugShowCheckedModeBanner: false,
        home: EventCalendarScreen(),
      )));
}

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({Key? key}) : super(key: key);

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;

  Map<String, List> mySelectedEvents = {};

  final titleController = TextEditingController();
  final startController = TextEditingController();
  final endController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _selectedDate = _focusedDay;

    loadPreviousEvents();
  }

  loadPreviousEvents() {
    mySelectedEvents = {
      "2023-09-13": [
        {
          "eventDescp": "22",
          "eventstart": "22",
          "eventend": "11",
          "eventTitle": "111"
        },
        {
          "eventstart": "22",
          "eventend": "11",
          "eventstart": "22",
          "eventend": "11",
          "eventDescp": "22",
          "eventTitle": "22"
        }
      ],
      "2023-09-30": [
        {
          "eventstart": "22",
          "eventend": "11",
          "eventDescp": "22",
          "eventTitle": "22"
        }
      ],
      "2023-0-20": [
        {
          "eventstart": "22",
          "eventend": "11",
          "eventTitle": "ss",
          "eventDescp": "ss"
        }
      ]
    };
  }

  List _listOfDayEvents(DateTime dateTime) {
    if (mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)] != null) {
      return mySelectedEvents[DateFormat('yyyy-MM-dd').format(dateTime)]!;
    } else {
      return [];
    }
  }

  _showAddEventDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '追加新しいイベント',
          textAlign: TextAlign.center,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: '追加タイトル',
              ),
            ),
            TextField(
              controller: startController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: '開始時間'),
            ),
            TextField(
              controller: endController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: '終了時間'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            child: const Text('追加'),
            onPressed: () {
              if (titleController.text.isEmpty &&
                  startController.text.isEmpty &&
                  endController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('タイトルの入力'),
                    duration: Duration(seconds: 2),
                  ),
                );
                //Navigator.pop(context);
                return;
              } else {
                setState(() {
                  if (mySelectedEvents[
                          DateFormat('yyyy-MM-dd').format(_selectedDate!)] !=
                      null) {
                    mySelectedEvents[
                            DateFormat('yyyy-MM-dd').format(_selectedDate!)]
                        ?.add({
                      "eventTitle": titleController.text,
                      "eventstart": startController.text,
                      "eventend": endController.text,
                    });
                  } else {
                    mySelectedEvents[
                        DateFormat('yyyy-MM-dd').format(_selectedDate!)] = [
                      {
                        "eventTitle": titleController.text,
                        "eventstart": startController.text,
                        "eventend": endController.text,
                      }
                    ];
                  }
                });

                print(
                    "New Event for backend developer ${json.encode(mySelectedEvents)}");
                titleController.clear();
                startController.clear();
                endController.clear();
                Navigator.pop(context);
                return;
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('カレンダー'),
      ),
      body: Column(
        children: [
          TableCalendar(
            //``言語コントロール
            locale: 'ja_JP',
            firstDay: DateTime(2023),
            lastDay: DateTime(2024),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDate, selectedDay)) {
                // 選択した日を更新するときに `setState()` を呼び出します
                setState(() {
                  _selectedDate = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                // Call `setState()` when updating calendar format
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              // No need to call `setState()` here
              _focusedDay = focusedDay;
            },
            eventLoader: _listOfDayEvents,
          ),
          ..._listOfDayEvents(_selectedDate!).map(
            (myEvents) => myEvents.isEmpty
                ? Text('')
                : ListTile(
                    leading: const Icon(
                      Icons.done,
                      color: Colors.teal,
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text('追加タイトル:   ${myEvents['eventTitle']}'),
                    ),
                    subtitle: Text('時刻 ${myEvents['eventstart']}' +
                        '～${myEvents['eventend']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          myEvents.clear();
                          mySelectedEvents.clear();
                          myEvents = myEvents;
                        });
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEventDialog(),
        label: const Text('追加'),
      ),
    );
  }
}
