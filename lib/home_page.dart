import 'dart:async';

import 'package:flutter/material.dart';
import 'http_service.dart';
import 'suggestion_model.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HttpService httpService = HttpService();
  String query = 'initial';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Posts"),
        ),
        body: Column(
          children: [
            Expanded(child: TextField(
              decoration: InputDecoration(
                  hintText: "Enter a search"
              ),
              onSubmitted: (String value) {
                print("\nsubmitted: $value");
                setState(() {
                  this.query = value;
                });
                },
            )),
            Expanded(child: FutureBuilder(
              future: httpService.getSuggestions(query),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  var suggestion = snapshot.data!;
                  return ListView(
                    children: suggestion.candidates.map<Widget>((String word) => ListTile(
                      title: Text(word),
                    ),
                    ).toList(),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              })
            )
          ],
        )
    );
  }
}