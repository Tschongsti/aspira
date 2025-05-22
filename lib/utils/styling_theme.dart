import 'package:flutter/material.dart';

const kAspiraPurple = Color(0xFF8D6CCB);
const kAspiraLavender = Color(0xFFC7B5E3);
const kAspiraGold = Color(0xFFF0D28A);
const kAspiraBrown = Color(0xFFB68B30);
const kAspiraBackground = Color(0xFFF5F7F8);

final kColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: kAspiraPurple,
  onPrimary: Colors.white,
  secondary: kAspiraLavender,
  onSecondary: Colors.black,
  error: Colors.red,
  onError: Colors.white,
  surface: kAspiraBackground,
  onSurface: Colors.black,
);
