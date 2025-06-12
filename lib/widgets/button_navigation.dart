import 'package:flutter/material.dart';

class ButtonNavigation extends StatelessWidget{
  
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final String text;
  
  const ButtonNavigation ({
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.text,
    super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // 👈 volle Breite
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50), // 👈 weniger rund
          ),
          elevation: 0, // 👈 kein Schatten, falls du das clean willst
          padding: const EdgeInsets.symmetric(vertical: 16.0), // 👈 mehr vertikaler Innenabstand
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only( // 👈 Abstand links & rechts vom Icon
                left: 24,
                right: 0,
              ),
              child: Icon(
                icon,
                size: 28, // 👈 grösseres Icon
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.left, // 👈 linksbündig
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


