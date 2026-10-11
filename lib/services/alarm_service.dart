import 'package:alarm/alarm.dart';
import '../models/alarm_model.dart';

class AlarmService {
  // রিয়েল অ্যালার্ম শিডিউল করা
  static Future<void> scheduleAlarm(AlarmModel alarm) async {
    final now = DateTime.now();
    var alarmDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );

    // সময় পার হয়ে গেলে পরের দিনের জন্য সেট হবে
    if (alarmDateTime.isBefore(now)) {
      alarmDateTime = alarmDateTime.add(const Duration(days: 1));
    }

    final alarmId =
        int.parse(alarm.id.replaceAll(RegExp(r'[^0-9]'), '')).abs() % 100000;

    final alarmSettings = AlarmSettings(
      id: alarmId,
      dateTime: alarmDateTime,
      assetAudioPath: 'assets/audio/alarm.wav',
      loopAudio: true,
      vibrate: true,
      volume: 0.9,
      fadeDuration: 2.0,
      notificationTitle: '⏰ ALARM RINGING!',
      notificationBody:
      alarm.title.isNotEmpty ? alarm.title : 'Tap to turn off alarm',
      enableNotificationOnKill: true,
      androidFullScreenIntent: true,
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  // অ্যালার্ম বন্ধ/বাতিল করা
  static Future<void> cancelAlarm(AlarmModel alarm) async {
    final alarmId =
        int.parse(alarm.id.replaceAll(RegExp(r'[^0-9]'), '')).abs() % 100000;
    await Alarm.stop(alarmId);
  }
}
