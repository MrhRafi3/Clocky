import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../models/city_timezone.dart';
import '../../widgets/neumorphic_container.dart';
import 'analog_clock.dart';

class ClockView extends StatefulWidget {
  const ClockView({super.key});

  @override
  State<ClockView> createState() => _ClockViewState();
}

class _ClockViewState extends State<ClockView>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late Timer _timer;
  AnimationController? _glowController;
  Animation<double>? _glowPulseAnimation;

  // Default City Tab e shudhu DHAKA thakbe
  final List<CityTimeZone> _myCityTabs = [
    const CityTimeZone(cityName: "DHAKA", country: "Bangladesh", offsetHours: 6),
  ];

  late CityTimeZone _selectedCity;
  DateTime _currentCityTime = DateTime.now();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _selectedCity = _myCityTabs.first; // Default select hobe DHAKA
    _updateTime();

    // Golden ambient light breathing pulse animation safely setup
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _glowPulseAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController!,
        curve: Curves.easeInOutSine,
      ),
    );

    // 60FPS fluid sweep hand timer
    _timer = Timer.periodic(const Duration(milliseconds: 32), (timer) {
      if (mounted) {
        setState(() {
          _updateTime();
        });
      }
    });
  }

  void _updateTime() {
    final utc = DateTime.now().toUtc();
    _currentCityTime = utc.add(Duration(
      hours: _selectedCity.offsetHours,
      minutes: _selectedCity.offsetMinutes,
    ));
  }

  @override
  void dispose() {
    _timer.cancel();
    _glowController?.dispose();
    super.dispose();
  }

  void _showCityPickerSheet() {
    String searchQuery = "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filteredCities = allPopularCities.where((c) {
              return c.cityName.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  c.country.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 45,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.shadowDark,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "ADD / SELECT TIME ZONE",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 14),
                      NeumorphicContainer(
                        height: 50,
                        borderRadius: 15,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          onChanged: (val) {
                            setSheetState(() => searchQuery = val);
                          },
                          decoration: const InputDecoration(
                            icon: Icon(Icons.search, color: AppColors.textGrey),
                            hintText: "Search city or country...",
                            hintStyle:
                            TextStyle(color: AppColors.textGrey, fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: filteredCities.isEmpty
                            ? const Center(
                          child: Text("No city found",
                              style: TextStyle(color: AppColors.textGrey)),
                        )
                            : ListView.separated(
                          controller: scrollController,
                          itemCount: filteredCities.length,
                          separatorBuilder: (_, _) =>
                          const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final city = filteredCities[index];
                            final isAlreadyInTabs = _myCityTabs
                                .any((c) => c.cityName == city.cityName);

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              title: Text(
                                city.cityName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isAlreadyInTabs
                                      ? AppColors.accentYellow
                                      : AppColors.primaryDark,
                                ),
                              ),
                              subtitle: Text(city.country,
                                  style: const TextStyle(fontSize: 12)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "UTC ${city.offsetHours >= 0 ? '+${city.offsetHours}' : city.offsetHours}${city.offsetMinutes > 0 ? ':${city.offsetMinutes}' : ''}",
                                    style: const TextStyle(
                                        color: AppColors.textGrey,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    isAlreadyInTabs
                                        ? Icons.check_circle
                                        : Icons.add_circle_outline,
                                    color: isAlreadyInTabs
                                        ? AppColors.accentYellow
                                        : AppColors.primaryDark,
                                  ),
                                ],
                              ),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  if (!isAlreadyInTabs) {
                                    _myCityTabs.add(city);
                                  }
                                  _selectedCity = city;
                                  _updateTime();
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _confirmDeleteTab(int index) {
    if (_myCityTabs.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("At least one city must remain!"),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final cityToDelete = _myCityTabs[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete City Tab?",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            "Do you want to remove '${cityToDelete.cityName}' from your clock tabs?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL",
                style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              setState(() {
                _myCityTabs.removeAt(index);
                if (_selectedCity.cityName == cityToDelete.cityName) {
                  _selectedCity = _myCityTabs.first;
                  _updateTime();
                }
              });
              Navigator.pop(context);
            },
            child: const Text("REMOVE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final timeStr = DateFormat('hh:mm:ss a').format(_currentCityTime);
    final size = MediaQuery.of(context).size;
    final clockSize = (size.height * 0.32).clamp(190.0, 260.0);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.public,
                                color: AppColors.primaryDark),
                            onPressed: _showCityPickerSheet,
                            tooltip: "Search All Cities",
                          ),
                          Text(
                            "WORLD CLOCK",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 1.5,
                              color: AppColors.primaryDark.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Clock with surrounding golden glow
                      Center(
                        child: _glowPulseAnimation != null
                            ? AnimatedBuilder(
                          animation: _glowPulseAnimation!,
                          builder: (context, child) {
                            final pulse = _glowPulseAnimation!.value;
                            return _buildClockStack(clockSize, pulse);
                          },
                        )
                            : _buildClockStack(clockSize, 1.0),
                      ),

                      const Spacer(),
                      const SizedBox(height: 15),

                      // City Tabs
                      SizedBox(
                        height: 52,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: ListView.separated(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: _myCityTabs.length,
                                separatorBuilder: (_, _) =>
                                const SizedBox(width: 10),
                                itemBuilder: (context, index) {
                                  return _buildCityTab(_myCityTabs[index], index);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: _showCityPickerSheet,
                              child: const NeumorphicContainer(
                                width: 50,
                                height: 50,
                                borderRadius: 16,
                                child: Icon(Icons.add,
                                    color: AppColors.primaryDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClockStack(double clockSize, double pulse) {
    return SizedBox(
      width: clockSize + 40,
      height: clockSize + 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Soft Golden Radial Light Aura
          Container(
            width: (clockSize + 36) * pulse,
            height: (clockSize + 36) * pulse,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFFD56B).withValues(alpha: 0.40 * pulse),
                  const Color(0xFFFFAE19).withValues(alpha: 0.22 * pulse),
                  const Color(0xFFF39C12).withValues(alpha: 0.08 * pulse),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.45, 0.75, 1.0],
              ),
            ),
          ),

          // 2. Focused Golden Backlight Halo
          Container(
            width: clockSize + 10,
            height: clockSize + 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC033).withValues(alpha: 0.45 * pulse),
                  blurRadius: 36,
                  spreadRadius: 6,
                ),
                BoxShadow(
                  color: const Color(0xFFE59C0B).withValues(alpha: 0.28 * pulse),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),

          // 3. Neumorphic Shell & Clock Face
          NeumorphicContainer(
            borderRadius: clockSize / 2,
            width: clockSize,
            height: clockSize,
            padding: const EdgeInsets.all(12),
            child: AnalogClock(dateTime: _currentCityTime),
          ),
        ],
      ),
    );
  }

  Widget _buildCityTab(CityTimeZone city, int index) {
    final isSelected = _selectedCity.cityName == city.cityName;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedCity = city;
          _updateTime();
        });
      },
      onLongPress: () {
        HapticFeedback.heavyImpact();
        _confirmDeleteTab(index);
      },
      child: Tooltip(
        message: "Long press to delete",
        child: NeumorphicContainer(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          borderRadius: 16,
          color: isSelected ? AppColors.accentLightYellow : AppColors.cardBg,
          child: Center(
            child: Text(
              city.cityName,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 1.1,
                color: isSelected ? AppColors.primaryDark : AppColors.textGrey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
