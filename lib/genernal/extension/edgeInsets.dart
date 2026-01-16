
import 'package:flutter/material.dart';

extension CJEdgeInsets on num {

  //水平方向
   EdgeInsets get hEdgeInsets =>EdgeInsets.symmetric(horizontal: toDouble());

  //垂直方向
   EdgeInsets get vEdgeInsets =>EdgeInsets.symmetric(vertical: toDouble());

   //上下左右
   EdgeInsets get allEdgeInsets => EdgeInsets.all(toDouble());

   //上
   EdgeInsets get topEdgeInsets => EdgeInsets.only(top: toDouble());

   //下
   EdgeInsets get bottomEdgeInsets => EdgeInsets.only(bottom: toDouble());

   EdgeInsets get lEdgeInsets => EdgeInsets.only(left: toDouble());
}