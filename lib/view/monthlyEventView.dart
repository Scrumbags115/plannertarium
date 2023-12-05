import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/common/view/topbar.dart';
import 'package:planner/view/dailyEventView.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:planner/models/event.dart';
import 'package:planner/view/weeklyEventView.dart';

class MonthlyEventView extends StatefulWidget {
  const MonthlyEventView({super.key});

  @override
  _MonthlyEventViewState createState() => _MonthlyEventViewState();
}

class _MonthlyEventViewState extends State<MonthlyEventView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DatabaseService db = DatabaseService();
  List<Event> todayEvents = [];
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    asyncInitState();
  }

  void asyncInitState() async {
    final List<Event> newTodayEvents;
    newTodayEvents = await fetchTodayEvents(DateTime.now());
    todayEvents = newTodayEvents;
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<List<Event>> fetchTodayEvents(DateTime selectedDate) async {
    DateTime dateStart =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    return await db.getListOfEventsInDay(date: dateStart);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getTopBar(Event, "monthly", context, this),
      body: Stack(children: [
        GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => WeeklyEventView()));
            }
          },
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 10, 16),
                lastDay: DateTime.utc(2130, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) async {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    final newTodayEvents = await fetchTodayEvents(selectedDay);
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      todayEvents = newTodayEvents;
                    });
                  }
                },
                onDayLongPressed: (selectedDay, focusedDay) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          DailyEventView(date: getDateOnly(selectedDay))));
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  todayBuilder: (context, date, events) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.transparent, // No color for today
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${date.day}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  },
                ),
                headerStyle: HeaderStyle(
                  titleCentered: true, // Center the title
                  formatButtonVisible: false, // Hide the format button
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Flexible(child: SingleDay(getDateOnly(_focusedDay)))
            ],
          ),
        ),
        //AddEventButton(startDate: _focusedDay, events: [])
      ]),
    );
  }
}
