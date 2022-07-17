import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:netflixdashboard/constants/globals.dart';

class Count {
  final int count;
  final String release_year;
  final String type;

  const Count(
      {required this.count, required this.release_year, required this.type});

  factory Count.fromJson(Map<String, dynamic> json) {
    return Count(
      count: int.parse(json['count']),
      release_year: json['release_year'].toString(),
      type: json['type'],
    );
  }
}

Future<List<Count>> fetchCounts() async {
  final response = await http.get(Uri.parse("$serverUri/api/title/years"),
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json"
      });
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final countList = json.decode(response.body) as List<dynamic>;
    final counts =
        countList.map((e) => Count.fromJson(e)).toList().reversed.toList();
    return counts;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

final countProvider = FutureProvider<List<Count>>((ref) async {
  final counts = await fetchCounts();
  return counts;
});

final yearProvider = StateProvider<int>((ref) => 2022);

class CountLineChart extends ConsumerWidget {
  const CountLineChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingData = ref.watch(countProvider);
    return ratingData.when(
        data: (data) {
          return Padding(
              padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 40),
              child: SizedBox(
                  child: LineChart(LineChartData(
                      minY: 0,
                      titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  reservedSize: 30,
                                  interval: 1,
                                  getTitlesWidget: bottomTitleWidgets,
                                  showTitles: true)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false))),
                      lineBarsData: [
                        LineChartBarData(
                            spots: data
                                .where((e) => e.type == "MOVIE")
                                .map((e) => FlSpot(double.parse(e.release_year),
                                    e.count as double))
                                .toList(),
                            color: Globals.red,
                            isCurved: true,
                            preventCurveOverShooting: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFb92028),
                                  const Color(0xFFdf0707)
                                ].toList(),
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              spotsLine: BarAreaSpotsLine(
                                show: false,
                              ),
                            )),
                        LineChartBarData(
                            spots: data
                                .where((e) => e.type == "SHOW")
                                .map((e) => FlSpot(double.parse(e.release_year),
                                    e.count as double))
                                .toList(),
                            color: const Color(0xFF221f1f),
                            isCurved: true,
                            preventCurveOverShooting: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: const Color(0xFF221f1f),
                              spotsLine: BarAreaSpotsLine(
                                show: false,
                              ),
                            ))
                      ],
                      lineTouchData: LineTouchData(
                        touchSpotThreshold: 20,
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Color.fromARGB(255, 231, 236, 238)
                              .withOpacity(0.8),
                        ),
                        touchCallback:
                            (FlTouchEvent event, LineTouchResponse? lineTouch) {
                          if (lineTouch == null ||
                              lineTouch.lineBarSpots == null ||
                              event is! FlTapDownEvent) {
                            return;
                          }
                          final year = lineTouch.lineBarSpots![0].x;
                          ref.read(yearProvider.notifier).state = year as int;
                        },
                      )))));
        },
        error: (err, stack) => Text('Error: $err'),
        loading: () => const CircularProgressIndicator());
  }
}

Widget bottomTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Globals.red,
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );
  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 16,
    child: Text(value.toString(), style: style),
  );
}
