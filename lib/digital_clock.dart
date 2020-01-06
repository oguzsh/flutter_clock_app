// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum _Element { background, text, shadow }

final _lightTheme = {
  _Element.background: Colors.white,
  _Element.text: Color.fromRGBO(0, 5, 33, 1),
  _Element.shadow: Colors.red,
};

final _darkTheme = {
  _Element.background: Color.fromRGBO(0, 5, 33, 1),
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF00AA),
};

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    // Set landspace mode
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      // _timer = Timer(
      //   Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final location = widget.model.location;
    final temp = widget.model.temperatureString;
    final weather = widget.model.weatherString;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 4;
    final defaultStyle = TextStyle(
        color: colors[_Element.text],
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w300,
        fontSize: fontSize,
        shadows: [Shadow(color: colors[_Element.shadow])]);

    return Container(
      color: colors[_Element.background],
      child: Center(
        child: DefaultTextStyle(
            style: defaultStyle,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      hour + ":",
                      style: TextStyle(
                          color: colors[_Element.text],
                          fontWeight: FontWeight.w200,
                          shadows: [
                            Shadow(
                                color: Colors.white,
                                blurRadius: 10,
                                offset: Offset(0, 3.0)),
                          ]),
                    ),
                    Text(minute,
                        style: TextStyle(
                          fontWeight: FontWeight.w200,
                          color: Color.fromRGBO(255, 0, 170, 1),
                          shadows: [
                            Shadow(
                                color: (colors == _lightTheme)
                                    ? Colors.transparent
                                    : colors[_Element.shadow],
                                blurRadius: 10,
                                offset: Offset(0, 3.0))
                          ],
                        ))
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2,
                                    color: Color.fromRGBO(255, 0, 170, 1)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3))),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                location.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 20, color: colors[_Element.text]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 2,
                                      color: Color.fromRGBO(255, 0, 170, 1)),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3))),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  weather.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: colors[_Element.text]),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2,
                                    color: Color.fromRGBO(255, 0, 170, 1)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3))),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                temp.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 20, color: colors[_Element.text]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }
}
