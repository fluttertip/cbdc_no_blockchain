import '../utils/http_client.dart';

class UserService {
  Future<Map<String, dynamic>> getAllUsers({String? token}) async {
    final response = await HttpClient.get('/user', token: token);
    if (response['success'] == true) {
      return {'success': true, 'data': response['data']};
    } else {
      return {'success': false, 'message': response['message']};
    }
  }

  // Get user by id
  Future<Map<String, dynamic>> getUserById(String id, {String? token}) async {
    final response = await HttpClient.get('/user/$id', token: token);
    if (response['success'] == true) {
      return {'success': true, 'data': response['data']};
    } else {
      return {'success': false, 'message': response['message']};
    }
  }

  // Get current user (showMe)
  Future<Map<String, dynamic>> getShowMe(String id, {String? token}) async {
    final response = await HttpClient.get('/user/showMe/$id', token: token);
    if (response['success'] == true) {
      return {'success': true, 'data': response['data']};
    } else {
      return {'success': false, 'message': response['message']};
    }
  }

  // Update profile (name/email/phone)
  Future<Map<String, dynamic>> updateProfile(
    String token, {
    String? name,
    String? email,
    String? phone,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (email != null) payload['email'] = email;
    if (phone != null) payload['phone'] = phone;

    final response = await HttpClient.put(
      '/user/updateUser',
      payload,
      token: token,
    );
    if (response['success'] == true) {
      return {'success': true, 'data': response['data']};
    } else {
      return {'success': false, 'message': response['message']};
    }
  }

  // Update password
  Future<Map<String, dynamic>> updatePassword(
    String token,
    String oldPassword,
    String newPassword,
  ) async {
    final response = await HttpClient.put('/user/updateUserPassword', {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    }, token: token);

    if (response['success'] == true) {
      return {'success': true};
    } else {
      return {'success': false, 'message': response['message']};
    }
  }

  // Set / update transaction PIN (backend expects userId + transactionPin)
  Future<Map<String, dynamic>> setTransactionPin(
    String userId,
    String pin, {
    String? token,
  }) async {
    final response = await HttpClient.post('/user/setpin', {
      'userId': userId,
      'transactionPin': pin,
    }, token: token);

    if (response['success'] == true) {
      return {'success': true, 'data': response['data']};
    } else {
      return {'success': false, 'message': response['message']};
    }
  }

  // Get user balance by id
  Future<Map<String, dynamic>> getUserBalance(
    String userId, {
    String? token,
  }) async {
    final response = await HttpClient.get(
      '/user/getbalance/$userId',
      token: token,
    );
    if (response['success'] == true) {
      return {'success': true, 'balance': response['data']};
    } else {
      return {'success': false, 'message': response['message']};
    }
  }
}
