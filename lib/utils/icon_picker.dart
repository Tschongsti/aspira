import 'package:flutter/material.dart';

import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

Future<IconData?> pickIcon(BuildContext context) async {
  final IconPickerIcon? picked = await showIconPicker(
    context,
    configuration: const SinglePickerConfiguration(
      iconPackModes: [IconPack.lineAwesomeIcons],
      adaptiveDialog: true,
      iconColor: Colors.amber, // z. B. kAspiraGold
      backgroundColor: Colors.white,
      title: Text("Wähle ein Icon"),
    ),
  );

  return picked?.data;
}