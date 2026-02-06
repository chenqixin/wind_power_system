library;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CharTest2 extends StatefulWidget {
  const CharTest2({super.key});

  @override
  State<CharTest2> createState() => _CharTest2State();
}

class _CharTest2State extends State<CharTest2> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trend Demo 2',
      theme: ThemeData.light(),
      home: const _TrendAreaPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _Point {
  final DateTime time;
  final double t;
  final double h;

  const _Point(this.time, this.t, this.h);
}

class _TrendAreaPage extends StatefulWidget {
  const _TrendAreaPage({super.key});

  @override
  State<_TrendAreaPage> createState() => _TrendAreaPageState();
}

class _TrendAreaPageState extends State<_TrendAreaPage> {
  final List<_Point> _data = [];
  Timer? _timer;
  Timer? _idleTimer;
  final Random _rnd = Random();
  ChartSeriesController? _tempController;
  ChartSeriesController? _humController;
  late ZoomPanBehavior _zoomPanBehavior;
  double _chartWidth = 1;
  double _dragStartDx = 0;
  DateTime? _dragStartMin;
  DateTime? _dragStartMax;

  static const int _windowCount = 50;
  static const int _maxPoints = 1000;
  static const Duration _idleDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      enablePinching: true,
      enableMouseWheelZooming: true,
      zoomMode: ZoomMode.x,
    );
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      final now = DateTime.now();
      final t = 15 + _rnd.nextDouble() * 30;
      final h = 20 + _rnd.nextDouble() * 60;
      setState(() {
        _data.add(_Point(now, t, h));
        final addedIndex = _data.length - 1;
        if (_data.length > _maxPoints) {
          _data.removeAt(0);
          _tempController?.updateDataSource(
            addedDataIndexes: <int>[addedIndex],
            removedDataIndexes: const <int>[0],
          );
          _humController?.updateDataSource(
            addedDataIndexes: <int>[addedIndex],
            removedDataIndexes: const <int>[0],
          );
        } else {
          _tempController
              ?.updateDataSource(addedDataIndexes: <int>[addedIndex]);
          _humController?.updateDataSource(addedDataIndexes: <int>[addedIndex]);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _idleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('温湿度曲线')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            _chartWidth = constraints.maxWidth;
            return Stack(
              children: [
                SfCartesianChart(
                  legend: const Legend(isVisible: true),
                  primaryXAxis: DateTimeAxis(
                    autoScrollingDelta: 15,
                    autoScrollingMode: AutoScrollingMode.end,
                    enableAutoIntervalOnZooming: false,
                  ),
                  primaryYAxis: NumericAxis(minimum: 0, maximum: 100),
                  zoomPanBehavior: _zoomPanBehavior,
                  onZooming: (_) {
                    _idleTimer?.cancel();
                  },
                  onZoomEnd: (_) {
                    _idleTimer?.cancel();
                    _idleTimer = Timer(_idleDuration, () {
                      _zoomPanBehavior.reset();
                    });
                  },
                  trackballBehavior: TrackballBehavior(
                    enable: _data.isNotEmpty,
                    activationMode: ActivationMode.singleTap,
                    tooltipSettings: const InteractiveTooltip(),
                  ),
                  series: <CartesianSeries<_Point, DateTime>>[
                    SplineAreaSeries<_Point, DateTime>(
                      name: '温度 (°C)',
                      dataSource: _data,
                      xValueMapper: (p, _) => p.time,
                      yValueMapper: (p, _) => p.t,
                      onRendererCreated: (controller) =>
                          _tempController = controller,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.withOpacity(0.5),
                          Colors.blue.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                      borderColor: Colors.blue,
                      borderWidth: 2,
                      borderDrawMode: BorderDrawMode.top,
                    ),
                    SplineAreaSeries<_Point, DateTime>(
                      name: '湿度 (RH)',
                      dataSource: _data,
                      xValueMapper: (p, _) => p.time,
                      yValueMapper: (p, _) => p.h,
                      onRendererCreated: (controller) =>
                          _humController = controller,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.red.withOpacity(0.5),
                          Colors.red.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                      borderColor: Colors.red,
                      borderWidth: 2,
                      borderDrawMode: BorderDrawMode.top,
                    ),
                  ],
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: '放大',
                        icon: const Icon(Icons.zoom_in),
                        onPressed: () => _zoomPanBehavior.zoomIn(),
                      ),
                      IconButton(
                        tooltip: '缩小',
                        icon: const Icon(Icons.zoom_out),
                        onPressed: () => _zoomPanBehavior.zoomOut(),
                      ),
                      IconButton(
                        tooltip: '回到最新',
                        icon: const Icon(Icons.refresh),
                        onPressed: () => _zoomPanBehavior.reset(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
