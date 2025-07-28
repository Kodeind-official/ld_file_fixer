import 'package:flutter/material.dart';

class colorSet {
  static Color mainBG = const Color(0xff171717);
  static Color mainGold = const Color(0xffd4a756);
  static Color pewter = const Color(0xffF2F1E8);
  static Color listTile1 = const Color(0xffe6dfcc);
  static Color listTile2 = const Color(0xffffffff);
}

class ThisTextStyle {
  static TextStyle bold14MainBg = TextStyle(
      fontSize: 14, fontWeight: FontWeight.bold, color: colorSet.mainBG);
  static TextStyle bold16MainBg = TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: colorSet.mainBG);
  static TextStyle bold18MainBg = TextStyle(
      fontSize: 18, fontWeight: FontWeight.bold, color: colorSet.mainBG);
  static TextStyle bold20MainBg = TextStyle(
      fontSize: 20, fontWeight: FontWeight.bold, color: colorSet.mainBG);
  static TextStyle bold20listTile1 = TextStyle(
      fontSize: 20, fontWeight: FontWeight.bold, color: colorSet.listTile1);
  static TextStyle bold22MainBg = TextStyle(
      fontSize: 20, fontWeight: FontWeight.bold, color: colorSet.mainBG);
  static TextStyle bold14MainGold = TextStyle(
      fontSize: 14, fontWeight: FontWeight.bold, color: colorSet.mainGold);
  static TextStyle bold16MainGold = TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: colorSet.mainGold);
  static TextStyle bold22MainGold = TextStyle(
      fontSize: 20, fontWeight: FontWeight.bold, color: colorSet.mainGold);
   static TextStyle kdialog16 = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w400, color: colorSet.mainBG);
}
