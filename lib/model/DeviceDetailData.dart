/// 设备详情数据
/// 包含设备状态、故障与叶片数据
class DeviceDetailData {
  DeviceDetailData({
    this.state,
    this.fault,
    this.winddata,
  });

  DeviceDetailData.fromJson(dynamic json) {
    state = json['State'] != null ? State.fromJson(json['State']) : null;
    fault = json['Fault'] != null ? Fault.fromJson(json['Fault']) : null;
    winddata =
        json['Winddata'] != null ? Winddata.fromJson(json['Winddata']) : null;
  }

  /// 状态数据
  State? state;

  /// 故障数据
  Fault? fault;

  /// 风机叶片数据
  Winddata? winddata;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (state != null) {
      map['State'] = state?.toJson();
    }
    if (fault != null) {
      map['Fault'] = fault?.toJson();
    }
    if (winddata != null) {
      map['Winddata'] = winddata?.toJson();
    }
    return map;
  }
}

/// 叶片数据集合，包含 1/2/3 号叶片
class Winddata {
  Winddata({
    this.blade1,
    this.blade2,
    this.blade3,
  });

  Winddata.fromJson(dynamic json) {
    blade1 = json['Blade1'] != null ? Blade1.fromJson(json['Blade1']) : null;
    blade2 = json['Blade2'] != null ? Blade2.fromJson(json['Blade2']) : null;
    blade3 = json['Blade3'] != null ? Blade3.fromJson(json['Blade3']) : null;
  }

  /// 对应叶片 1 数据集合
  Blade1? blade1;

  /// 对应叶片 2 数据集合
  Blade2? blade2;

  /// 对应叶片 3 数据集合
  Blade3? blade3;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (blade1 != null) {
      map['Blade1'] = blade1?.toJson();
    }
    if (blade2 != null) {
      map['Blade2'] = blade2?.toJson();
    }
    if (blade3 != null) {
      map['Blade3'] = blade3?.toJson();
    }
    return map;
  }
}

/// 叶片 3 数据集合
class Blade3 {
  Blade3({
    this.tempUp,
    this.tickUp,
    this.runUp,
    this.tempMid,
    this.tickMid,
    this.runMid,
    this.tempDown,
    this.tickDown,
    this.runDown,
    this.windI,
    this.windV,
  });

  Blade3.fromJson(dynamic json) {
    tempUp = json['temp_up'];
    tickUp = json['tick_up'];
    runUp = json['run_up'];
    tempMid = json['temp_mid'];
    tickMid = json['tick_mid'];
    runMid = json['run_mid'];
    tempDown = json['temp_down'];
    tickDown = json['tick_down'];
    runDown = json['run_down'];
    windI = json['wind_I'];
    windV = json['wind_V'];
  }

  /// 叶尖温度
  num? tempUp;

  /// 叶尖厚度
  num? tickUp;

  /// 叶尖运动状态
  num? runUp;

  /// 叶中温度
  num? tempMid;

  /// 叶中厚度
  num? tickMid;

  /// 叶中运动状态
  num? runMid;

  /// 叶根温度
  num? tempDown;

  /// 叶根厚度
  num? tickDown;

  /// 叶根运动状态
  num? runDown;

  /// 叶片运行电流
  num? windI;

  /// 叶片运行电压
  num? windV;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['temp_up'] = tempUp;
    map['tick_up'] = tickUp;
    map['run_up'] = runUp;
    map['temp_mid'] = tempMid;
    map['tick_mid'] = tickMid;
    map['run_mid'] = runMid;
    map['temp_down'] = tempDown;
    map['tick_down'] = tickDown;
    map['run_down'] = runDown;
    map['wind_I'] = windI;
    map['wind_V'] = windV;
    return map;
  }
}

/// 叶片 2 数据集合
class Blade2 {
  Blade2({
    this.tempUp,
    this.tickUp,
    this.runUp,
    this.tempMid,
    this.tickMid,
    this.runMid,
    this.tempDown,
    this.tickDown,
    this.runDown,
    this.windI,
    this.windV,
  });

  Blade2.fromJson(dynamic json) {
    tempUp = json['temp_up'];
    tickUp = json['tick_up'];
    runUp = json['run_up'];
    tempMid = json['temp_mid'];
    tickMid = json['tick_mid'];
    runMid = json['run_mid'];
    tempDown = json['temp_down'];
    tickDown = json['tick_down'];
    runDown = json['run_down'];
    windI = json['wind_I'];
    windV = json['wind_V'];
  }

  /// 叶尖温度
  num? tempUp;

  /// 叶尖厚度
  num? tickUp;

  /// 叶尖运动状态
  num? runUp;

  /// 叶中温度
  num? tempMid;

  /// 叶中厚度
  num? tickMid;

  /// 叶中运动状态
  num? runMid;

  /// 叶根温度
  num? tempDown;

  /// 叶根厚度
  num? tickDown;

  /// 叶根运动状态
  num? runDown;

  /// 叶片运行电流
  num? windI;

  /// 叶片运行电压
  num? windV;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['temp_up'] = tempUp;
    map['tick_up'] = tickUp;
    map['run_up'] = runUp;
    map['temp_mid'] = tempMid;
    map['tick_mid'] = tickMid;
    map['run_mid'] = runMid;
    map['temp_down'] = tempDown;
    map['tick_down'] = tickDown;
    map['run_down'] = runDown;
    map['wind_I'] = windI;
    map['wind_V'] = windV;
    return map;
  }
}

/// 叶片 1 数据集合
class Blade1 {
  Blade1({
    this.tempUp,
    this.tickUp,
    this.runUp,
    this.tempMid,
    this.tickMid,
    this.runMid,
    this.tempDown,
    this.tickDown,
    this.runDown,
    this.windI,
    this.windV,
  });

  Blade1.fromJson(dynamic json) {
    tempUp = json['temp_up'];
    tickUp = json['tick_up'];
    runUp = json['run_up'];
    tempMid = json['temp_mid'];
    tickMid = json['tick_mid'];
    runMid = json['run_mid'];
    tempDown = json['temp_down'];
    tickDown = json['tick_down'];
    runDown = json['run_down'];
    windI = json['wind_I'];
    windV = json['wind_V'];
  }

  /// 叶尖温度
  num? tempUp;

  /// 叶尖厚度
  num? tickUp;

  /// 叶尖运动状态
  num? runUp;

  /// 叶中温度
  num? tempMid;

  /// 叶中厚度
  num? tickMid;

  /// 叶中运动状态
  num? runMid;

  /// 叶根温度
  num? tempDown;

  /// 叶根厚度
  num? tickDown;

  /// 叶根运动状态
  num? runDown;

  /// 叶片运行电流
  num? windI;

  /// 叶片运行电压
  num? windV;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['temp_up'] = tempUp;
    map['tick_up'] = tickUp;
    map['run_up'] = runUp;
    map['temp_mid'] = tempMid;
    map['tick_mid'] = tickMid;
    map['run_mid'] = runMid;
    map['temp_down'] = tempDown;
    map['tick_down'] = tickDown;
    map['run_down'] = runDown;
    map['wind_I'] = windI;
    map['wind_V'] = windV;
    return map;
  }
}

/// 故障状态集合
class Fault {
  Fault({
    this.faultRing,
    this.faultUps,
    this.faultTestCom,
    this.faultIavg,
    this.faultContactor,
    this.faultStick,
    this.faultStickBlade1,
    this.faultStickBlade2,
    this.faultStickBlade3,
    this.faultBlade1,
    this.faultBlade2,
    this.faultBlade3,
  });

  Fault.fromJson(dynamic json) {
    faultRing = json['Fault_ring'];
    faultUps = json['Fault_ups'];
    faultTestCom = json['Fault_test_com'];
    faultIavg = json['Fault_iavg'];
    faultContactor = json['Fault_contactor'];
    faultStick = json['Fault_stick'];
    faultStickBlade1 = json['Fault_stick_blade1'];
    faultStickBlade2 = json['Fault_stick_blade2'];
    faultStickBlade3 = json['Fault_stick_blade3'];
    faultBlade1 = json['Fault_blade1'];
    faultBlade2 = json['Fault_blade2'];
    faultBlade3 = json['Fault_blade3'];
  }

  /// 环网通讯故障
  num? faultRing;

  /// UPS 电源故障
  num? faultUps;

  /// 测冰设备通讯故障
  num? faultTestCom;

  /// 电流均值故障
  num? faultIavg;

  /// 接触器转运故障
  num? faultContactor;

  /// 主接触器粘黏故障
  num? faultStick;

  /// 叶片 1 接触器粘黏故障
  num? faultStickBlade1;

  /// 叶片 2 接触器粘黏故障
  num? faultStickBlade2;

  /// 叶片 3 接触器粘黏故障
  num? faultStickBlade3;

  /// 1# 叶片电源故障
  num? faultBlade1;

  /// 2# 叶片电源故障
  num? faultBlade2;

  /// 3# 叶片电源故障
  num? faultBlade3;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Fault_ring'] = faultRing;
    map['Fault_ups'] = faultUps;
    map['Fault_test_com'] = faultTestCom;
    map['Fault_iavg'] = faultIavg;
    map['Fault_contactor'] = faultContactor;
    map['Fault_stick'] = faultStick;
    map['Fault_stick_blade1'] = faultStickBlade1;
    map['Fault_stick_blade2'] = faultStickBlade2;
    map['Fault_stick_blade3'] = faultStickBlade3;
    map['Fault_blade1'] = faultBlade1;
    map['Fault_blade2'] = faultBlade2;
    map['Fault_blade3'] = faultBlade3;
    return map;
  }
}

/// 设备状态数据
class State {
  State({
    this.deviceId,
    this.verisonHot,
    this.verisonIce,
    this.aI,
    this.bI,
    this.cI,
    this.aV,
    this.bV,
    this.cV,
    this.cmd,
    this.tcpIp,
    this.envTemp,
    this.envHumidity,
    this.errorStop,
    this.restFlag,
    this.hotState1,
    this.hotState2,
    this.hotState3,
    this.hotTime,
    this.iSet,
    this.rotorSpeed,
    this.windSpeed,
    this.iceState,
  });

  State.fromJson(dynamic json) {
    deviceId = json['Device_id'];
    verisonHot = json['Verison_hot'];
    verisonIce = json['Verison_ice'];
    aI = json['A_I'];
    bI = json['B_I'];
    cI = json['C_I'];
    aV = json['A_V'];
    bV = json['B_V'];
    cV = json['C_V'];
    cmd = json['Cmd'];
    tcpIp = json['Tcp_ip'];
    envTemp = json['Env_temp'];
    envHumidity = json['Env_humidity'];
    errorStop = json['Error_stop'];
    restFlag = json['Rest_flag'];
    hotState1 = json['Hot_state1'];
    hotState2 = json['Hot_state2'];
    hotState3 = json['Hot_state3'];
    hotTime = json['Hot_time'];
    iSet = json['I_set'];
    rotorSpeed = json['rotor_speed'];
    windSpeed = json['wind_speed'];
    iceState = json['Ice_state'];
  }

  /// 设备唯一标识符（IMEI）
  String? deviceId;

  /// 加热设备版本号
  String? verisonHot;

  /// 测冰设备版本号
  String? verisonIce;

  /// A 相电流
  num? aI;

  /// B 相电流
  num? bI;

  /// C 相电流
  num? cI;

  /// A 相电压
  num? aV;

  /// B 相电压
  num? bV;

  /// C 相电压
  num? cV;

  /// 命令
  num? cmd;

  /// 设备所属 IP 地址
  String? tcpIp;

  /// 柜内环境温度
  num? envTemp;

  /// 环境湿度
  num? envHumidity;

  /// 急停信号
  num? errorStop;

  /// 复位信号
  num? restFlag;

  /// 叶片 1 当前加热状态
  num? hotState1;

  /// 叶片 2 当前加热状态
  num? hotState2;

  /// 叶片 3 当前加热状态
  num? hotState3;

  /// 加热时长
  num? hotTime;

  /// 不平衡电流阈值
  num? iSet;

  /// 转速
  num? rotorSpeed;

  /// 风速
  num? windSpeed;

  /// 结冰状态
  num? iceState;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Device_id'] = deviceId;
    map['Verison_hot'] = verisonHot;
    map['Verison_ice'] = verisonIce;
    map['A_I'] = aI;
    map['B_I'] = bI;
    map['C_I'] = cI;
    map['A_V'] = aV;
    map['B_V'] = bV;
    map['C_V'] = cV;
    map['Cmd'] = cmd;
    map['Tcp_ip'] = tcpIp;
    map['Env_temp'] = envTemp;
    map['Env_humidity'] = envHumidity;
    map['Error_stop'] = errorStop;
    map['Rest_flag'] = restFlag;
    map['Hot_state1'] = hotState1;
    map['Hot_state2'] = hotState2;
    map['Hot_state3'] = hotState3;
    map['Hot_time'] = hotTime;
    map['I_set'] = iSet;
    map['rotor_speed'] = rotorSpeed;
    map['wind_speed'] = windSpeed;
    map['Ice_state'] = iceState;
    return map;
  }
}
