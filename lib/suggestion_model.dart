import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';

class Suggestion {
  final candidates;

  Suggestion({
    @required this.candidates
  });

  factory Suggestion.fromXML(String xmlString) {
   var raw = XmlDocument.parse(xmlString);
   var elements = raw.findAllElements("suggestion");
   var candidates = <String>[];
   for (var element in elements) {
     // if null give empty str as default
     candidates.add(element.getAttribute('data') ?? '');
   }
   return Suggestion(candidates: candidates);
  }
}