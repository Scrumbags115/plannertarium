import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:planner/CANVAS_SECRET_AUTH_TOKEN_DO_NOT_PUSH.dart' as canvas_secret;

const canvas_url = "canvas.ucsc.edu";
Future<void> getCanvasEvents() async {
  const pagination = "page=1&limit=50";
  Map<String, String> requestHeaders = {
    "Content-type": "application/json",
    "Accept": "application/json",
    'Authorization': 'Bearer ${canvas_secret.SECRET}'
  };
  const endpoint = "/api/v1/calendar_events";
  final url = Uri.parse("http://$canvas_url$endpoint?$pagination");
  final response = await http.get(url, headers: requestHeaders);
  if (response.statusCode == 200) {
    final Map<String, dynamic> decodedJSON = jsonDecode(response.body);
    print("done fetching");
  } else {
    throw Exception("Failed to load data from Canvas");
  }
}