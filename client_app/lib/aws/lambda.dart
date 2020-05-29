import 'dart:convert';

import 'package:http/http.dart' as http;

Future<String> getTalksByTag(String tag, String token) async {
  const endpoint = 'https://oph6fo60tj.execute-api.us-east-1.amazonaws.com/default';
  const path = '/GetTalksByTag';
  Map headers = <String, String>{
    'Content-Type': 'application/json',
    'Authorization': token,
  };
  String body = jsonEncode(<String, Object>{
    'tag': tag,
    'doc_per_page': 2,
    'page': 1
  });
  try {
    http.Response response = await http.post(
      endpoint + path,
      headers: headers,
      body: body,
    );
    return response.body;
  } catch (e) {
    return null;
  }
}