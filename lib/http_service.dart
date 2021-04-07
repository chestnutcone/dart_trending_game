import 'package:http/http.dart';
import 'suggestion_model.dart';

class HttpService {
  Future<Suggestion> getSuggestions(search) async {
    final Uri postsURL = Uri.parse(
        "https://toolbarqueries.google.com/complete/search?q=$search&output=toolbar&hl=en");
    Response res = await get(postsURL);

    if (res.statusCode == 200) {
      Suggestion suggestion = Suggestion.fromXML(res.body);
      print('returning from http');
      return suggestion;
    } else {
      throw "Unable to retrieve suggestions from google";
    }
  }
}