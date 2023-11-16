// Copyright (C) 2020 - present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:planner/canvas/flutter_student_embed/lib/l10n/app_localizations.dart';
import 'package:planner/canvas/flutter_student_embed/lib/models/course.dart';
import 'package:planner/canvas/flutter_student_embed/lib/network/utils/api_prefs.dart';
import 'package:planner/canvas/flutter_student_embed/lib/utils/common_widgets/appbar_dynamic_style.dart';
import 'package:planner/canvas/flutter_student_embed/lib/utils/common_widgets/empty_panda_widget.dart';
import 'package:planner/canvas/flutter_student_embed/lib/utils/common_widgets/error_panda_widget.dart';
import 'package:planner/canvas/flutter_student_embed/lib/utils/common_widgets/loading_indicator.dart';
import 'package:planner/canvas/flutter_student_embed/lib/utils/service_locator.dart';

import 'calendar_filter_list_interactor.dart';

class CalendarFilterListScreen extends StatefulWidget {
  final Set<String> _selectedCourses;

  const CalendarFilterListScreen(this._selectedCourses, {super.key});

  @override
  State<StatefulWidget> createState() => CalendarFilterListScreenState();
}

class CalendarFilterListScreenState extends State<CalendarFilterListScreen> {
  Future<List<Course>> _coursesFuture;
  Set<String> selectedContextIds = {}; // Public, to allow for testing
  final GlobalKey<RefreshIndicatorState> _refreshCoursesKey = GlobalKey<RefreshIndicatorState>();
  bool selectAllIfEmpty = true;
  int courseLength = -1;

  @override
  void initState() {
    _coursesFuture = locator.get<CalendarFilterListInteractor>().getCoursesForUser(isRefresh: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // An empty list is interpreted as all courses selected
        Navigator.pop(context, courseLength == selectedContextIds.length ? <String>{} : selectedContextIds);
        return false;
      },
      child: Scaffold(
        appBar: dynamicStyleAppBar(
          context: context,
          appBar: AppBar(
            title: Text(L10n(context).calendars),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(L10n(context).calendarSelectFavoriteCalendars, style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(height: 24.0),
            Expanded(child: _body())
          ],
        ),
      ),
    );
  }

  Widget _body() {
    return FutureBuilder(
        future: _coursesFuture,
        builder: (context, snapshot) {
          Widget body;
          List<Course> courses;
          if (snapshot.hasError) {
            body = ErrorPandaWidget(L10n(context).errorLoadingCourses, () => _refreshCoursesKey.currentState.show());
          } else if (snapshot.hasData) {
            courses = snapshot.data;
            courseLength = courses.length;
            courseLength++;
            if (selectedContextIds.isEmpty && selectAllIfEmpty) {
              // We only want to do this the first time we load, otherwise if the user ever deselects all the
              // contexts, then they will all automatically be put into the selected list
              // Note: As unlikely as it is, if the user deselects all contexts then all contexts will be returned in the calendar

              // List will be empty when all courses are selected (on first load)
              selectedContextIds.addAll(courses.map((c) => 'course_${c.id}').toList());
              selectedContextIds.add('user_${ApiPrefs.getUser().id}');
                          selectAllIfEmpty = false;
            }
            body = (courses.isEmpty)
                ? EmptyPandaWidget(
                    svgPath: 'assets/svg/panda-book.svg',
                    title: L10n(context).noCoursesTitle,
                    subtitle: L10n(context).noCoursesMessage,
                  )
                : _calendarList(courses);
          } else {
            selectedContextIds.addAll(widget._selectedCourses);
            if (selectedContextIds.isNotEmpty) {
              // The list isn't empty so we don't want to continue checking if the list is empty above, and
              // select everything again (though if the user doesn't select anything and they go back, everything will be
              // selected).
              selectAllIfEmpty = false;
            }
            return const LoadingIndicator();
          }

          return RefreshIndicator(
            key: _refreshCoursesKey,
            onRefresh: () {
              _coursesFuture = locator.get<CalendarFilterListInteractor>().getCoursesForUser(isRefresh: true);
              setState(() {});
              return _coursesFuture;
            },
            child: body,
          );
        });
  }

  ListView _calendarList(List<Course> courses) {
    final user = ApiPrefs.getUser();
    List<Widget> listItems = [
      LabeledCheckbox(
        label: user.name,
        padding: const EdgeInsets.only(left: 2.0, right: 16.0),
        value: selectedContextIds.contains('user_${user.id}'),
        onChanged: (bool newValue) {
          setState(() {
            newValue
                ? selectedContextIds.add('user_${user.id}')
                : selectedContextIds.remove('user_${user.id}');
          });
        }),
      ...courses.map((c) => MergeSemantics(
            child: LabeledCheckbox(
                label: c.name,
                padding: const EdgeInsets.only(left: 2.0, right: 16.0),
                value: selectedContextIds.contains(c.contextFilterId()),
                onChanged: (bool newValue) {
                  setState(() {
                    newValue
                        ? selectedContextIds.add(c.contextFilterId())
                        : selectedContextIds.remove(c.contextFilterId());
                  });
                }),
          ))
    ];
    return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: listItems.length, // Add one for the Courses header
        itemBuilder: (context, index) {
          return listItems[index];
        });
  }
}

// Custom checkbox to better control the padding at the start
class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({super.key, 
    this.label,
    this.padding,
    this.value,
    this.onChanged,
  });

  final String label;
  final EdgeInsets padding;
  final bool value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Checkbox(
              value: value,
              onChanged: (bool newValue) {
                onChanged(newValue);
              },
            ),
            const SizedBox(width: 21.0),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
          ],
        ),
      ),
    );
  }
}
