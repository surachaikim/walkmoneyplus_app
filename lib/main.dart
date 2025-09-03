import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walkmoney/screen/check_register.dart';
import 'package:walkmoney/utils/locale_utils.dart';
import 'palette.dart';

// NAiFlutter
// Copyright R&D Computer System Co., Ltd.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Thai locale data for the entire app
  await LocaleUtils.initializeLocale();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Walkmoney',
      debugShowCheckedModeBanner: false,
      //theme: ThemeData(primarySwatch: Colors.blue),
      theme: ThemeData(
        primarySwatch: Palette.kToDark,
        textTheme: GoogleFonts.kanitTextTheme(Theme.of(context).textTheme),
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.kanit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      home: const CheckRegisterScreen(),
    );
  }
}
