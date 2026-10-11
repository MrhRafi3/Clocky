import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../models/alarm_model.dart';
import '../../widgets/neumorphic_container.dart';
import 'alarm_dialog.dart';
import 'vertical_switch.dart';

class AlarmView extends StatelessWidget {
  final List<AlarmModel> alarms;
  final Function(AlarmModel) onAddOrUpdateAlarm;
  final Function(int) onDeleteAlarm;
  final Function(int, bool) onToggleAlarm;

  const AlarmView({
    super.key,
    required this.alarms,
    required this.onAddOrUpdateAlarm,
    required this.onDeleteAlarm,
    required this.onToggleAlarm,
  });

  void _openAlarmDialog(BuildContext context, [AlarmModel? alarm]) {
    showDialog(
      context: context,
      builder: (context) => AlarmDialog(
        alarmToEdit: alarm,
        onSave: onAddOrUpdateAlarm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.menu, color: AppColors.primaryDark),
              Text(
                "ALARM",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 1.5,
                  color: AppColors.primaryDark.withValues(alpha: 0.8),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_alarm, color: AppColors.primaryDark),
                onPressed: () => _openAlarmDialog(context),
              )
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: alarms.isEmpty
                ? const Center(
              child: Text(
                "No alarms set yet!\nTap '+' to create one.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey, fontSize: 16),
              ),
            )
                : ListView.separated(
              itemCount: alarms.length,
              separatorBuilder: (_, _) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return Dismissible(
                  key: Key(alarm.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    onDeleteAlarm(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Alarm deleted"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      // Tap on Card to Edit
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _openAlarmDialog(context, alarm),
                          child: NeumorphicContainer(
                            height: 125,
                            borderRadius: 25,
                            color: alarm.isEnabled
                                ? AppColors.accentLightYellow
                                : AppColors.cardBg,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  alarm.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryDark
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      alarm.formattedHourMinute,
                                      style: const TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      alarm.period,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryDark
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Vertical switch toggle
                      VerticalSwitch(
                        value: alarm.isEnabled,
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          onToggleAlarm(index, val);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
