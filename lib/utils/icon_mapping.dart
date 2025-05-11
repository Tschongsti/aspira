import 'package:flutter/material.dart';

const Map<String, IconData> iconMap = {
  'diversity3': Icons.diversity_3,
  'landscape2': Icons.landscape,
  'self_improvement': Icons.self_improvement,
  'test': Icons.star, 
  'person': Icons.person,
};

IconData getIcon(String name) {
  return iconMap[name] ?? Icons.help_outline;
}