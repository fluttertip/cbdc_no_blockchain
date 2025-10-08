import 'package:cbdcprovider/provider/app_provider.dart';
import 'package:cbdcprovider/screens/auth/biometric_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:cbdcprovider/screens/main_navigation.dart';

class TransactionPinCheck extends StatefulWidget {
  final String receiverId;
  final double amount;
  final String Remarks;

  TransactionPinCheck({
    super.key,
    required this.receiverId,
    required this.amount,
    required this.Remarks,
  });

  @override
  State<TransactionPinCheck> createState() => _TransactionPinState();
}

class _TransactionPinState extends State<TransactionPinCheck> {
  final TextEditingController _pinController = TextEditingController();
  bool _hasShownBiometricPopup = false;

  @override
  void initState() {
    super.initState();
    _initializeBiometric();
  }

  Future<void> _initializeBiometric() async {
    final userProvider = Provider.of<AppProvider>(context, listen: false);
    await userProvider.loadBiometricPreference();
    await userProvider.loadtranscationpin();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userProvider.isbiometricenabled && !_hasShownBiometricPopup) {
        _hasShownBiometricPopup = true;
        _authenticateAndSend(userProvider);
      }
    });
  }

  Future<void> _authenticateAndSend(AppProvider userProvider) async {
    await Biometricauth().handleBiometricAction(
      context: context,
      isForSetup: false,
      onSuccess: () {
        String? savedPin = userProvider.transactionPin;
        if (savedPin != null && savedPin.length == 4) {
          _sendWithPin(savedPin);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Saved PIN not found.")),
            );
          }
        }
      },
      onFailure: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Authentication cancelled")),
          );
        }
      },
    );
  }

  void _sendWithPin(String pin) async {
    final userProvider = Provider.of<AppProvider>(context, listen: false);

    final result = await userProvider.sendMoney(
      widget.receiverId,
      widget.amount,
      pin,
      widget.Remarks,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      // success: show message and navigate to main navigation
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Transaction successful")));

      // Replace stack with main navigation
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: MainNavigation(),
        withNavBar: true,
        pageTransitionAnimation: PageTransitionAnimation.cupertino,
      );
    } else {
      final msg = result['message'] ?? 'Transaction failed';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $msg")));
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<AppProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Enter Transaction PIN"),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter your 4-digit PIN",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Pinput(
              controller: _pinController,
              length: 4,
              obscureText: true,
              keyboardType: TextInputType.number,
              animationCurve: Curves.easeInOut,
              autofocus: true,
              defaultPinTheme: PinTheme(
                width: 50,
                height: 50,
                textStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: userProvider.isTransactionInProgress
                    ? null
                    : () => _sendWithPin(_pinController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.blueAccent : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: userProvider.isTransactionInProgress
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Confirm", style: TextStyle(fontSize: 16)),
              ),
            ),
            Selector<AppProvider, bool>(
              selector: (_, provider) => provider.isbiometricenabled,
              builder: (context, isEnabled, child) {
                if (!isEnabled) return SizedBox.shrink();
                return Column(
                  children: [
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        final userProvider = Provider.of<AppProvider>(
                          context,
                          listen: false,
                        );
                        await _authenticateAndSend(userProvider);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fingerprint,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Use Biometric Authentication",
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
