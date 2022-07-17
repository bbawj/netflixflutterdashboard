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

class Country {
  final int release_year;
  final String country;
  final int count;

  const Country(
      {required this.country, required this.release_year, required this.count});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      country: json['country'],
      release_year: json['release_year'],
      count: int.parse(json['count']),
    );
  }
}

Future<List<Country>> fetchCountryCounts(int year) async {
  final uri = Uri.parse("$serverUri/api/title/countries/$year");
  final response = await http.get(uri, headers: {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json"
  });
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final countList = json.decode(response.body) as List<dynamic>;
    final counts = countList.map((e) => Country.fromJson(e)).toList();
    return counts;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load counts');
  }
}

final countsProvider =
    FutureProvider.autoDispose.family<List<Country>, int>((ref, year) async {
  final counts = await fetchCountryCounts(year);
  return counts;
});

class CountryCountsBarChart extends ConsumerWidget {
  const CountryCountsBarChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = ref.watch(yearProvider);
    final countsData = ref.watch(countsProvider(year));
    return countsData.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(
                child: Text("There is no country specific data for this year"));
          }
          return AspectRatio(
              aspectRatio: 3 / 2,
              child: BarChart(BarChartData(
                  minY: 0,
                  titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          return SideTitleWidget(
                              child: Text(data[index].country),
                              axisSide: meta.axisSide);
                        },
                      )),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false))),
                  barGroups: data
                      .asMap()
                      .entries
                      .map((e) => BarChartGroupData(x: e.key, barRods: [
                            BarChartRodData(
                                toY: e.value.count as double,
                                color: Globals.black),
                          ]))
                      .toList(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final title = data[group.x.toInt()].count.toString();
                      return BarTooltipItem(
                          title, const TextStyle(color: Colors.white));
                    }),
                  ))));
        },
        error: (err, stack) => Text('Error: $err'),
        loading: () => const CircularProgressIndicator());
  }
}
