import 'package:flutter/material.dart';
import 'package:planner/common/database.dart';
import 'package:planner/common/view/addTaskButton.dart';
import 'package:planner/common/view/topbar.dart';
import 'package:planner/models/event.dart';
import 'package:planner/view/eventDialogs.dart';
import 'package:planner/view/weekView.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:planner/common/time_management.dart';

class MonthView extends StatefulWidget {
  const MonthView({super.key});

  @override
  _MonthViewState createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DatabaseService db = DatabaseService();
  List<Event> todayEvents = [];
  final PageController _pageController = PageController();
  Map<DateTime, List<Event>> active = {};
  DateTime today = getDateOnly(DateTime.now());
  
  @override
  /// Initializes the state of the widget
  void initState() {
    super.initState();
    asyncInitState();
  }

  /// Performs asynchronous initialization for the widget
  void asyncInitState() async {
    final List<Event> newTodayEvents;
    final Map<DateTime, List<Event>> newMonthlyEvents;
    (newTodayEvents, newMonthlyEvents) =
        await db.getListOfEventsInDateRange(dateStart: getMonthAsDateTime(DateTime.now()), dateEnd: getNextMonthAsDateTime(DateTime.now()));
    todayEvents = newTodayEvents;
    active = newMonthlyEvents;
    setState(() {});
  }

  @override
  /// Disposes of the resources used by the widget
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => WeekView(),
            ));
          }
        },
        child: Scaffold(
          appBar: getTopBar(Event, "monthly", context, this),
          body: Column(
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
                    final newTodayEvents = await db.getListOfEventsInDay(date: selectedDay);
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      todayEvents = newTodayEvents;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                  today = getDateOnly(focusedDay);
                },
                eventLoader: (day) {
                  var taskForDay = active[getDateOnly(day)] ?? [];
                  return taskForDay;
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, tasks) {
                    if (tasks.isNotEmpty) {
                      return Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                      );
                    }
                    return Container();
                  },
                ),
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: todayEvents.length,
                  itemBuilder: (context, index) {
                    Event event = todayEvents[index];
                    return EventCard(
                      eventsToday: todayEvents,
                      index: index,
                      date: _selectedDay!);
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0, 0, 20, 20), // Adjust the value as needed
                  child: ClipOval(
                    child: ElevatedButton(
                      onPressed: () async {
                        Event? newEvent = await addEventFormForDay(context, today);
                        if (newEvent != null) {
                          setState(() {
                            DateTime newEventDateStart = newEvent.timeStart;
                            active[newEventDateStart] = [
                              ...active[newEventDateStart] ?? [],
                              newEvent
                            ];
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        minimumSize: const Size(75, 75),
                      ),
                      child: const Icon(
                        Icons.add_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
