import 'package:flutter_riverpod/flutter_riverpod.dart';

final tickerProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (i) => i);
});