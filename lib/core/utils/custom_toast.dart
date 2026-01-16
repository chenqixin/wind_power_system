import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class AIToast {
  static void msg(String msg) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: const Color(0x99000000),
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  static void error(String? msg) {
    // 添加一个取消加载菊花
    //AIToast.loadingHide();
    Fluttertoast.showToast(
      msg: msg ?? "数据获取失败",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: const Color(0x99000000),
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  // 网络请求loading
  static final Widget _loadingView = SizedBox(
    width: 45.0,
    height: 45.0,
    child: Image.asset('lib/resources/webp/loading.webp'),
  );

  // 展示网络请求loading
  // static void loading() {
  //   EasyLoading.instance
  //     ..loadingStyle = EasyLoadingStyle.custom
  //     ..indicatorWidget = _loadingView
  //     ..maskType = EasyLoadingMaskType.clear
  //     ..indicatorColor = Colors.transparent
  //     ..backgroundColor = Colors.white
  //     ..contentPadding = EdgeInsets.zero
  //     ..textPadding = EdgeInsets.zero
  //     ..textColor = Colors.white
  //     ..userInteractions = false
  //     ..maskColor = Colors.white.withOpacity(0.5)
  //     ..progressColor = AppColors.textRed
  //     ..dismissOnTap = false;
  //
  //   EasyLoading.show();
  // }
  //
  // // 隐藏网络请求loading
  // static void loadingHide() {
  //   // FToast().removeCustomToast();
  //   EasyLoading.dismiss();
  // }
}
