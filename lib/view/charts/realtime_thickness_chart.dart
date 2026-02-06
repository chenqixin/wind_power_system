library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RealtimeThicknessChart extends StatefulWidget {
  final Future<List<double>> Function()? onRequest;
  final int refreshSeconds;
  final int maxPoints;

  const RealtimeThicknessChart({
    super.key,
    this.onRequest,
    this.refreshSeconds = 5,
    this.maxPoints = 180,
  });

  @override
  State<RealtimeThicknessChart> createState() => _RealtimeThicknessChartState();
}

class _Point {
  final DateTime time;
  final double root;
  final double mid;
  final double tip;

  const _Point(this.time, this.root, this.mid, this.tip);
}

class _RealtimeThicknessChartState extends State<RealtimeThicknessChart> {
  final List<_Point> _data = [];
  Timer? _timer;
  ChartSeriesController? _rootController;
  ChartSeriesController? _midController;
  ChartSeriesController? _tipController;
  late TrackballBehavior _trackballBehavior;
  bool _controllersReady = false;

  @override
  void initState() {
    super.initState();
    _trackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipSettings: const InteractiveTooltip(),
    );
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    Future<void> tick() async {
      final now = DateTime.now();
      if (widget.onRequest == null) return;
      List<double> values;
      try {
        values = await widget.onRequest!();
      } catch (_) {
        return;
      }
      if (values.length < 3) return;
      final p = _Point(now, values[0].clamp(0, 20), values[1].clamp(0, 20),
          values[2].clamp(0, 20));
      _data.add(p);
      List<int> removed = const [];
      if (_data.length > widget.maxPoints) {
        _data.removeAt(0);
        removed = [0];
      }
      if (!mounted) return;
      final addedIndex = _data.length - 1;
      if (_rootController == null ||
          _midController == null ||
          _tipController == null) {
        setState(() {});
        return;
      }
      _controllersReady = true;
      _rootController!.updateDataSource(
          addedDataIndexes: [addedIndex], removedDataIndexes: removed);
      _midController!.updateDataSource(
          addedDataIndexes: [addedIndex], removedDataIndexes: removed);
      _tipController!.updateDataSource(
          addedDataIndexes: [addedIndex], removedDataIndexes: removed);
    }

    _timer =
        Timer.periodic(Duration(seconds: widget.refreshSeconds), (_) => tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      legend: const Legend(isVisible: false, position: LegendPosition.bottom),
      primaryXAxis: DateTimeAxis(
        intervalType: DateTimeIntervalType.seconds,
        interval: 5,
        autoScrollingDelta: 50,
        autoScrollingMode: AutoScrollingMode.end,
        enableAutoIntervalOnZooming: false,
        desiredIntervals: 10,
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 1, dashArray: <double>[4, 4]),
        majorTickLines: const MajorTickLines(size: 0, width: 0),
        minorTickLines: const MinorTickLines(size: 0, width: 0),
        axisLabelFormatter: (details) {
          final dt = DateTime.fromMillisecondsSinceEpoch(details.value.toInt());
          String two(int n) => n < 10 ? '0$n' : '$n';
          final s = '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
          return ChartAxisLabel(s, const TextStyle(fontSize: 10));
        },
        edgeLabelPlacement: EdgeLabelPlacement.shift,
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 20,
        interval: 5,
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 1, dashArray: <double>[4, 4]),
        majorTickLines: const MajorTickLines(size: 0, width: 0),
        minorTickLines: const MinorTickLines(size: 0, width: 0),
        plotBands: <PlotBand>[
          PlotBand(
              start: 5,
              end: 5,
              borderWidth: 0.5,
              borderColor: const Color(0xFFE0E0E0),
              dashArray: const <double>[4, 4],
              shouldRenderAboveSeries: true),
          PlotBand(
              start: 10,
              end: 10,
              borderWidth: 0.5,
              borderColor: const Color(0xFFE0E0E0),
              dashArray: const <double>[4, 4],
              shouldRenderAboveSeries: true),
          PlotBand(
              start: 15,
              end: 15,
              borderWidth: 0.5,
              borderColor: const Color(0xFFE0E0E0),
              dashArray: const <double>[4, 4],
              shouldRenderAboveSeries: true),
        ],
        axisLabelFormatter: (details) {
          final v = details.value;
          final wanted = v == 0 || v == 5 || v == 10 || v == 15 || v == 20;
          return ChartAxisLabel(wanted ? v.toStringAsFixed(0) : '',
              const TextStyle(fontSize: 10));
        },
      ),
      trackballBehavior: _trackballBehavior,
      series: <CartesianSeries<_Point, DateTime>>[
        SplineAreaSeries<_Point, DateTime>(
          name: '叶根',
          dataSource: _data,
          xValueMapper: (p, _) => p.time,
          yValueMapper: (p, _) => p.root,
          onRendererCreated: (c) => _rootController = c,
          animationDuration: 0,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1AD2B9).withOpacity(0.18),
              Colors.white.withOpacity(0.25),
            ],
          ),
          borderColor: const Color(0xFF1AD2B9),
          borderWidth: 1,
          borderDrawMode: BorderDrawMode.top,
        ),
        SplineAreaSeries<_Point, DateTime>(
          name: '叶中',
          dataSource: _data,
          xValueMapper: (p, _) => p.time,
          yValueMapper: (p, _) => p.mid,
          onRendererCreated: (c) => _midController = c,
          animationDuration: 0,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.withOpacity(0.18),
              Colors.white.withOpacity(0.10),
            ],
          ),
          borderColor: Colors.blue,
          borderWidth: 1,
          borderDrawMode: BorderDrawMode.top,
        ),
        SplineAreaSeries<_Point, DateTime>(
          name: '叶尖',
          dataSource: _data,
          xValueMapper: (p, _) => p.time,
          yValueMapper: (p, _) => p.tip,
          onRendererCreated: (c) => _tipController = c,
          animationDuration: 0,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFF914C).withOpacity(0.30),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderColor: const Color(0xFFFF6A4C),
          borderWidth: 1,
          borderDrawMode: BorderDrawMode.top,
        ),
      ],
    );
  }
}
