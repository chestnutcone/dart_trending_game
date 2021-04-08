import 'package:flutter/material.dart';

class ListViewCard extends StatefulWidget {
  final String phrase;
  final int index;
  final Key key;

  ListViewCard(this.phrase, this.index, this.key);

  @override
  _ListViewCard createState() => _ListViewCard();
}

class _ListViewCard extends State<ListViewCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(4),
      color: Colors.white,
      child: InkWell(
        splashColor: Colors.blue,
        onTap: () => {print("Item ${widget.phrase} selected.")},
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.topLeft,
                    child: Text(
                      widget.phrase,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.left,
                      maxLines: 5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Description ${widget.phrase}',
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 16),
                      textAlign: TextAlign.left,
                      maxLines: 5,
                    ),
                  ),
                ],
              ),
            ),
            ReorderableDragStartListener(
              index: widget.index,
              child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Icon(
                Icons.reorder,
                color: Colors.grey,
                size: 30.0,
              )),
            ),
          ],
        ),
      ),
    );
  }
}