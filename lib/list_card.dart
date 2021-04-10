import 'package:flutter/material.dart';

class ListViewCard extends StatefulWidget {
  final String phrase;
  final String description;
  final int index;
  final Key key;
  final bool reorderable;
  final colorLevel;

  ListViewCard(this.phrase, this.index, this.description, this.reorderable, this.colorLevel, this.key);

  @override
  _ListViewCard createState() => _ListViewCard();
}

class _ListViewCard extends State<ListViewCard> {

  Widget _getReorderWidget () {
    const child = Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: Icon(
          Icons.reorder,
          color: Colors.grey,
          size: 30.0,));
    Widget w = child;
    if (widget.reorderable) {
      w = ReorderableDragStartListener(
          index: widget.index,
          child: child
      );
    }
    return w;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(4),
      color: (widget.reorderable || widget.colorLevel == null)? Colors.white : Colors.lime[widget.colorLevel],
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
                      widget.description,
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 16),
                      textAlign: TextAlign.left,
                      maxLines: 5,
                    ),
                  ),
                ],
              ),
            ),
            _getReorderWidget(),
          ],
        ),
      ),
    );
  }
}