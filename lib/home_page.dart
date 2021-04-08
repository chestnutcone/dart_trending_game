import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'http_service.dart';
import 'list_card.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HttpService httpService = HttpService();
  String query = 'initial';
  final _maxData = 4;
  List<String> _allData = [];
  List<String> _showData = [];

  void _updateMyItems(oldIndex, newIndex) {
    if (newIndex > oldIndex) {
      newIndex = newIndex - 1;
    }
    final item = _showData.removeAt(oldIndex);
    _showData.insert(newIndex, item);
  }

  void _buildSuggestion() async {
    print('build suggestion');
    await _getSuggestion();
    print('after got suggestion');
    _setShowData(_allData);
    print(_allData);
    print(_showData);
    print('setting state');
    setState(() {
      print("build suggestion set state");
    });
  }

  Future<void> _getSuggestion() async {
    print('starting get suggestion');
    var res = await httpService.getSuggestions(query);
    print('raw list: ');
    print(res.candidates);
    _allData = res.candidates;
  }

  void _setShowData(List<String> data) {
    _showData = [];
    Random random = new Random();
    Set<int> idxs = {};

    int maxNum = min(data.length, _maxData);
    while (idxs.length < maxNum) {
      int randInt = random.nextInt(data.length);
      idxs.add(randInt);
    }
    idxs.forEach((idx) {
      _showData.add(data[idx]);
    });
    print(_showData);
  }

  List<Widget> _makeRows() {
    List<Widget> rows = [];
    for (int idx = 0; idx < _showData.length; idx++) {
      String phrase = _showData[idx];
      var row = ListViewCard(phrase, idx, ValueKey(phrase));
      rows.add(row);
    }
    return rows;
  }

  void _checkScore () {
    print('check score triggered');
    List<int> positions = _showData.map((word) => _allData.indexOf(word)).toList();
    int steps = _insertionSort(positions);
    int n = positions.length;
    int worst_case = n * n;
    int score = worst_case - steps;
    print("score $score");
  }

  int _insertionSort (List<int> arr) {
    // returns how many steps needed to sort the arr via insertion sort
    int steps = 0;

    for (int i=1; i<arr.length; i++) {
      int key = arr[i];
      int j = i - 1;
      while (j >= 0 && key < arr[j]) {
        arr[j+1] = arr[j];
        j -= 1;
        steps += 1;
      }
      arr[j+1] = key;

    }
    return steps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Trending"),
        ),
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      decoration: InputDecoration(hintText: "Enter a search"),
                      onSubmitted: (String value) {
                        print("\nsubmitted: $value");
                        setState(() {
                          this.query = value;
                          _buildSuggestion();
                        });
                      },
                    ))
                  ],
                )),
            Expanded(
                child: ReorderableListView(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    buildDefaultDragHandles: false,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        _updateMyItems(oldIndex, newIndex);
                      });
                    },
                    dragStartBehavior: DragStartBehavior.down,
                    children: _makeRows()))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _checkScore,
          tooltip: 'Enter',
          child: Icon(Icons.check)
        ),
    );
  }
}
