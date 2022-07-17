import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:netflixdashboard/constants/globals.dart';
import 'package:http/http.dart' as http;
import 'package:netflixdashboard/yearlycount.dart';

class NewTitleDialog extends ConsumerWidget {
  const NewTitleDialog({Key? key}) : super(key: key);

  submitForm(
      String id, String name, String type, double rating, int year) async {
    try {
      var response = await http.post(Uri.parse("$serverUri/api/title"),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "id": id,
            "name": name,
            "type": type,
            "rating": rating,
            "year": year
          }));
      print(response);
    } catch (err) {
      throw Exception(err);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    String id = '';
    String name = "";
    String type = '';
    double rating = 0;
    int year = ref.read(yearProvider);

    Future openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Add new title"),
              content: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: formKey,
                child: Column(children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: "ID"),
                    onSaved: (newValue) => id = newValue!,
                    validator: (value) {
                      if (value == null) {
                        return "Cannot be empty";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Name"),
                    onSaved: (newValue) => name = newValue!,
                    validator: (value) {
                      if (value == null) {
                        return "Cannot be empty";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Type"),
                    onSaved: (newValue) => type = newValue.toString(),
                    validator: (value) {
                      if (value != "movie" && value != "show") {
                        return "Enter only 'movie' or 'show'.";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Rating"),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9.,]'))
                    ],
                    onSaved: (newValue) => rating = double.parse(newValue!),
                    validator: (value) {
                      try {
                        if (value != null &&
                            (double.parse(value) > 10 ||
                                double.parse(value) < 0)) {
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
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Globals.red)),
                        onPressed: () {
                          final isValid = formKey.currentState!.validate();

                          if (isValid) {
                            formKey.currentState!.save();
                            submitForm(id, name, type, rating, year);
                            Navigator.pop(context);
                          }
                        },
                        child: const Text("Submit")),
                  )
                ]),
              ),
            ));
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: ElevatedButton(
        onPressed: openDialog,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Globals.red)),
        child: const Text("Create new title"),
      ),
    );
  }
}
