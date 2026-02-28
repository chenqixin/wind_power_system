library;

import 'package:wind_power_system/model/DeviceDetailData.dart' as model;


//总功率
({String value, String unit}) powerValueUnit(model.DeviceDetailData? data) {
  if (data == null || data.winddata == null) return (value: '-', unit: '');
  final wind = data.winddata!;
  
  final p1 = (wind.blade1?.windI != null && wind.blade1?.windV != null)
      ? (wind.blade1!.windI!.toDouble() * wind.blade1!.windV!.toDouble())
      : 0.0;
  final p2 = (wind.blade2?.windI != null && wind.blade2?.windV != null)
      ? (wind.blade2!.windI!.toDouble() * wind.blade2!.windV!.toDouble())
      : 0.0;
  final p3 = (wind.blade3?.windI != null && wind.blade3?.windV != null)
      ? (wind.blade3!.windI!.toDouble() * wind.blade3!.windV!.toDouble())
      : 0.0;

  final p = p1 + p2 + p3;
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
