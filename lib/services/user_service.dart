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

  Future<Map<String, dynamic>> setTransactionPin(
    String userId,
    String pin, {
    String? token,
  }) async {
    try {
      // Try primary GET endpoint (as docs)
      // final endpoint1 =
      //     '/user/setPin?userId=${Uri.encodeComponent(userId)}&transactionPin=${Uri.encodeComponent(pin)}';
      // var response = await HttpClient.get(endpoint1, token: token);

      // if (response['success'] == true) {
      //   return {'success': true, 'data': response['data']};
      // }

      // // If not found / route does not exist, try lowercase variant
      // final endpoint2 =
      //     '/user/setpin?userId=${Uri.encodeComponent(userId)}&transactionPin=${Uri.encodeComponent(pin)}';
      // response = await HttpClient.get(endpoint2, token: token);
      // if (response['success'] == true) {
      //   return {'success': true, 'data': response['data']};
      // }

      // Final fallback: try POST (some deployments use POST)
      final response = await HttpClient.post('/user/setpin', {
        'userId': userId,
        'transactionPin': pin,
      }, token: token);
      if (response['success'] == true) {
        return {'success': true, 'data': response['data']};
      }

      // No success from any attempt
      return {
        'success': false,
        'message': response['message'] ?? 'Failed to set PIN on server',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
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
