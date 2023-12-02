import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/common/time_management.dart';
import 'package:planner/common/view/topbar.dart';
import 'package:planner/models/task.dart';
import 'package:planner/view/monthlyTaskView.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:planner/models/event.dart';
import 'package:planner/view/weekView.dart';

class MonthView extends StatefulWidget {
  const MonthView({super.key});

  @override
  _MonthViewState createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DatabaseService db = DatabaseService();
  List<Task> todayTasks = [];
  List<Event> todayEvents = [];
  bool forEvents = true;

  // Add a PageController for handling page navigation
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Add a listener to the PageController to update the focusedDay
    _pageController.addListener(() {
      setState(() {
        _focusedDay = _pageController.page == 0
            ? _focusedDay.subtract(const Duration(days: 30))
            : _focusedDay.add(const Duration(days: 30));
      });
    });
  }

  @override
  void dispose() {
    // Dispose of the PageController to prevent memory leaks
    _pageController.dispose();
    super.dispose();
  }

  void fetchTodayEvents(DateTime selectedDate) async {
    DateTime dateStart =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    todayEvents = await db.getListOfEventsInDay(date: dateStart);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        )),
        backgroundColor: Colors.white,
        title: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Tasks ',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  Switch(
                    // thumb color (round icon)
                    activeColor: Colors.white,
                    activeTrackColor: Colors.cyan,
                    inactiveThumbColor: Colors.blueGrey.shade600,
                    inactiveTrackColor: Colors.grey.shade400,
                    splashRadius: 50.0,
                    value: forEvents,
                    onChanged: (value) {
                      setState(() {
                        forEvents = value;
                      });
                      if (!forEvents) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MonthlyTaskView(),
                          ),
                        );
                      }
                    },
                  ),
                  const Text(
                    ' Events',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [Icon(Icons.search)],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => WeekView()));
          }
        },
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime(DateTime.now().year, DateTime.now().month, 1),
              lastDay:
                  DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });

                  fetchTodayEvents(selectedDay);
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                // Update the focusedDay when navigating to previous/next months
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
                leftChevronIcon: GestureDetector(
                  onTap: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                  child: const Icon(Icons.arrow_back),
                ), // Set custom left chevron icon
                rightChevronIcon: GestureDetector(
                  onTap: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                  child: const Icon(Icons.arrow_forward),
                ), // Set custom right chevron icon
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: todayEvents.length,
                itemBuilder: (context, index) {
                  return EventCard(
                      eventsToday: todayEvents,
                      index: index,
                      date: _selectedDay!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
