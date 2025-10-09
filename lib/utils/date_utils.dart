/// Liefert den Wochenstart (Montag 00:00) und das Wochenende (Montag + 7 Tage).
///
/// Beispiel:
///   final (start, end) = weekWindow(DateTime(2025, 10, 9));
///   // start = Montag, 6. Oktober 2025, 00:00
///   // end   = Montag, 13. Oktober 2025, 00:00
///
/// Hinweis: Wenn du UTC-Zeitstempel in der DB verwendest, verwende weekWindowUtc().
///
(DateTime start, DateTime end) weekWindow(DateTime date) {
  final localDay = DateTime(date.year, date.month, date.day);
  final start = localDay.subtract(Duration(days: localDay.weekday - 1)); // Montag 00:00
  final end = start.add(const Duration(days: 7)); // Folgewoche Montag 00:00
  return (start, end);
}

/// Gibt true zurück, wenn zwei Daten im selben Wochenfenster liegen.
bool isSameWeek(DateTime a, DateTime b) {
  final (startA, _) = weekWindow(a);
  final (startB, _) = weekWindow(b);
  return startA == startB;
}