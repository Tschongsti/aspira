import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp (
      home: Scaffold (
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo-aspira.png',
                width: 200,
                ),
              SizedBox (height: 16),
              Text.rich(
                TextSpan(
                  text: 'Become You',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8D6CCB),
                  ),
                ),
              ),
            ],
          ),  
        )
      ),
    ),
  );
}

