import 'dart:io';
import 'package:flutter/material.dart';

import '../service/config.dart';
import 'package:http/http.dart' as http;
import 'package:walkmoney/screen/menu.dart';

Future<bool> showExitPopup(context) async {
  return await Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => Menuscreen(tab: '0')),
  );
}
