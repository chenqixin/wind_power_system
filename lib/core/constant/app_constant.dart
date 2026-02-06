import 'package:flutter/material.dart';
import '/core/utils/print_utils.dart';

class AppConstant {
  /// 单例
  static AppConstant? _shared;

  static AppConstant get shared => _shared ??= AppConstant();

  /// 保存内容上下文
  late BuildContext context;

  /// 初始化
  static void init(BuildContext context) {
    shared.context = context;
    final view = View.maybeOf(AppConstant.shared.context);
    if (view != null) {
      final data = MediaQueryData.fromView(view);
      cjPrint("AppConstant--context--view布局完成");
      cjPrint("AppConstant--context--view宽度：${data.size.width}");
      cjPrint("AppConstant--context--view高度：${data.size.height}");
    } else {
      cjPrint("AppConstant--context--view未布局完成");
    }
  }


  //
}

/// 屏幕相关常量
class AppScreen extends AppConstant {
  /// 屏幕宽度
  static double get width {
    return MediaQuery.of(AppConstant.shared.context).size.width;
  }

  /// 屏幕高度
  static double get height {
    return MediaQuery.of(AppConstant.shared.context).size.height;
  }

  /// 状态栏高度
  static double get statusBarHeight {
    return MediaQuery.of(AppConstant.shared.context).padding.top;
  }

  /// 底部安全区域
  static double get paddingBottom {
    return MediaQuery.of(AppConstant.shared.context).viewPadding.bottom;
  }

  /// 导航栏的高度 + 状态栏的高度
  static double get naviBarHeight {
    return statusBarHeight + 44;
  }

  /// 底部tabbar高度
  static double get tabBarHeight {
    return MediaQuery.of(AppConstant.shared.context).viewPadding.bottom + 63;
  }

  /// 适配比例
  static double get scale375 {
    return width / 375;
  }


  /// 适配字体大小
  static double adaptiveFontSize(BuildContext context, double baseSize) {
    double scale = MediaQuery.of(context).size.width / 1920;
    scale = scale.clamp(0.85, 1.2);

    return baseSize * scale;
  }

  /// 顶部全局 Header 高度
  static const double headerHeight = 60.0;

  /// 物理像素比
  static double get devicePixelRatio {
    return MediaQuery.of(AppConstant.shared.context).devicePixelRatio;
  }
}

class UserInfo {
  static String userName = '';
  static String password = '';
  static int role = 0;
}
