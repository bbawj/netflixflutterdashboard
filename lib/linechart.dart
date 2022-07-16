import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:netflixdashboard/constants/globals.dart';
import 'package:netflixdashboard/yearlycount.dart';

class Rating {
  final String title;
  final int release_year;
  final double imdb_score;

  const Rating(
      {required this.title,
      required this.release_year,
      required this.imdb_score});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      title: json['title'],
      release_year: json['release_year'],
      imdb_score: double.parse(json['imdb_score']),
    );
  }
}

Future<List<Rating>> fetchRating(int year) async {
  final response = await http.get(Uri.parse("$serverUri/api/score/$year"),
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json"
      });
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    final ratingList = json.decode(response.body) as List<dynamic>;
    print(ratingList);
    final ratings = ratingList.map((e) => Rating.fromJson(e)).toList();
    return ratings;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

final ratingProvider =
    FutureProvider.family<List<Rating>, int>((ref, year) async {
  final ratings = await fetchRating(year);
  return ratings;
});

class RatingLineChart extends ConsumerWidget {
  const RatingLineChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = ref.watch(yearProvider);
    final ratingData = ref.watch(ratingProvider(year));
    return ratingData.when(
        data: (data) {
          return Padding(
              padding: const EdgeInsets.all(4),
              child: SizedBox(
                  child: LineChart(LineChartData(lineBarsData: [
                LineChartBarData(
                    spots: data
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key as double, e.value.imdb_score))
                        .toList())
              ], minY: 0, maxY: 10))));
        },
        error: (err, stack) => Text('Error: $err'),
        loading: () => const CircularProgressIndicator());
  }
}
