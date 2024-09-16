import 'dart:convert';

class Response {
  final int statusCode;
  final Map<String, dynamic> body;

  Response(this.statusCode, this.body);

  factory Response.fromString(String response) {
    final parts = response.split("\n");
    final statusCode = int.parse(parts[0]);
    final body = parts[1];
    var map = jsonDecode(body);
    return Response(statusCode, map);
  }
}
