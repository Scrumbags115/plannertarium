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
import 'package:planner/canvas/flutter_student_embed/lib/models/planner_item.dart';
import 'package:planner/canvas/flutter_student_embed/lib/screens/calendar/planner_fetcher.dart';
import 'package:planner/canvas/flutter_student_embed/lib/utils/common_widgets/empty_panda_widget.dart';
import 'package:planner/canvas/flutter_student_embed/lib/utils/common_widgets/error_panda_widget.dart';
import 'package:planner/canvas/flutter_student_embed/lib/utils/common_widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

import 'calendar_day_list_tile.dart';

class CalendarDayPlanner extends StatefulWidget {
  final DateTime _day;

  final Function(PlannerItem item) onItemSelected;

  const CalendarDayPlanner(this._day, {super.key, @required this.onItemSelected});

  @override
  State<StatefulWidget> createState() => CalendarDayPlannerState();
}

class CalendarDayPlannerState extends State<CalendarDayPlanner> {
  @override
  Widget build(BuildContext context) {
    return Selector<PlannerFetcher, AsyncSnapshot<List<PlannerItem>>>(
      selector: (_, fetcher) => fetcher.getSnapshotForDate(widget._day),
      builder: (_, snapshot, __) {
        Widget body;
        if (snapshot.hasError) {
          body = ErrorPandaWidget(L10n(context).errorLoadingEvents, _refresh, header: const SizedBox(height: 32));
        } else if (!snapshot.hasData) {
          body = const LoadingIndicator();
        } else {
          if (snapshot.data.isEmpty) {
            body = EmptyPandaWidget(
              svgPath: 'assets/svg/panda-no-events.svg',
              title: L10n(context).noEventsTitle,
              subtitle: L10n(context).noEventsMessage,
              header: const SizedBox(height: 32),
            );
          } else {
            body = CalendarDayList(snapshot.data, widget.onItemSelected);
          }
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: body,
        );
      },
    );
  }

  Future<void> _refresh() async {
    PlannerFetcher.notifyDatesChanged([widget._day]);
    await Provider.of<PlannerFetcher>(context, listen: false).refreshItemsForDate(widget._day);
  }
}

class CalendarDayList extends StatelessWidget {
  final List<PlannerItem> _plannerItems;
  final Function(PlannerItem item) onItemSelected;

  const CalendarDayList(this._plannerItems, this.onItemSelected, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 64), // Large bottom padding to account for FAB
      itemCount: _plannerItems.length,
      itemBuilder: (context, index) => _dayTile(context, _plannerItems[index], index),
    );
  }

  Widget _dayTile(BuildContext context, PlannerItem plannerItem, int index) {
    return CalendarDayListTile(plannerItem, onItemSelected);
  }
}
