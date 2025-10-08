import '../utils/http_client.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await HttpClient.post('/user/login', {
      'email': email,
      'password': password,
      'type': 'user',
    });

    if (response['success'] == true) {
      return {'success': true, 'data': response['data']};
    } else {
      return {'success': false, 'message': response['message']};
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String? phone,
  ) async {
    final payload = {'name': name, 'email': email, 'password': password};
    if (phone != null) payload['phone'] = phone;

    final response = await HttpClient.post('/user/register', payload);

    if (response['success'] == true) {
      return {'success': true, 'data': response['data']};
    } else {
      return {'success': false, 'message': response['message']};
    }
  }

  Future<Map<String, dynamic>> logout({String? token}) async {
    final response = await HttpClient.get('/user/logout', token: token);
    if (response['success'] == true) {
      return {'success': true};
    } else {
      return {'success': false, 'message': response['message']};
    }
  }
}