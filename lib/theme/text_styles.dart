import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:aspira/theme/color_schemes.dart';

final TextTheme kTextTheme = GoogleFonts.interTextTheme().copyWith(
  titleLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: kAspiraPurple),
  titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
  displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold),
  bodyMedium: GoogleFonts.inter(fontSize: 14),
  labelLarge: GoogleFonts.inter(fontSize: 13, letterSpacing: 0.4),
);

class AppTextStyles {
  static TextStyle get screenTitle => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: kAspiraPurple
      );
}
