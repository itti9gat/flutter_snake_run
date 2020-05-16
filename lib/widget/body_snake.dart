import 'package:flutter/material.dart';

final Widget bodySnake = Padding(
    padding: const EdgeInsets.all(1.0),
    child: Container(
      width: 13.0,
      height: 13.0,
      decoration: new BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.all(
          Radius.circular(3.0),
        ),
      ),
    ));

final Widget pointInGame = Container(
  width: 13.0,
  height: 13.0,
  decoration: new BoxDecoration(
    color: Colors.white,
    shape: BoxShape.circle,
  ),
);
