import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wind_power_system/page/main_shell_page.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 window_manager
  await windowManager.ensureInitialized();

  // 配置窗口参数
  const double baseW = 1920;
  const double baseH = 1280;
  const double minW = 1280;
  const double minH = 800;
  WindowOptions windowOptions = const WindowOptions(
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final display = await screenRetriever.getPrimaryDisplay();
      final screenW = display.size.width;
      final screenH = display.size.height;
      await windowManager.setFullScreen(false);
      await windowManager.setResizable(true);
      await windowManager.setMinimumSize(const Size(minW, minH));
      if (screenW > baseW && screenH > baseH) {
        await windowManager.setSize(const Size(baseW, baseH));
      } else {
        await windowManager.setSize(Size(
          screenW.clamp(minW, baseW),
          screenH.clamp(minH, baseH),
        ));
      }
      await windowManager.center();
    }
    await windowManager.show(); // 显示窗口
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '风电监控系统',
      theme: _buildIndustrialTheme(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      locale: const Locale('zh', 'CN'),
      builder: (context, child) {
        return MediaQuery(
          // 固定 PC 缩放，避免系统字体影响
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
      home: MainShellPage(),
    );
  }

  // 创建主题theme
  ThemeData _buildIndustrialTheme() {
    const primary = Color(0xFF2F7BEA); // 工业蓝
    const bg = Color(0xFFEAF0F9); // 页面背景
    const card = Colors.white;
    const textMain = Color(0xFF1F2937);
    const textSub = Color(0xFF6B7280);

    return ThemeData(
      useMaterial3: false,

      // 主色
      primaryColor: primary,
      scaffoldBackgroundColor: bg,

      // 字体
      fontFamily: 'PingFang SC',

      // 文本
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 14, color: textMain),
        bodySmall: TextStyle(fontSize: 12, color: textSub),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),

      // Card（你系统里大量卡片）
      cardTheme: CardTheme(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E7EB),
        thickness: 1,
      ),

      // Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: const TextStyle(fontSize: 14),
        ),
      ),

      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textMain,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: textSub,
        ),
      ),

      // Tooltip（PC 常用）
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: const TextStyle(fontSize: 12, color: Colors.white),
      ),
    );
  }
}
