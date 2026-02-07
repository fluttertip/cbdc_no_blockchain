
// import 'package:cloud_firestore/cloud_firestore.dart';

// @Deprecated('Use Cloud Firestore transactions through AppProvider instead')
// class TransactionService {
//   @Deprecated('Use AppProvider.sendMoney() instead')
//   Future<Map<String, dynamic>> createTransaction({
//     required String senderId,
//     required String receiverId,
//     required double amount,
//     required String transactionType,
//     required String transactionPin,
//     String? description,
//     String? token,
//   }) async {
//     throw UnsupportedError(
//       'TransactionService is deprecated. Use AppProvider.sendMoney() with Firestore transactions',
//     );
//   }

//   @Deprecated('Use AppProvider.fetchTransactions() instead')
//   Future<Map<String, dynamic>> getTransactionsForUser(
//     String userId, {
//     String? token,
//   }) async {
//     throw UnsupportedError(
//       'TransactionService is deprecated. Use AppProvider.fetchTransactions() with Firestore queries',
//     );
//   }

//   @Deprecated('Use Firestore queries through AppProvider instead')
//   Future<Map<String, dynamic>> getTransactionDetails(
//     String transactionId, {
//     String? token,
//   }) async {
//     throw UnsupportedError(
//       'TransactionService is deprecated. Use Cloud Firestore through AppProvider',
//     );
//   }
// }
