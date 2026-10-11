class CityTimeZone {
  final String cityName;
  final String country;
  final int offsetHours;
  final int offsetMinutes;

  const CityTimeZone({
    required this.cityName,
    required this.country,
    required this.offsetHours,
    this.offsetMinutes = 0,
  });
}

const List<CityTimeZone> allPopularCities = [
  CityTimeZone(cityName: "DHAKA", country: "Bangladesh", offsetHours: 6),
  CityTimeZone(cityName: "LONDON", country: "United Kingdom", offsetHours: 1),
  CityTimeZone(cityName: "NEW YORK", country: "United States", offsetHours: -4),
  CityTimeZone(cityName: "DUBAI", country: "United Arab Emirates", offsetHours: 4),
  CityTimeZone(cityName: "TOKYO", country: "Japan", offsetHours: 9),
  CityTimeZone(cityName: "SINGAPORE", country: "Singapore", offsetHours: 8),
];
