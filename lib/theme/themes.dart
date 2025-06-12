import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:aspira/theme/color_schemes.dart';
import 'package:aspira/theme/text_styles.dart';


final kLightColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.light,
  seedColor: kAspiraPurple,
  surface: kAspiraBackground
);

final kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: kAspiraPurple,
  surface: Color(0xFF121212),
);

final ThemeData lightTheme = ThemeData.from(
  colorScheme: kLightColorScheme,
  textTheme: GoogleFonts.interTextTheme(),
).copyWith(
  scaffoldBackgroundColor: kAspiraBackground,
  appBarTheme: AppBarTheme(
    backgroundColor: kAspiraBackground,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: kAspiraPurple
    ),
    iconTheme: const IconThemeData(
      color: kAspiraBrown
    ), 
  ),
  // ... weitere spezifische Themes
);

final ThemeData darkTheme = ThemeData.from(
  colorScheme: kLightColorScheme,
  textTheme: GoogleFonts.interTextTheme(),
).copyWith(
  scaffoldBackgroundColor: kAspiraBackground,
  appBarTheme: AppBarTheme(
    backgroundColor: kAspiraPurple,
    foregroundColor: Colors.white,
  ),
  // ... weitere spezifische Themes
);