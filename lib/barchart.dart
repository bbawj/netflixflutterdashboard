import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:netflixdashboard/constants/globals.dart';
import 'package:netflixdashboard/updatetitledialog.dart';
import 'package:netflixdashboard/yearlycount.dart';
import 'package:netflixdashboard/linechart.dart';

final titleProvider = StateProvider<Rating>(
    (ref) => Rating(id: "", imdb_score: 0, release_year: 0, title: ""));

class MyBarChart extends ConsumerWidget {
  const MyBarChart(this.order, this.type, {Key? key}) : super(key: key);
  final String order;
  final String type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future openDialog() => showDialog(
        context: context, builder: (context) => const UpdateTitleDialog());
    final year = ref.watch(yearProvider);
    final ratingData = order == "top"
        ? type == "movie"
            ? ref.watch(topMovieRatingProvider(year))
            : ref.watch(topShowRatingProvider(year))
        : type == "movie"
            ? ref.watch(bottomMovieRatingProvider(year))
            : ref.watch(bottomShowRatingProvider(year));
    return ratingData.when(
        data: (data) {
          return AspectRatio(
              aspectRatio: 3 / 2,
              child: BarChart(BarChartData(
                  maxY: 10,
                  minY: 0,
                  titlesData: FlTitlesData(
                      bottomTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: true)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false))),
                  barGroups: data
                      .asMap()
                      .entries
                      .map((e) => BarChartGroupData(x: e.key, barRods: [
                            BarChartRodData(
                                toY: e.value.imdb_score,
                                color: type == "movie"
                                    ? Globals.red
                                    : Globals.black),
                          ]))
                      .toList(),
                  barTouchData: BarTouchData(touchTooltipData:
                      BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final title = data[group.x.toInt()].title;
                    final value = data[group.x.toInt()].imdb_score;
                    return BarTooltipItem("$title\n Rating: $value",
                        const TextStyle(color: Colors.white));
                  }), touchCallback: (FlTouchEvent event, response) {
                    if (response == null ||
                        response.spot == null ||
                        event is! FlTapDownEvent) return;
                    ref.read(titleProvider.state).state =
                        data[response.spot!.touchedBarGroupIndex];
                    openDialog();
                  }))));
        },
        error: (err, stack) => Text('Error: $err'),
        loading: () => const CircularProgressIndicator());
  }
}
