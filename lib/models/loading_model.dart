import 'package:flutter/material.dart';

Widget loading() {
  return const Scaffold(
    body: Center(
      child: SizedBox(
          width: 48.0,
          height: 48.0,
          child: CircularProgressIndicator(
              strokeWidth: 6.5, color: Colors.blueAccent)),
    ),
  );
}
