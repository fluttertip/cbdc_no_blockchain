import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpClient {
  //vercel
  // static const String baseUrl =
  // "https://cbdc-test-backend-test-code.vercel.app/api/v1";
  //render
  static const String baseUrl =
      "https://cbdc-test-backend-test-code.onrender.com/api/v1";
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
  }) async {
    final Map<String, String> requestHeaders = Map<String, String>.from(
      headers,
    );
    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    print("➡️ GET Request: $baseUrl$endpoint");
    print("Headers: $requestHeaders");

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: requestHeaders,
      );
      print("⬅️ GET Response [${response.statusCode}]: ${response.body}");
      return _processResponse(response);
    } catch (e) {
      print("❌ GET Error: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    dynamic data, {
    String? token,
  }) async {
    final Map<String, String> requestHeaders = Map<String, String>.from(
      headers,
    );
    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    print("➡️ POST Request: $baseUrl$endpoint");
    print("Headers: $requestHeaders");
    print("Body: ${json.encode(data)}");

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: requestHeaders,
        body: json.encode(data),
      );
      print("⬅️ POST Response [${response.statusCode}]: ${response.body}");
      return _processResponse(response);
    } catch (e) {
      print("❌ POST Error: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    dynamic data, {
    String? token,
  }) async {
    final Map<String, String> requestHeaders = Map<String, String>.from(
      headers,
    );
    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    print("➡️ PUT Request: $baseUrl$endpoint");
    print("Headers: $requestHeaders");
    print("Body: ${json.encode(data)}");

    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: requestHeaders,
        body: json.encode(data),
      );
      print("⬅️ PUT Response [${response.statusCode}]: ${response.body}");
      return _processResponse(response);
    } catch (e) {
      print("❌ PUT Error: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? token,
  }) async {
    final Map<String, String> requestHeaders = Map<String, String>.from(
      headers,
    );
    if (token != null) {
      requestHeaders['Authorization'] = 'Bearer $token';
    }

    print("➡️ DELETE Request: $baseUrl$endpoint");
    print("Headers: $requestHeaders");

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: requestHeaders,
      );
      print("⬅️ DELETE Response [${response.statusCode}]: ${response.body}");
      return _processResponse(response);
    } catch (e) {
      print("❌ DELETE Error: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  static Map<String, dynamic> _processResponse(http.Response response) {
    print("📦 Processing Response...");
    print("Status Code: ${response.statusCode}");
    print("Raw Body: ${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = json.decode(response.body);
        print("✅ Decoded Response: $decoded");
        return {'success': true, 'data': decoded};
      } catch (e) {
        print("⚠️ JSON Decode Error: $e");
        return {'success': true, 'data': response.body};
      }
    } else {
      final errorMessage = _getErrorMessage(response);
      print("❌ Error Response: $errorMessage");
      return {
        'success': false,
        'message': errorMessage,
        'statusCode': response.statusCode,
      };
    }
  }

  static String _getErrorMessage(http.Response response) {
    try {
      final Map<String, dynamic> body = json.decode(response.body);
      print("⚠️ Error Body: $body");
      return body['message'] ?? 'Unknown error occurred';
    } catch (e) {
      print("⚠️ Failed to decode error body: $e");
      return 'Error: ${response.statusCode}';
    }
  }
}
