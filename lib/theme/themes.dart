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
  textTheme: kTextTheme,
).copyWith(
  scaffoldBackgroundColor: kAspiraBackground,
  appBarTheme: AppBarTheme(
    backgroundColor: kAspiraBackground,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: kTextTheme.titleLarge,
    iconTheme: const IconThemeData(
      color: kAspiraBrown
    ), 
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kAspiraPurple,
      foregroundColor: kAspiraTextLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      side: const BorderSide(
        color: kAspiraLavender,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
    ),
  ),
  cardTheme: CardTheme(
      color: kAspiraTextLight,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
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