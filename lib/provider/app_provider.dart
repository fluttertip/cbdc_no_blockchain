import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:crypto/crypto.dart';

class AppProvider with ChangeNotifier {
  // Firebase instances
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  String _kycStatus = "not_submitted";
  bool _isTransactionInProgress = false;
  String? _transactionPin;
  bool _isBiometricEnabled = false;
  bool _transactionpin_backend = false;

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
  bool get isbiometricenabled => _isBiometricEnabled;
  String get kycStatus => _kycStatus;

  //ui loading
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  // Helper: Hash PIN using SHA256
  String _hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  //
  // Three functions for biometric auth
  //
  Future<void> loadBiometricPreference() async {
    // Load from user's Firestore document
    if (_walletuserid.isEmpty) return;
    
    try {
      final doc = await _firestore.collection('users').doc(_walletuserid).get();
      if (doc.exists) {
        _isBiometricEnabled = doc.data()?['isBiometricEnabled'] ?? false;
      }
    } catch (e) {
      print("Error loading biometric preference: $e");
    }
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool value) async {
    if (_walletuserid.isEmpty) return;
    
    try {
      await _firestore.collection('users').doc(_walletuserid).update({
        'isBiometricEnabled': value,
      });
      _isBiometricEnabled = value;
    } catch (e) {
      print("Error setting biometric: $e");
    }
    notifyListeners();
  }

  //
  // Function for login screen
  //
  Future<void> checkBiometricLoginAvailable() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return;

    _walletuserid = currentUser.uid;
    await loadBiometricPreference();
    notifyListeners();
  }

  //
  // For setting page
  //
  Future<String> getBiometricLabel() async {
    return _isBiometricEnabled ? "Disable Biometric" : "Enable Biometric";
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

  // Register User & update Data
  Future<Map<String, dynamic>> registerUser(
    String name,
    String email,
    String password,
  ) async {
    _setLoading(true);
    print("register user called");

    try {
      // Create Firebase Auth account
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      print("User registered with UID: $uid");

      // Create user document in Firestore
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'balance': 0.0,
        'dateOfBirth': '',
        'governmentIdNumber': '',
        'kycStatus': 'not_submitted',
        'transactionPin': null,
        'profilePhotoUrl': '',
        'isBiometricEnabled': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create KYC document
      await _firestore.collection('kyc').doc(uid).set({
        'profilePhotoUrl': '',
        'governmentIdImageUrl': '',
        'status': 'not_submitted',
        'dateOfBirth': '',
        'governmentIdNumber': '',
        'submittedAt': null,
        'approvedAt': null,
        'rejectionReason': null,
      });

      _walletuserid = uid;
      _fullName = name;
      _email = email;
      _balance = 0.0;
      _kycStatus = 'not_submitted';

      notifyListeners();
      print("User registered successfully with UID: $uid");

      return {'success': true, 'data': {'user': {'_id': uid, 'name': name, 'email': email, 'balance': 0.0}}};
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.message ?? "Registration failed";
      print("Registration error: $errorMessage");
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print("Registration error: $e");
      return {'success': false, 'message': e.toString()};
    } finally {
      _setLoading(false);
    }
  }

  // Login User & update Data
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    _setLoading(true);
    print("login user called");

    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      print("User logged in with UID: $uid");

      // Fetch user data from Firestore
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        _setDataOfUseronFirestoreDoc(userData, uid);
        notifyListeners();

        return {
          'success': true,
          'data': {
            'user': {'_id': uid, ...userData}
          }
        };
      } else {
        return {
          'success': false,
          'message': 'User profile not found'
        };
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.message ?? "Login failed";
      print("Login error: $errorMessage");
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print("Login error: $e");
      return {'success': false, 'message': e.toString()};
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
      final hashedPin = _hashPin(transactionPin);

      await _firestore.collection('users').doc(_walletuserid).update({
        'transactionPin': hashedPin,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print("Transaction PIN set successfully");

      _transactionPin = transactionPin;
      _transactionpin_backend = true;
      notifyListeners();

      return {'success': true};
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
      final userDoc = await _firestore.collection('users').doc(_walletuserid).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        _setDataOfUseronFirestoreDoc(userData, _walletuserid);
        notifyListeners();
        print("User details fetched successfully: $userData");
      } else {
        print("User document not found");
        throw Exception("User profile not found");
      }
    } catch (error) {
      print("Error fetching user info: $error");
      rethrow;
    }
  }

  // Fetch Transactions
  Future<void> fetchTransactions() async {
    if (_walletuserid.isEmpty) return;

    isrecenttranscationloading = true;
    notifyListeners();

    print("fetch transactions called");

    try {
      // Query transactions where user is sender or receiver
      final QuerySnapshot sentSnapshot = await _firestore
          .collection('transactions')
          .where('senderId', isEqualTo: _walletuserid)
          .orderBy('timestamp', descending: true)
          .get();

      final QuerySnapshot receivedSnapshot = await _firestore
          .collection('transactions')
          .where('receiverId', isEqualTo: _walletuserid)
          .orderBy('timestamp', descending: true)
          .get();

      // Combine and sort transactions
      final allTransactions = [
        ...sentSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>),
        ...receivedSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>),
      ];

      // Sort by timestamp descending
      allTransactions.sort((a, b) {
        final aTime = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
        final bTime = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
        return bTime.compareTo(aTime);
      });

      _transactions = allTransactions.map((transaction) {
        bool isCredit = transaction['receiverId'] == _walletuserid;
        return {
          ...transaction,
          'isCredit': isCredit,
          'timestamp': (transaction['timestamp'] as Timestamp?)?.toDate(),
        };
      }).toList();

      print("Transactions fetched: ${_transactions.length}");
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
      final QuerySnapshot sentSnapshot = await _firestore
          .collection('transactions')
          .where('senderId', isEqualTo: _walletuserid)
          .orderBy('timestamp', descending: true)
          .get();

      final QuerySnapshot receivedSnapshot = await _firestore
          .collection('transactions')
          .where('receiverId', isEqualTo: _walletuserid)
          .orderBy('timestamp', descending: true)
          .get();

      final allTransactions = [
        ...sentSnapshot.docs,
        ...receivedSnapshot.docs,
      ];

      _transactions = allTransactions.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'isCredit': data['receiverId'] == _walletuserid,
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
        };
      }).toList();

      print("User transactions fetched successfully: ${_transactions.length}");
      notifyListeners();
    } catch (e) {
      print("Error fetching individual transactions: $e");
      throw Exception("Failed to fetch transactions");
    }
  }

  void _setDataOfUseronFirestoreDoc(Map<String, dynamic> data, String uid) {
    _walletuserid = uid;
    _fullName = data['name'] ?? "";
    _email = data['email'] ?? "";
    _balance = (data['balance'] ?? 0.0).toDouble();
    _kycStatus = data['kycStatus'] ?? "not_submitted";
    _dob = data['dateOfBirth'] ?? "";
    _citizenidno = data['governmentIdNumber'] ?? "";

    // Check if transaction pin exists in backend
    if (data['transactionPin'] != null &&
        data['transactionPin'].toString().isNotEmpty) {
      _transactionpin_backend = true;
      _transactionPin = null; // Never store plaintext PIN in memory
    } else {
      _transactionpin_backend = false;
      _transactionPin = null;
    }

    print("Updated User Info:");
    print("Full Name: $_fullName");
    print("Wallet User ID: $_walletuserid");
    print("Balance: $_balance");
    print("Email: $_email");
    print("KYC Status: $_kycStatus");
    print("Transaction PIN Backend: $_transactionpin_backend");

    notifyListeners();
  }

  Future<Map<String, dynamic>> sendMoney(
    String receiverId,
    double amount,
    String pin,
    String remarks,
  ) async {
    print("Send money called with receiverId: $receiverId, amount: $amount");

    if (_walletuserid.isEmpty) {
      return {'success': false, 'message': 'User not logged in'};
    }

    if (pin.trim().isEmpty) {
      print("sendMoney aborted: missing transaction PIN");
      return {'success': false, 'message': 'Transaction PIN required'};
    }

    if (amount <= 0) {
      return {'success': false, 'message': 'Amount must be greater than zero'};
    }

    _isTransactionInProgress = true;
    notifyListeners();

    try {
      // Hash the provided PIN
      final hashedProvidedPin = _hashPin(pin);

      // Execute atomic Firestore transaction
      final result = await _firestore.runTransaction((transaction) async {
        // Read sender document
        final senderRef = _firestore.collection('users').doc(_walletuserid);
        final senderSnapshot = await transaction.get(senderRef);

        if (!senderSnapshot.exists) {
          throw Exception('Sender account not found');
        }

        final senderData = senderSnapshot.data() as Map<String, dynamic>;
        final senderBalance = (senderData['balance'] ?? 0.0).toDouble();
        final storedHashedPin = senderData['transactionPin'];

        // Verify PIN
        if (storedHashedPin == null || storedHashedPin != hashedProvidedPin) {
          throw Exception('Invalid transaction PIN');
        }

        // Check sufficient balance
        if (senderBalance < amount) {
          throw Exception('Insufficient balance');
        }

        // Read receiver document
        final receiverRef = _firestore.collection('users').doc(receiverId);
        final receiverSnapshot = await transaction.get(receiverRef);

        if (!receiverSnapshot.exists) {
          throw Exception('Receiver account not found');
        }

        final receiverData = receiverSnapshot.data() as Map<String, dynamic>;
        final receiverBalance = (receiverData['balance'] ?? 0.0).toDouble();

        // Update sender balance
        transaction.update(senderRef, {
          'balance': senderBalance - amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update receiver balance
        transaction.update(receiverRef, {
          'balance': receiverBalance + amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create transaction record
        final transactionRef = _firestore.collection('transactions').doc();
        transaction.set(transactionRef, {
          'senderId': _walletuserid,
          'senderName': _fullName,
          'receiverId': receiverId,
          'receiverName': receiverData['name'] ?? 'Unknown',
          'amount': amount,
          'transactionType': 'transfer',
          'description': remarks,
          'status': 'completed',
          'timestamp': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        return transactionRef.id;
      });

      // Update local state
      _balance = _balance - amount;
      notifyListeners();

      print("Transaction completed successfully: $result");
      return {
        'success': true,
        'data': {'transactionId': result, 'amount': amount}
      };
    } on FirebaseException catch (e) {
      print("Firestore exception: ${e.message}");
      return {'success': false, 'message': e.message ?? 'Transaction failed'};
    } catch (e) {
      print("Transaction error: $e");
      return {'success': false, 'message': e.toString()};
    } finally {
      _isTransactionInProgress = false;
      notifyListeners();
    }
  }

  // Get balance
  Future<void> getBalance() async {
    print("get balance called");

    if (_walletuserid.isEmpty) return;

    try {
      final userDoc = await _firestore.collection('users').doc(_walletuserid).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final balance = (userData['balance'] ?? 0.0).toDouble();
        print("User balance fetched successfully: $balance");
        _balance = balance;
        notifyListeners();
      } else {
        print("User document not found");
        throw Exception("User profile not found");
      }
    } catch (e) {
      print("Error fetching user balance: $e");
      rethrow;
    }
  }

  // Submit KYC
  Future<void> submitKYC(
    String dob,
    String idNumber,
    XFile profileImage,
    XFile idCardImage,
  ) async {
    if (_walletuserid.isEmpty) {
      return;
    }

    _setLoading(true);

    try {
      // TODO: Firebase Storage implementation coming soon
      // This feature will enable KYC document uploads via Firebase Storage
      // For now, we'll store the metadata only without document uploads
      
      // Update user document with KYC information (without file uploads)
      await _firestore.collection('users').doc(_walletuserid).update({
        'dateOfBirth': dob,
        'governmentIdNumber': idNumber,
        'kycStatus': 'pending',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update KYC document with metadata only
      await _firestore.collection('kyc').doc(_walletuserid).set({
        'status': 'pending',
        'dateOfBirth': dob,
        'governmentIdNumber': idNumber,
        'submittedAt': FieldValue.serverTimestamp(),
        'approvedAt': null,
        'rejectionReason': null,
        'note': 'Document uploads will be available when Firebase Storage is enabled',
      }, SetOptions(merge: true));

      _kycStatus = "pending";
      _dob = dob;
      _citizenidno = idNumber;
      notifyListeners();

      print("KYC submitted successfully! (Document uploads coming soon)");

      // Refresh user info
      await fetchUserInfo();
    } catch (e) {
      print("Error submitting KYC: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Logout User
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      print("Firebase logout successful");
    } catch (e) {
      print("Logout error: $e");
    }

    // Clear all state
    _walletuserid = "";
    _fullName = "";
    _email = "";
    _balance = 0.00;
    _dob = "";
    _citizenidno = "";
    _kycStatus = "not_submitted";
    _transactions = [];
    _transactionPin = null;
    _transactionpin_backend = false;
    _isBiometricEnabled = false;

    print("Provider state cleared");
    notifyListeners();
  }
}
