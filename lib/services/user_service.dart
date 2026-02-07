

// @Deprecated('Use Cloud Firestore through AppProvider instead')
// class UserService {
//   @Deprecated('Use Firestore queries through AppProvider instead')
//   Future<Map<String, dynamic>> getAllUsers({String? token}) async {
//     throw UnsupportedError(
//       'UserService is deprecated. Use Cloud Firestore through AppProvider',
//     );
//   }

//   @Deprecated('Use AppProvider.fetchUserInfo() instead')
//   Future<Map<String, dynamic>> getUserById(String id, {String? token}) async {
//     throw UnsupportedError(
//       'UserService is deprecated. Use Cloud Firestore through AppProvider',
//     );
//   }

//   @Deprecated('Use AppProvider.fetchUserInfo() instead')
//   Future<Map<String, dynamic>> getShowMe(String id, {String? token}) async {
//     throw UnsupportedError(
//       'UserService is deprecated. Use Cloud Firestore through AppProvider',
//     );
//   }

//   @Deprecated('Use Firestore update through AppProvider instead')
//   Future<Map<String, dynamic>> updateProfile(
//     String token, {
//     String? name,
//     String? email,
//     String? phone,
//   }) async {
//     throw UnsupportedError(
//       'UserService is deprecated. Use Cloud Firestore through AppProvider',
//     );
//   }

//   @Deprecated('Use FirebaseAuth.currentUser.updatePassword() instead')
//   Future<Map<String, dynamic>> updatePassword(
//     String token,
//     String oldPassword,
//     String newPassword,
//   ) async {
//     throw UnsupportedError(
//       'UserService is deprecated. Use Firebase Auth through AppProvider',
//     );
//   }

//   @Deprecated('Use AppProvider.setupTransactionPin() instead')
//   Future<Map<String, dynamic>> setTransactionPin(
//     String userId,
//     String pin, {
//     String? token,
//   }) async {
//     throw UnsupportedError(
//       'UserService is deprecated. Use AppProvider.setupTransactionPin() with Firestore',
//     );
//   }

//   @Deprecated('Use AppProvider.getBalance() instead')
//   Future<Map<String, dynamic>> getUserBalance(
//     String userId, {
//     String? token,
//   }) async {
//     throw UnsupportedError(
//       'UserService is deprecated. Use AppProvider.getBalance() with Firestore',
//     );
//   }
// }
