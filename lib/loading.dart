import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 16, 40, 92),
      child: Center(
        child: SpinKitPouringHourGlass(
          color: Colors.deepOrange,
          size: 70.0,
        ),
      ),
    );
  }
}
