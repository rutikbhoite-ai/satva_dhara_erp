import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const card = <BoxShadow>[
    BoxShadow(
      blurRadius: 20,
      spreadRadius: -10,
      offset: Offset(0, 10),
      color: Color(0x22000000),
    ),
  ];
}
