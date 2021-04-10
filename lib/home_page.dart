import 'dart:math';
import 'package:flutter/cupertino.dart';
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
  String query = "";
  final _maxData = 4;
  int session_score = 0;
  int session_number = 0;
  final int max_session_number = 10;
  List<String> _allData = [];
  List<String> _showData = [];
  bool reorderable = true;
  final card_color = {
    0: 50,
    1: 100,
    2: 200,
    3: 300
  };
  //final List<String> phrasesDB = ['hi', 'how are you', 'what is a', 'covid is', 'unlike what'];
  final List<String> phrasesDB = ['hi', 'asidjaosdji'];
  Map<String, String> phraseLevel2 = new Map(); // keep track of first suggestion of a phrase (ie first suggestion of first suggestion)

  @override
  void initState() {
    super.initState();
    _nextRound();
  }

  void _updateMyItems(oldIndex, newIndex) {
    if (newIndex > oldIndex) {
      newIndex = newIndex - 1;
    }
    final item = _showData.removeAt(oldIndex);
    _showData.insert(newIndex, item);
  }

  String _getRandomQuery () {
    Random random = new Random();
    int randInt = random.nextInt(phrasesDB.length);
    return phrasesDB[randInt];
  }

  void _buildSuggestion() async {
    await _getSuggestion();
    _setShowData(_allData);
    phraseLevel2 = new Map<String, String>();
    for (int i=0; i<_showData.length; i++) {
      await _getSuggestion2(_showData[i]);
    }
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
    int maxLoopDepth = 100;
    int loopCount = 0;
    while (res.candidates.length == 0) {
      // try new query
      this.query = _getRandomQuery();
      res = await httpService.getSuggestions(query);
      loopCount += 1;
      if (loopCount > maxLoopDepth) {
        throw Exception("Unreasonable max loop depth");
      }
    }

    print('raw list: ');
    print(res.candidates);
    _allData = res.candidates;
  }

  Future<void> _getSuggestion2(phrase) async {
    // get first suggestion of a suggestion
    var res = await httpService.getSuggestions(phrase);
    var firstSuggestion = res.candidates.isNotEmpty ? res.candidates[1] : '';
    phraseLevel2[phrase] = firstSuggestion;
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
    Map<int, int> idxMap = _indexPositionMap();
    for (int idx = 0; idx < _showData.length; idx++) {
      String phrase = _showData[idx];
      var colorLevel = card_color[idxMap[_allData.indexOf(phrase)]];
      String description = phraseLevel2[phrase] ?? "";
      var row = ListViewCard(phrase, idx, description,reorderable, colorLevel, ValueKey(phrase));
      rows.add(row);
    }
    return rows;
  }

  Map<int, int> _indexPositionMap () {
    List<int> positions = _showData.map((word) => _allData.indexOf(word)).toList();
    positions.sort();
    var mapping = new Map<int, int>();
    for (var i=0; i<positions.length; i++) {
      mapping[positions[i]] = i;
    }
    return mapping;
  }

  void _checkNextAction () {
    if (this.reorderable) {
      _checkScore();
    } else {
      _nextRound();
    }
  }

  void _nextRound() {
    // generate new word and set state
    this.reorderable = true;
    this.session_number += 1;
    this.query = _getRandomQuery();
    setState(() {
      _buildSuggestion();
    });
  }

  void _checkScore () {
    this.reorderable = false;
    print('check score triggered');

    List<int> positions = _showData.map((word) => _allData.indexOf(word)).toList();
    int steps = _insertionSort(positions);
    int n = positions.length;
    int worstCase = (0.5*(n-1)*(n)).round();
    int score = worstCase - steps;
    print("score $score");

    setState(() {
      session_score += score;
    });
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

  Widget _getNextIcon () {
    Widget icon = Icon(Icons.check);
    if (!this.reorderable) {
      icon = Icon(Icons.arrow_forward);
    }
    return icon;
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
            // Container(
            //     padding: EdgeInsets.all(10),
            //     child: Row(
            //       children: [
            //         Expanded(
            //             child: TextField(
            //           decoration: InputDecoration(hintText: "Enter a search"),
            //           onSubmitted: (String value) {
            //             print("\nsubmitted: $value");
            //             setState(() {
            //               this.query = value;
            //               _buildSuggestion();
            //             });
            //           },
            //         ))
            //       ],
            //     )),
            Container(
              padding: EdgeInsets.fromLTRB(0, 30, 0, 30),
              child: Text(
                "Score $session_score",
                style: TextStyle(fontSize: 30),
              )
            ),
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
                    children: _makeRows())
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _checkNextAction,
          tooltip: 'Enter',
          child: _getNextIcon()
        ),
    );
  }
}
