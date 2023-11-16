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

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:planner/canvas/flutter_student_embed/lib/utils/design/student_theme.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info/package_info.dart';

import '../l10n/app_localizations.dart';

class CrashScreen extends StatelessWidget {
  final FlutterErrorDetails error;

  const CrashScreen(this.error, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModalRoute.of(context)?.canPop ?? false
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              iconTheme: Theme.of(context).iconTheme,
            )
          : null,
      body: _body(context),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[_errorDetailsButton(context)],
      ),
    );
  }

  Center _body(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset('assets/svg/panda-not-supported.svg'),
              const SizedBox(height: 64),
              Text(
                L10n(context).crashScreenTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                L10n(context).crashScreenMessage,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorDetailsButton(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([PackageInfo.fromPlatform(), DeviceInfoPlugin().androidInfo]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        PackageInfo packageInfo = snapshot.data[0];
        AndroidDeviceInfo deviceInfo = snapshot.data[1];
        return FlatButton(
          onPressed: () => _showDetailsDialog(context, packageInfo, deviceInfo),
          child: Text(
            L10n(context).crashScreenViewDetails,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        );
      },
    );
  }

  String _getFullErrorMessage() {
    String message = '';
    try {
      message = error.exception.toString();
    } catch (e) {
      // Intentionally left blank
    }
    return '$message\n\n${error.stack.toString()}';
  }

  _showDetailsDialog(BuildContext context, PackageInfo packageInfo, AndroidDeviceInfo deviceInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.all(0),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            padding: const EdgeInsets.all(8),
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                title: Text(L10n(context).crashDetailsAppVersion),
                subtitle: Text('${packageInfo.version} (${packageInfo.buildNumber})'),
              ),
              ListTile(
                title: Text(L10n(context).crashDetailsDeviceModel),
                subtitle: Text('${deviceInfo.manufacturer} ${deviceInfo.model}'),
              ),
              ListTile(
                title: Text(L10n(context).crashDetailsAndroidVersion),
                subtitle: Text(deviceInfo.version.release),
              ),
              ExpansionTile(
                title: Text(L10n(context).crashDetailsFullMessage),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                    child: Container(
                      key: const Key('full-error-message'),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: StudentTheme.of(context).nearSurfaceColor,
                          borderRadius: const BorderRadius.all(Radius.circular(8))),
                      child: Text(
                        _getFullErrorMessage(),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(L10n(context).done.toUpperCase()),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
