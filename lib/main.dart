import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walkmoney/screen/check_register.dart';
import 'palette.dart';

// NAiFlutter
// Copyright R&D Computer System Co., Ltd.

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Walkmoney',
      //theme: ThemeData(primarySwatch: Colors.blue),
      theme: ThemeData(
        primarySwatch: Palette.kToDark,
        textTheme: GoogleFonts.kanitTextTheme(Theme.of(context).textTheme),
      ),

      home: const CheckRegisterScreen(),
    );
  }
}
