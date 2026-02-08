library;

import 'package:wind_power_system/model/DeviceDetailData.dart' as model;


//总功率
({String value, String unit}) powerValueUnit(model.State? s) {
  if (s == null) return (value: '-', unit: '');
  final ai = (s.aI ?? 0).toDouble();
  final bi = (s.bI ?? 0).toDouble();
  final ci = (s.cI ?? 0).toDouble();
  final av = (s.aV ?? 0).toDouble();
  final bv = (s.bV ?? 0).toDouble();
  final cv = (s.cV ?? 0).toDouble();
  final p = ai * av + bi * bv + ci * cv;
  if (p >= 1000) {
    return (value: (p / 1000).toStringAsFixed(2), unit: 'kw');
  } else {
    return (value: p.toStringAsFixed(2), unit: 'W');
  }
}


//  blades 功率
({String value, String unit}) bladePowerValueUnit(
    model.Winddata? wind, int blade) {
  if (wind == null) return (value: '-', unit: '');
  num? i;
  num? v;
  switch (blade) {
    case 1:
      i = wind.blade1?.windI;
      v = wind.blade1?.windV;
      break;
    case 2:
      i = wind.blade2?.windI;
      v = wind.blade2?.windV;
      break;
    case 3:
      i = wind.blade3?.windI;
      v = wind.blade3?.windV;
      break;
    default:
      i = null;
      v = null;
  }
  if (i == null || v == null) return (value: '-', unit: '');
  final p = i.toDouble() * v.toDouble();
  if (p >= 1000) {
    return (value: (p / 1000).toStringAsFixed(2), unit: 'kw');
  } else {
    return (value: p.toStringAsFixed(2), unit: 'W');
  }
}
