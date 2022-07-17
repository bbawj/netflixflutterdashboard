import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflixdashboard/barchart.dart';
import 'package:netflixdashboard/countrieschart.dart';
import 'package:netflixdashboard/linechart.dart';
import 'package:netflixdashboard/newtitledialog.dart';
import 'package:netflixdashboard/yearlycount.dart';

import 'constants/globals.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({Key? key, required String title}) : super(key: key);

  String get title => "";

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final year = ref.watch(yearProvider);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(mainAxisSize: MainAxisSize.min, children: const [
                Text(
                  "Number of ",
                  style: TextStyle(fontSize: 20, color: Colors.blueGrey),
                ),
                Text("Movies ",
                    style: TextStyle(
                        color: Globals.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text(
                  "and ",
                  style: TextStyle(fontSize: 20, color: Colors.blueGrey),
                ),
                Text("Shows ",
                    style: TextStyle(
                        color: Globals.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text(
                  "by Release Year",
                  style: TextStyle(fontSize: 20, color: Colors.blueGrey),
                )
              ]),
            ),
            const Text(
              "Click below to select a year",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 400,
              width: MediaQuery.of(context).size.width * 1,
              child: const CountLineChart(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Currently Viewing: ",
                      style: TextStyle(fontSize: 20)),
                  Text("$year",
                      style: const TextStyle(fontSize: 20, color: Globals.red)),
                  const NewTitleDialog()
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Total releases according to country",
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(
                height: 300,
                width: MediaQuery.of(context).size.width * 1,
                child: const CountryCountsBarChart()),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Click on a movie or show below to update/delete",
                style: TextStyle(
                    fontSize: 16,
                    color: Globals.red,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 300,
              width: null,
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: const [
                        Text("Top 10 Movies",
                            style:
                                TextStyle(fontSize: 16, color: Globals.black)),
                        Expanded(flex: 1, child: MyBarChart("top", "movie")),
                      ],
                    ),
                    Column(
                      children: const [
                        Text("Bottom 10 Movies",
                            style:
                                TextStyle(fontSize: 16, color: Globals.black)),
                        Expanded(flex: 1, child: MyBarChart("bottom", "movie")),
                      ],
                    ),
                  ]),
            ),
            SizedBox(
              height: 300,
              width: null,
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: const [
                        Text("Top 10 Shows",
                            style:
                                TextStyle(fontSize: 16, color: Globals.black)),
                        Expanded(flex: 1, child: MyBarChart("top", "show")),
                      ],
                    ),
                    Column(
                      children: const [
                        Text("Bottom 10 Shows",
                            style:
                                TextStyle(fontSize: 16, color: Globals.black)),
                        Expanded(flex: 1, child: MyBarChart("bottom", "show")),
                      ],
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
