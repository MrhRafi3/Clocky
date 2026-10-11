import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';
import '../../widgets/neumorphic_container.dart';

class LapRecord {
  final int lapNumber;
  final Duration lapTime;
  final Duration totalTime;

  LapRecord({
    required this.lapNumber,
    required this.lapTime,
    required this.totalTime,
  });
}

class StopwatchView extends StatefulWidget {
  const StopwatchView({super.key});

  @override
  State<StopwatchView> createState() => _StopwatchViewState();
}

class _StopwatchViewState extends State<StopwatchView>
    with AutomaticKeepAliveClientMixin {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  final List<LapRecord> _laps = [];
  Duration _lastLapMark = Duration.zero;

  @override
  bool get wantKeepAlive => true;

  void _startTimer() {
    HapticFeedback.mediumImpact();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  void _stopTimer() {
    HapticFeedback.mediumImpact();
    _stopwatch.stop();
    _timer?.cancel();
    setState(() {});
  }

  void _resetTimer() {
    HapticFeedback.heavyImpact();
    _stopwatch.reset();
    _timer?.cancel();
    setState(() {
      _laps.clear();
      _lastLapMark = Duration.zero;
    });
  }

  void _recordLap() {
    if (!_stopwatch.isRunning) return;
    HapticFeedback.lightImpact();
    final currentTotal = _stopwatch.elapsed;
    final lapDiff = currentTotal - _lastLapMark;
    _lastLapMark = currentTotal;

    setState(() {
      _laps.insert(
        0,
        LapRecord(
          lapNumber: _laps.length + 1,
          lapTime: lapDiff,
          totalTime: currentTotal,
        ),
      );
    });
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final hundredths = twoDigits((duration.inMilliseconds.remainder(1000) ~/ 10));
    return "$minutes:$seconds.$hundredths";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final elapsed = _stopwatch.elapsed;
    final isRunning = _stopwatch.isRunning;
    final canResetOrLap = elapsed > Duration.zero;

    // Progress circle based on 60 seconds
    final secondsFraction = (elapsed.inMilliseconds % 60000) / 60000.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.timer_outlined, color: AppColors.primaryDark),
              Text(
                "STOPWATCH",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 1.5,
                  color: AppColors.primaryDark.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 24),
            ],
          ),
          const SizedBox(height: 25),

          // Central Stopwatch Ring Display
          Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Neumorphic Shell
                  NeumorphicContainer(
                    width: 230,
                    height: 230,
                    borderRadius: 115,
                    color: AppColors.background,
                  ),

                  // Circular Progress Indicator
                  SizedBox(
                    width: 210,
                    height: 210,
                    child: CircularProgressIndicator(
                      value: secondsFraction,
                      strokeWidth: 6,
                      backgroundColor: AppColors.shadowDark.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.redAccent,
                      ),
                    ),
                  ),

                  // Digital Time
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(elapsed),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                          letterSpacing: 1.2,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isRunning ? "RUNNING" : (elapsed > Duration.zero ? "PAUSED" : "READY"),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                          color: isRunning
                              ? const Color(0xFF2ECC71)
                              : (elapsed > Duration.zero
                              ? AppColors.accentYellow
                              : AppColors.textGrey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          // Controls: Lap/Reset & Start/Stop
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Lap / Reset Button
              GestureDetector(
                onTap: () {
                  if (!canResetOrLap) return;
                  if (isRunning) {
                    _recordLap();
                  } else {
                    _resetTimer();
                  }
                },
                child: Opacity(
                  opacity: canResetOrLap ? 1.0 : 0.45,
                  child: NeumorphicContainer(
                    width: 100,
                    height: 52,
                    borderRadius: 20,
                    color: AppColors.cardBg,
                    child: Center(
                      child: Text(
                        isRunning ? "LAP" : "RESET",
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 1.2,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Start / Stop Primary Button
              GestureDetector(
                onTap: isRunning ? _stopTimer : _startTimer,
                child: Container(
                  width: 130,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: isRunning
                          ? [const Color(0xFFFF5252), const Color(0xFFE02E2E)]
                          : [const Color(0xFFFFC444), const Color(0xFFF39C12)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isRunning
                            ? const Color(0xFFFF5252)
                            : const Color(0xFFF39C12))
                            .withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isRunning ? "STOP" : "START",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Laps Table / List
          Expanded(
            child: _laps.isEmpty
                ? Center(
              child: Text(
                "No laps recorded yet",
                style: TextStyle(
                  color: AppColors.textGrey.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
                : ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: _laps.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final lap = _laps[index];
                return NeumorphicContainer(
                  borderRadius: 16,
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Lap ${lap.lapNumber.toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.textGrey,
                        ),
                      ),
                      Text(
                        "+ ${_formatTime(lap.lapTime)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.primaryDark,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        _formatTime(lap.totalTime),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.primaryDark.withValues(alpha: 0.9),
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
