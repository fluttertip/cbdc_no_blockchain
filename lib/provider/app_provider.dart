import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:http_parser/http_parser.dart';

// Import services
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/transaction_service.dart';

class AppProvider with ChangeNotifier {
  // Services
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final TransactionService _transactionService = TransactionService();

  //vercel
  // static const String baseUrl =
  //     "https://cbdc-test-backend-test-code.vercel.app/api/v1";
  //render
  static const String baseUrl =
      "https://cbdc-test-backend-test-code.onrender.com/api/v1";

  //
  // Variables
  //
  List _transactions = [];
  bool isrecenttranscationloading = false;
  bool showbalance = false;
  String _walletuserid = "";
  String _fullName = "";
  String _email = "";
  double _balance = 0.00;
  String _dob = "";
  String _citizenidno = "";
  String _kycStatus = "Pending";
  bool _isTransactionInProgress = false;
  String? _transactionPin;
  bool _isBiometricEnabled = false;
  bool _transactionpin_backend = false;
  String? _token;

  // UI/loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Getters
  bool get isTransactionInProgress => _isTransactionInProgress;
  String? get transactionPin => _transactionPin;
  bool get transactionpin_backend => _transactionpin_backend;
  String get walletuserid => _walletuserid;
  String get fullName => _fullName;
  String get email => _email;
  double get balance => _balance;
  List<dynamic> get transactions => _transactions;
  String get dob => _dob;
  String get citizenidno => _citizenidno;
  String get baseurl => baseUrl;
  bool get isbiometricenabled => _isBiometricEnabled;
  String get kycStatus => _kycStatus;
  String? get token => _token;

  //ui loading
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  //
  // Three functions for biometric auth
  //
  Future<void> loadBiometricPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isBiometricEnabled = prefs.getBool('isbiometricenabled') ?? false;
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isbiometricenabled', value);
    _isBiometricEnabled = value;
    notifyListeners();
  }

  //
  // Function for login screen
  //
  Future<void> checkBiometricLoginAvailable() async {
    final prefs = await SharedPreferences.getInstance();
    String walletId = prefs.getString('wallet_id') ?? "";
    bool biometricEnabled = prefs.getBool('isbiometricenabled') ?? false;
    _isBiometricEnabled = biometricEnabled;
    _walletuserid = walletId;
    notifyListeners();
  }

  //
  // For setting page
  //
  Future<String> getBiometricLabel() async {
    final prefs = await SharedPreferences.getInstance();
    final isBiometricEnabled = prefs.getBool('isbiometricenabled') ?? false;
    return isBiometricEnabled ? "Disable Biometric" : "Enable Biometric";
  }

  Future<String> getTransactionPinLabel() async {
    return (_transactionPin == null || _transactionpin_backend == false)
        ? "Setup Transaction PIN"
        : "Change Transaction PIN";
  }

  // Set transaction PIN
  Future<void> setTransactionPin(String pin) async {
    _transactionPin = pin;
    _transactionpin_backend = true;
    notifyListeners();
  }

  // Get the stored transaction pin
  Future<void> loadtranscationpin() async {
    if (_transactionPin != null) return;
    if (_walletuserid.isNotEmpty) {
      try {
        await fetchUserInfo(); // fetch will update _transactionpin_backend if backend has PIN
      } catch (_) {
        // ignore
      }
    }
  }

  // Toggle show balance
  void toogleShowBalance() {
    showbalance = !showbalance;
    notifyListeners();
  }

  void setwalletidfromsharedpreftowalletidvariable(
    String walletidfromsharedpref,
  ) {
    _walletuserid = walletidfromsharedpref;
    notifyListeners();
  }

  // Save Wallet ID to SharedPreferences
  Future<void> _savewalletuserid(String walletuserid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("wallet_id", walletuserid);
  }

  // Save token to SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
  }

  // Register User & update Data
  Future<Map<String, dynamic>> registerUser(
    // BuildContext context,
    String name,
    String email,
    String password,
  ) async {
    _setLoading(true);

    print("register user called");

    try {
      final result = await _authService.register(name, email, password, null);

      print("Register result: $result");

      if (result['success'] == true) {
        final responseData = result['data'];
        print("User registered successfully: $responseData");

        _setDataOfUseronLoginAndSignUp(responseData["user"]);

        // Save token if available
        if (responseData["token"] != null) {
          _token = responseData["token"];
          await _saveToken(_token!);
        }

        await _savewalletuserid(_walletuserid);
        notifyListeners();

        return {'success': true, 'data': responseData};

        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (context) => MainNavigation()),
        //   (route) => false,
        // );
      } else {
        String errorMessage = result["message"] ?? "Registration failed";
        print(errorMessage);
        return {'success': false, 'message': errorMessage};

        // ScaffoldMessenger.of(
        //   context,
        // ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      print("Registration error: $e");
      return {'success': false, 'message': e.toString()};

      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      _setLoading(false);
    }
  }

  // Login User & update Data
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    _setLoading(true);
    print("login user called");

    try {
      final result = await _authService.login(email, password);

      print("Login result: $result");

      if (result['success'] == true) {
        final responseData = result['data'];
        print("User Logged IN successfully: $responseData");

        _setDataOfUseronLoginAndSignUp(responseData["user"]);

        // Save token if available
        if (responseData["token"] != null) {
          _token = responseData["token"];
          await _saveToken(_token!);
        }

        await _savewalletuserid(_walletuserid);

        print("Checking for wallet id: $_walletuserid");

        notifyListeners();
        return {'success': true, 'data': responseData};

        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (context) => MainNavigation()),
        //   (route) => false,
        // );
      } else {
        final message = result["message"] ?? "Login failed";

        return {'success': false, 'message': message};

        // ScaffoldMessenger.of(
        //   context,
        // ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      print("Login error: $e");
      return {'success': false, 'message': e.toString()};

      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> setupTransactionPin(
    String transactionPin,
  ) async {
    if (_walletuserid.isEmpty) {
      return {'success': false, 'message': 'User not logged in'};
    }

    try {
      final result = await _userService.setTransactionPin(
        _walletuserid,
        transactionPin,
        token: _token,
      );

      print("Set PIN API Response: $result");

      if (result['success'] == true) {
        // Update provider state in-memory only
        _transactionPin = transactionPin;
        _transactionpin_backend = true;
        notifyListeners();
        return {'success': true};
      } else {
        return {'success': false, 'message': result['message'] ?? 'Failed'};
      }
    } catch (e) {
      print("Exception while setting PIN: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  // Fetch User Details
  Future<void> fetchUserInfo() async {
    if (_walletuserid.isEmpty) return;

    print("fetch user info $_walletuserid");

    try {
      print("try fetch user info $_walletuserid");

      final result = await _userService.getShowMe(_walletuserid, token: _token);

      print("fetch user function Response: $result");

      if (result['success'] == true) {
        final data = result['data'];
        print("User details fetched successfully: $data");
        _setDataOfUseronLoginAndSignUp(data["user"]);
        notifyListeners();
      } else {
        print("Failed to fetch user info: ${result['message']}");
        throw Exception("Failed to fetch user info");
      }
    } catch (error) {
      print("Error fetching user info: $error");
    }
  }

  // Fetch Transactions
  Future<void> fetchTransactions() async {
    if (_walletuserid.isEmpty) return;

    isrecenttranscationloading = true;
    notifyListeners();

    print("fetch transactions called");

    try {
      final result = await _transactionService.getTransactionsForUser(
        _walletuserid,
        token: _token,
      );

      if (result['success'] == true) {
        print("fetchTransaction response incoming:");
        print(result['data']);

        List<dynamic> transactions = result['data']['transactions'];

        // Old implementation for showcase
        _transactions = transactions.map((transaction) {
          bool isCredit = transaction['receiver']['_id'] == _walletuserid;
          return {
            ...transaction,
            'isCredit': isCredit,
            'senderId': transaction['sender']['_id'],
            'receiverId': transaction['receiver']['_id'],
            'senderName': transaction['sender']['name'],
            'receiverName': transaction['receiver']['name'],
          };
        }).toList();
      } else {
        _transactions = [];
        print("Failed to fetch transactions: ${result['message']}");
      }
    } catch (e) {
      _transactions = [];
      print("Error fetching transactions: $e");
    }

    isrecenttranscationloading = false;
    notifyListeners();
  }

  // Fetch individual transactions
  Future<void> fetchindvidualTransactions() async {
    if (_walletuserid.isEmpty) return;

    try {
      final result = await _transactionService.getTransactionsForUser(
        _walletuserid,
        token: _token,
      );

      if (result['success'] == true) {
        _transactions = result['data']['transactions'];
        print("User transaction successfully: $_transactions");
        notifyListeners();
      } else {
        throw Exception("Failed to fetch transactions");
      }
    } catch (e) {
      print("Error fetching individual transactions: $e");
      throw Exception("Failed to fetch transactions");
    }
  }

  void _setDataOfUseronLoginAndSignUp(Map<String, dynamic> data) {
    if (_walletuserid.isEmpty) {
      _walletuserid = data['_id'] ?? data['id'] ?? "";
    }

    if (_fullName.isEmpty) {
      _fullName = data['name'] ?? "";
    }

    if (_balance == 0.00) {
      _balance = (data['balance'] ?? 0).toDouble();
    }

    if (_email.isEmpty) {
      _email = data['email'] ?? "";
    }

    _balance = (data['balance'] ?? 0).toDouble();
    _kycStatus = data['kycStatus'] ?? "Pending";
    _dob = data['dateOfBirth'] ?? "";
    _citizenidno = data['governmentIdNumber'] ?? "";
    _transactionPin = data['transactionPin'] ?? null;

    // Check if transaction pin exists in backend
    if (data['transactionPin'] != null &&
        data['transactionPin'].toString().isNotEmpty) {
      _transactionpin_backend = true;
    }

    print("kyc status: $_kycStatus");
    print("dob: $_dob");
    print("citizenidno: $_citizenidno");

    print("Updated User Info:");
    print("Full Name: $_fullName");
    print("Wallet User ID: $_walletuserid");
    print("Balance: $_balance");
    print("Email: $_email");

    notifyListeners();
  }

  Future<Map<String, dynamic>> sendMoney(
    String receiverId,
    double amount,
    String pin,
    String Remarks,
  ) async {
    print("Send money called with pin: $pin");

    if (_walletuserid.isEmpty) {
      return {'success': false, 'message': 'User not logged in'};
    }

    if (pin.trim().isEmpty) {
      print("sendMoney aborted: missing transaction PIN");
      return {'success': false, 'message': 'Transaction PIN required'};
    }

    _isTransactionInProgress = true;
    notifyListeners();

    try {
      final result = await _transactionService.createTransaction(
        senderId: _walletuserid,
        receiverId: receiverId,
        amount: amount,
        transactionType: "transfer",
        description: Remarks,
        transactionPin: pin,
        token: _token,
      );

      print("Transaction result: $result");

      if (result['success'] == true) {
        await getBalance();
        return {'success': true, 'data': result['data']};
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Transaction failed',
        };
      }
    } catch (e) {
      print("Transaction error: $e");
      return {'success': false, 'message': e.toString()};
    } finally {
      _isTransactionInProgress = false;
      notifyListeners();
    }
  }

  // Get balance
  // ...existing code...
  // Get balance
  Future<void> getBalance() async {
    print("get balance called");

    if (_walletuserid.isEmpty) return;

    try {
      final result = await _userService.getUserBalance(
        _walletuserid,
        token: _token,
      );

      // Accept multiple response shapes and extract numeric balance safely
      if (result['success'] == true) {
        // result may contain { 'balance': 123 } or { 'data': { 'balance': 123 } } or { 'balance': { 'balance': 123 } }
        dynamic balanceCandidate;
        if (result.containsKey('balance')) {
          balanceCandidate = result['balance'];
        } else if (result.containsKey('data')) {
          balanceCandidate = result['data'];
          if (balanceCandidate is Map &&
              balanceCandidate.containsKey('balance')) {
            balanceCandidate = balanceCandidate['balance'];
          }
        } else {
          balanceCandidate = result;
        }

        // If it's a map containing balance key, extract it
        if (balanceCandidate is Map &&
            balanceCandidate.containsKey('balance')) {
          balanceCandidate = balanceCandidate['balance'];
        }

        double parsedBalance = 0.0;
        if (balanceCandidate is num) {
          parsedBalance = balanceCandidate.toDouble();
        } else if (balanceCandidate is String) {
          parsedBalance = double.tryParse(balanceCandidate) ?? 0.0;
        } else {
          parsedBalance = 0.0;
        }

        print("User balance fetched successfully: $balanceCandidate");
        _balance = parsedBalance;
        notifyListeners();
      } else {
        print("Failed to fetch user balance: ${result['message']}");
        throw Exception("Failed to fetch user balance");
      }
    } catch (e) {
      print("Error fetching user balance: $e");
      throw Exception("Failed to fetch user balance");
    }
  }
  // ...existing code...

  // Submit KYC
  Future<void> submitKYC(
    // BuildContext context,
    String dob,
    String idNumber,
    XFile profileImage,
    XFile idCardImage,
  ) async {
    if (_walletuserid.isEmpty) {
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text("User not logged in!")));
      return;
    }

    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$baseUrl/images/complete-registration/$_walletuserid"),
      );

      request.fields['dateOfBirth'] = dob;
      request.fields['governmentIdNumber'] = idNumber;

      // Add token to headers if available
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'profilePhoto',
          profileImage.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'governmentIdImage',
          idCardImage.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("KYC Submitted Successfully! ✅")),
        // );
        _kycStatus = "Submitted";
        notifyListeners();

        // Once kyc updated call fetch user info to get latest user data
        await fetchUserInfo();

        // Navigate to main navigation
        // PersistentNavBarNavigator.pushNewScreen(
        //   context,
        //   screen: MainNavigation(),
        //   pageTransitionAnimation: PageTransitionAnimation.cupertino,
        //   withNavBar: true,
        // );
      } else {
        String errorMessage =
            jsonDecode(responseBody)['message'] ?? "KYC submission failed";
        print(errorMessage);
        // ScaffoldMessenger.of(
        //   context,
        // ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text("Error submitting KYC: $e")));
    }
  }

  // Logout User
  Future<void> logout() async {
    try {
      // Call logout service
      if (_token != null) {
        await _authService.logout(token: _token);
      }
    } catch (e) {
      print("Logout service error: $e");
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("wallet_id");
    await prefs.remove("auth_token");
    await prefs.setBool('isbiometricenabled', false);

    // Clear all state
    _walletuserid = "";
    _fullName = "";
    _email = "";
    _balance = 0.00;
    _dob = "";
    _citizenidno = "";
    _kycStatus = "Pending";
    _transactions = [];
    _transactionPin = null;
    _token = null;
    _transactionpin_backend = false;

    print("SharedPreferences cleared");

    // await Future.delayed(const Duration(seconds: 1), () {
    //   PersistentNavBarNavigator.pushNewScreen(
    //     context,
    //     screen: LoginScreen(),
    //     pageTransitionAnimation: PageTransitionAnimation.cupertino,
    //     withNavBar: false,
    //   );
    // });
  }
}
