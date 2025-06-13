import 'package:flutter/material.dart';

import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

import 'package:aspira/theme/color_schemes.dart';

Future<IconData?> pickIcon(BuildContext context) async {
  final IconPickerIcon? picked = await showIconPicker(
    context,
    configuration: const SinglePickerConfiguration(
      iconPackModes: [IconPack.material],
      adaptiveDialog: true,
      iconColor: kAspiraPurple, // z. B. kAspiraGold
      backgroundColor: Colors.white,
      title: Text("Wähle ein Icon"),
    ),
  );

  return picked?.data;
}