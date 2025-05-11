class FokusTaetigkeit {
  const FokusTaetigkeit(this.title, this.startDate, this.totalTime, this.iconName);

  final String title;
  final DateTime startDate;
  final Duration totalTime;
  final String iconName;

/// Factory-Konstruktor für Strings:
  factory FokusTaetigkeit.fromStrings(String title, String startDate, String totalTime, String iconName) {
    return FokusTaetigkeit(
      title,
      DateTime.parse(startDate), // Format: yyyy-MM-dd
      _parseDuration(totalTime), // Format: dd:hh:mm
      iconName,
    );
  }

  /// Hilfsmethode zur Umwandlung eines Strings in Duration
  static Duration _parseDuration(String input) {
    final parts = input.split(':');
      final days = parts.length == 3 ? int.tryParse(parts[0]) ?? 0 : 0;
      final hours = parts.length >= 2 ? int.tryParse(parts[parts.length - 2]) ?? 0 : 0;
      final minutes = parts.length >= 1 ? int.tryParse(parts[parts.length - 1]) ?? 0 : 0;
      return Duration(days: days, hours: hours, minutes: minutes);
    }
}
