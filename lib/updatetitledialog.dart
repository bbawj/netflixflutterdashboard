import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflixdashboard/barchart.dart';
import 'package:netflixdashboard/constants/globals.dart';
import 'package:http/http.dart' as http;
import 'package:netflixdashboard/yearlycount.dart';

class UpdateTitleDialog extends ConsumerWidget {
  const UpdateTitleDialog({Key? key}) : super(key: key);

  updateTitle(String id, String title, double rating) async {
    try {
      var response = await http.put(Uri.parse("$serverUri/api/title/$id"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "title": title,
            "rating": rating,
          }));
      print(response);
    } catch (err) {
      throw Exception(err);
    }
  }

  deleteTitle(String id) async {
    try {
      var response = await http.delete(Uri.parse("$serverUri/api/title/$id"));
      print(response);
    } catch (err) {
      throw Exception(err);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTitle = ref.watch(titleProvider);
    final formKey = GlobalKey<FormState>();
    String title = "";
    double rating = 0;

    return AlertDialog(
      title: Text("Update ${currentTitle.title}"),
      content: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: formKey,
        child: Column(children: [
          TextFormField(
            initialValue: currentTitle.title,
            decoration: const InputDecoration(labelText: "Name"),
            onSaved: (newValue) => title = newValue!,
            validator: (value) {
              if (value == null) {
                return "Cannot be empty";
              }
              return null;
            },
          ),
          TextFormField(
            initialValue: currentTitle.imdb_score.toString(),
            decoration: const InputDecoration(
              labelText: "Rating",
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
            ],
            onSaved: (newValue) => rating = double.parse(newValue!),
            validator: (value) {
              try {
                if (value != null &&
                    (double.parse(value) > 10 || double.parse(value) < 0)) {
                  return "Invalid range (0-10)";
                }
                return null;
              } catch (err) {
                return "Please enter a number";
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                onPressed: () {
                  final isValid = formKey.currentState!.validate();

                  if (isValid) {
                    formKey.currentState!.save();
                    updateTitle(currentTitle.id, title, rating);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Submit")),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Globals.red)),
                onPressed: () {
                  deleteTitle(currentTitle.id);
                  Navigator.pop(context);
                },
                child: const Text("Delete")),
          )
        ]),
      ),
    );
  }
}
