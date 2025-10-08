// ...existing code...
import '../utils/http_client.dart';

class TransactionService {
  // Create transaction (transfer / deposit / withdrawal)
  Future<Map<String, dynamic>> createTransaction({
    required String senderId,
    required String receiverId,
    required double amount,
    required String transactionType,
    String? description,
    String? token,
  }) async {
    final payload = {
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'transactionType': transactionType,
      'description': description ?? '',
    };

    final response = await HttpClient.post(
      '/transactions',
      payload,
      token: token,
    );
    if (response['success'] == true) {
      return {'success': true, 'data': response['data']};
    } else {
      return {'success': false, 'message': response['message']};
    }
  }

  // Get transactions for a user (by user id)
  Future<Map<String, dynamic>> getTransactionsForUser(
    String userId, {
    String? token,
  }) async {
    final response = await HttpClient.get(
      '/transactions/$userId',
      token: token,
    );
    if (response['success'] == true) {
      return {'success': true, 'data': response['data']};
    } else {
      return {'success': false, 'message': response['message']};
    }
  }

  // Get single transaction details
  Future<Map<String, dynamic>> getTransactionDetails(
    String transactionId, {
    String? token,
  }) async {
    final response = await HttpClient.get(
      '/transactions/getSingleTransaction/$transactionId',
      token: token,
    );
    if (response['success'] == true) {
      return {'success': true, 'data': response['data']};
    } else {
      return {'success': false, 'message': response['message']};
    }
  }
}
