import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../models/alarm_model.dart';
import '../../widgets/neumorphic_container.dart';

class AlarmDialog extends StatefulWidget {
  final AlarmModel? alarmToEdit;
  final Function(AlarmModel) onSave;

  const AlarmDialog({super.key, this.alarmToEdit, required this.onSave});

  @override
  State<AlarmDialog> createState() => _AlarmDialogState();
}

class _AlarmDialogState extends State<AlarmDialog> {
  late TimeOfDay _selectedTime;
  late List<int> _selectedDays;
  late bool _isOnce;

  final List<String> _dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.alarmToEdit?.time ?? TimeOfDay.now();
    _selectedDays = List<int>.from(
      widget.alarmToEdit?.selectedDays ?? [1, 2, 3, 4, 5, 6, 7],
    );
    _isOnce = widget.alarmToEdit?.isOnce ?? false;
  }

  Future<void> _pickTime() async {
    HapticFeedback.lightImpact();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryDark,
              onPrimary: Colors.white,
              surface: AppColors.background,
              onSurface: AppColors.primaryDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  String _computeTitle() {
    if (_isOnce) return "Once";
    if (_selectedDays.length == 7) return "Everyday";
    if (_selectedDays.length == 5 &&
        _selectedDays.contains(1) && _selectedDays.contains(2) &&
        _selectedDays.contains(3) && _selectedDays.contains(4) &&
        _selectedDays.contains(5)) {
      return "Weekdays";
    }
    if (_selectedDays.length == 2 &&
        _selectedDays.contains(6) && _selectedDays.contains(7)) {
      return "Weekends";
    }
    if (_selectedDays.isEmpty) return "Once";

    final sortedDays = List<int>.from(_selectedDays)..sort();
    return sortedDays.map((d) => _dayNames[d - 1].toUpperCase()).join("   ");
  }

  void _toggleDay(int dayIndex) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_isOnce) _isOnce = false;
      if (_selectedDays.contains(dayIndex)) {
        _selectedDays.remove(dayIndex);
      } else {
        _selectedDays.add(dayIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int hour = _selectedTime.hourOfPeriod == 0 ? 12 : _selectedTime.hourOfPeriod;
    String min = _selectedTime.minute.toString().padLeft(2, '0');
    String period = _selectedTime.period == DayPeriod.am ? "AM" : "PM";

    // Validation Logic: jodi "isOnce" true hoy othoba list e kono din thake, taholei save kora jabe
    bool canSave = _isOnce || _selectedDays.isNotEmpty;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: NeumorphicContainer(
        borderRadius: 28,
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.alarmToEdit == null ? "ADD ALARM" : "EDIT ALARM",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 1.5,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 20),

              // Time Picker
              GestureDetector(
                onTap: _pickTime,
                child: NeumorphicContainer(
                  borderRadius: 20,
                  color: AppColors.accentLightYellow.withValues(alpha: 0.55),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${hour.toString().padLeft(2, '0')}:$min",
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        period,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ==========================================
              // ONLY FOR ONCE OPTION
              // ==========================================
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _isOnce = !_isOnce;
                    if (_isOnce) {
                      _selectedDays.clear();
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _isOnce
                        ? AppColors.primaryDark.withValues(alpha: 0.06)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isOnce
                          ? AppColors.primaryDark
                          : AppColors.shadowDark.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isOnce
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: _isOnce
                                ? AppColors.primaryDark
                                : AppColors.textGrey,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Only for once",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Ring once",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGrey.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==========================================
              // 7 DAYS WEEK SELECTION
              // ==========================================
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "REPEAT DAYS",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.textGrey.withValues(alpha: 0.9),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final dayIndex = index + 1;
                  final isSelected = !_isOnce && _selectedDays.contains(dayIndex);
                  final dayShort = _dayNames[index].substring(0, 1);

                  return GestureDetector(
                    onTap: () => _toggleDay(dayIndex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.primaryDark
                            : AppColors.cardBg,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryDark
                              : AppColors.shadowDark.withValues(alpha: 0.5),
                          width: 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          dayShort,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? const Color(0xFFFFC444)
                                : AppColors.textGrey,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 30),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "CANCEL",
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        disabledBackgroundColor: AppColors.shadowDark.withValues(alpha: 0.4), // Disabled hoye thakle ey color hobe
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: canSave ? 2 : 0,
                      ),
                      // Jodio canSave false hoy, tahole onPressed 'null' hobe, jate click kora na jay
                      onPressed: canSave
                          ? () {
                        HapticFeedback.mediumImpact();
                        final updated = AlarmModel(
                          id: widget.alarmToEdit?.id ??
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          title: _computeTitle(),
                          time: _selectedTime,
                          isEnabled: widget.alarmToEdit?.isEnabled ?? true,
                          selectedDays: _selectedDays,
                          isOnce: _isOnce,
                        );
                        widget.onSave(updated);
                        Navigator.pop(context);
                      }
                          : null,
                      child: Text(
                        "SAVE",
                        style: TextStyle(
                          color: canSave ? Colors.white : AppColors.textGrey.withValues(alpha: 0.6), // Disabled thakle text gray hobe
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
