import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alarm/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../models/alarm_model.dart';
import '../services/alarm_service.dart';
import '../widgets/custom_bottom_nav.dart';
import 'alarm/alarm_dialog.dart';
import 'alarm/alarm_view.dart';
import 'clock/clock_view.dart';
import 'stopwatch/stopwatch_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  StreamSubscription<AlarmSettings>? _ringSubscription;

  List<AlarmModel> _alarms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAlarms(); // অ্যাপ ওপেন হলে স্টোরেজ থেকে অ্যালার্ম লোড করবে

    _ringSubscription = Alarm.ringStream.stream.listen((alarmSettings) {
      setState(() {
        final index = _alarms.indexWhere((a) {
          final aId = int.parse(a.id.replaceAll(RegExp(r'[^0-9]'), '')).abs() % 100000;
          return aId == alarmSettings.id;
        });
        if (index != -1 && _alarms[index].isOnce) {
          _alarms[index].isEnabled = false;
          _saveAlarmsToStorage(); // স্টেট চেঞ্জ হওয়ার পর সেভ করা
        }
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.alarm, color: AppColors.redAccent, size: 28),
                SizedBox(width: 10),
                Text("ALARM RINGING!", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
              ],
            ),
            content: Text(alarmSettings.notificationBody, style: const TextStyle(fontSize: 16)),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    HapticFeedback.heavyImpact();
                    await Alarm.stop(alarmSettings.id);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text("STOP", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      }
    });
  }

  // ==========================================
  // STORAGE LOGIC (LOAD & SAVE)
  // ==========================================
  Future<void> _loadSavedAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String? alarmsJson = prefs.getString('saved_alarms');

    if (alarmsJson != null && alarmsJson.isNotEmpty) {
      final List<dynamic> decoded = json.decode(alarmsJson);
      setState(() {
        _alarms = decoded.map((item) => AlarmModel.fromJson(item)).toList();
      });
    } else {
      // প্রথমবার অ্যাপ ওপেন করলে UI সুন্দর দেখানোর জন্য ২টি ডিফল্ট অফ করা অ্যালার্ম
      setState(() {
        _alarms = [
          AlarmModel(
            id: "1",
            title: "Everyday",
            time: const TimeOfDay(hour: 6, minute: 30),
            isEnabled: false,
            selectedDays: [1, 2, 3, 4, 5, 6, 7],
            isOnce: false,
          ),
          AlarmModel(
            id: "2",
            title: "SAT   MON",
            time: const TimeOfDay(hour: 8, minute: 0),
            isEnabled: false,
            selectedDays: [1, 6],
            isOnce: false,
          ),
        ];
      });
      _saveAlarmsToStorage();
    }

    setState(() {
      _isLoading = false;
    });

    _initAlarms();
  }

  Future<void> _saveAlarmsToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(_alarms.map((a) => a.toJson()).toList());
    await prefs.setString('saved_alarms', encodedData);
  }

  void _initAlarms() {
    for (final alarm in _alarms) {
      if (alarm.isEnabled) {
        AlarmService.scheduleAlarm(alarm);
      }
    }
  }

  @override
  void dispose() {
    _ringSubscription?.cancel();
    super.dispose();
  }

  void _showTimeRemainingToast(TimeOfDay time) {
    final now = DateTime.now();
    DateTime alarmTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }

    final diff = alarmTime.difference(now);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    String message = "Alarm will ring in ";
    if (hours > 0) message += "$hours hour${hours > 1 ? 's' : ''} and ";
    message += "$minutes minute${minutes > 1 ? 's' : ''}.";

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primaryDark.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _addOrUpdateAlarm(AlarmModel alarm) {
    setState(() {
      final index = _alarms.indexWhere((a) => a.id == alarm.id);
      if (index != -1) {
        _alarms[index] = alarm;
      } else {
        _alarms.add(alarm);
      }
    });

    _saveAlarmsToStorage(); // সেভ করা হলো

    if (alarm.isEnabled) {
      AlarmService.scheduleAlarm(alarm);
      _showTimeRemainingToast(alarm.time);
    } else {
      AlarmService.cancelAlarm(alarm);
    }
  }

  void _deleteAlarm(int index) {
    final deletedAlarm = _alarms[index];
    AlarmService.cancelAlarm(deletedAlarm);
    setState(() {
      _alarms.removeAt(index);
    });
    _saveAlarmsToStorage(); // ডিলিট করার পর সেভ করা হলো
  }

  void _toggleAlarm(int index, bool val) {
    setState(() {
      _alarms[index].isEnabled = val;
    });

    _saveAlarmsToStorage(); // টগল করার পর সেভ করা হলো

    if (val) {
      AlarmService.scheduleAlarm(_alarms[index]);
      _showTimeRemainingToast(_alarms[index].time);
    } else {
      AlarmService.cancelAlarm(_alarms[index]);
    }
  }

  void _openAddAlarmModal() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlarmDialog(
        onSave: (newAlarm) {
          _addOrUpdateAlarm(newAlarm);
          setState(() => _currentIndex = 1);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryDark))
            : IndexedStack(
          index: _currentIndex,
          children: [
            const ClockView(),
            AlarmView(
              alarms: _alarms,
              onAddOrUpdateAlarm: _addOrUpdateAlarm,
              onDeleteAlarm: _deleteAlarm,
              onToggleAlarm: _toggleAlarm,
            ),
            const StopwatchView(),
          ],
        ),
      ),
      floatingActionButton: (_currentIndex == 1 && !_isLoading)
          ? FloatingActionButton(
        onPressed: _openAddAlarmModal,
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFF5252), Color(0xFFFF7E7E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2),
            boxShadow: [
              BoxShadow(color: const Color(0xFFFF5252).withValues(alpha: 0.45), blurRadius: 14, offset: const Offset(0, 6)),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}