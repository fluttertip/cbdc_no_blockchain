
// @Deprecated('Use FirebaseAuth through AppProvider instead')
// class AuthService {
//   @Deprecated('Use AppProvider.loginUser() instead')
//   Future<Map<String, dynamic>> login(String email, String password) async {
//     throw UnsupportedError(
//       'AuthService is deprecated. Use AppProvider.loginUser() with Firebase Auth',
//     );
//   }

//   @Deprecated('Use AppProvider.registerUser() instead')
//   Future<Map<String, dynamic>> register(
//     String name,
//     String email,
//     String password,
//     String? phone,
//   ) async {
//     throw UnsupportedError(
//       'AuthService is deprecated. Use AppProvider.registerUser() with Firebase Auth',
//     );
//   }

//   @Deprecated('Use AppProvider.logout() instead')
//   Future<Map<String, dynamic>> logout({String? token}) async {
//     throw UnsupportedError(
//       'AuthService is deprecated. Use AppProvider.logout() with FirebaseAuth.signOut()',
//     );
//   }
// }