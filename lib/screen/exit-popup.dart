import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:walkmoneyapp/app_exceptions.dart';

import '../service/config.dart';
import 'package:http/http.dart' as http;

Future<bool> updateuselogin(username, password) async {
  var url = Uri.parse(Config.UrlApi +
      '/api/UpdateUseLogin?User=' +
      username +
      '&password=' +
      password +
      '&st=0' +
      '&Cusid=' +
      Config.CusId);

  var headers = {
    'Verify_identity': Config.Verify_identity,
    "Accept": "application/json"
  };
  var response = await http.post(url, headers: headers);

  if (response.statusCode != 400) {
    return Future<bool>.value(true);
  } else {
    return Future<bool>.value(false);
  }
}

Future<bool> showExitPopup(context) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ต้องการออก?"),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          print('yes selected');

                          exit(0);
                        },
                        child: Text("ตกลง"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade800),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                        child: OutlinedButton(
                      onPressed: () {
                        print('no selected');
                        Navigator.of(context).pop();
                      },
                      child:
                          Text("ยกเลิก", style: TextStyle(color: Colors.black)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                    ))
                  ],
                )
              ],
            ),
          ),
        );
      });
}
