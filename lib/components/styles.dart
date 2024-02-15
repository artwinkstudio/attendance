import 'package:flutter/material.dart';

const kSmallTextStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);

const kBigTextStyle = TextStyle(
  fontSize: 30,
);

const emailInputDecoration = InputDecoration(
  hintText: "Enter your email",
  labelText: "Email",
  border: OutlineInputBorder(),
  prefixIcon: Icon(Icons.email),
);
const passwordInputDecoration = InputDecoration(
  hintText: "Enter your password",
  labelText: "Password",
  border: OutlineInputBorder(),
  prefixIcon: Icon(Icons.lock),
);


const kbuttonTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 16.0,
);

final kbuttonStyle = TextButton.styleFrom(
  backgroundColor:const Color.fromARGB(255, 113, 162, 221),
  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24.0),
  ),
);

final kbuttonStyleAbmin = TextButton.styleFrom(
  backgroundColor:const Color.fromARGB(255, 205, 209, 213),
  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24.0),
  ),
);


const kAppBarBackgroundColor = Color.fromARGB(255, 227, 234, 203);
const kBackgroundColor = Color.fromARGB(255, 245, 245, 237);
const kListTileColor = Color.fromARGB(255, 255, 255, 255);