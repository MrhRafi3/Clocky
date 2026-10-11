import 'package:flutter/material.dart';

class AlarmModel {
  String id;
  String title;
  TimeOfDay time;
  bool isEnabled;
  List<int> selectedDays;
  bool isOnce;

  AlarmModel({
    required this.id,
    required this.title,
    required this.time,
    this.isEnabled = true,
    List<int>? selectedDays,
    this.isOnce = false,
  }) : selectedDays = selectedDays ?? [1, 2, 3, 4, 5, 6, 7];

  String get formattedHourMinute {
    int h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    String min = time.minute.toString().padLeft(2, '0');
    String hour = h.toString().padLeft(2, '0');
    return "$hour:$min";
  }

  String get period => time.period == DayPeriod.am ? "AM" : "PM";

  // JSON থেকে ডাটা পড়ার জন্য
  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'] as String,
      title: json['title'] as String,
      time: TimeOfDay(
        hour: json['timeHour'] as int,
        minute: json['timeMinute'] as int,
      ),
      isEnabled: json['isEnabled'] as bool,
      selectedDays: List<int>.from(json['selectedDays'] ?? [1, 2, 3, 4, 5, 6, 7]),
      isOnce: json['isOnce'] ?? false,
    );
  }

  // ডাটা JSON-এ সেভ করার জন্য
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'timeHour': time.hour,
      'timeMinute': time.minute,
      'isEnabled': isEnabled,
      'selectedDays': selectedDays,
      'isOnce': isOnce,
    };
  }
}
