import 'dart:convert';
import '../config.dart';
import 'package:http/http.dart' as http;

class ApiManager {
  static T? tryJsonDecode<T>(http.Response response) {
    if (response.statusCode == 204) {
      return null;
    }

    try {
      return json.decode(response.body) as T;

    } catch (error) {
      throw Exception('Failed to decode json');
    }
  }

  static void checkStatusCode(http.Response response) {
    int statusCode = response.statusCode;
    if (!allowedStatusCodes.contains(statusCode)) {
      throw Exception(
          'Failed to load data, status code: ${response.statusCode}, body: ${response.body}');
    }
  }

  static Future<T> post<T>(String url,
      [Map<String, dynamic>? apiBody,
        Map<String, String>? requestHeaders]) async {

    print("Sending: ${jsonEncode(apiBody)}");

    http.Response response = await http.post(Uri.parse(apiUrl + url),
        headers: requestHeaders ?? apiHeaders, body: jsonEncode(apiBody ?? {}));

    // Disabled until status codes are handled properly
    // Necessary for addUser function, which needs the userID from returned JSON
    // checkStatusCode(response);

    print("RESP: ${response.body}");

    return tryJsonDecode(response);
  }

  static Future<T> put<T>(String url,
      [Map<String, dynamic>? apiBody,
        Map<String, String>? requestHeaders]) async {
    http.Response response = await http.put(Uri.parse(apiUrl + url),
        headers: requestHeaders ?? apiHeaders, body: jsonEncode(apiBody ?? {}));

    checkStatusCode(response);
    return tryJsonDecode(response);
  }

  static Future<T> get<T>(String url,
      [Map<String, String>? requestHeaders]) async {
    http.Response response = await http.get(Uri.parse(apiUrl + url),
        headers: requestHeaders ?? apiHeaders);
    // checkStatusCode(response);
    print("Response GET : ${response.body}");
    return tryJsonDecode(response);
  }

  static Future<T> delete<T>(String url,
      [Map<String, String>? requestHeaders]) async {
    http.Response response = await http.delete(Uri.parse(apiUrl + url),
        headers: requestHeaders ?? apiHeaders);

    checkStatusCode(response);
    return tryJsonDecode(response);
  }
}
