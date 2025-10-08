import 'package:cbdcprovider/provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

class Biometricauth {
  final LocalAuthentication auth = LocalAuthentication();

  /// Main handler for both setup (enable/disable) and usage (login/send money)
  Future<void> handleBiometricAction({
    required BuildContext context,
    required bool isForSetup,
    required VoidCallback onSuccess,
    VoidCallback? onFailure,
  }) async {
    final userProvider = Provider.of<AppProvider>(context, listen: false);
    bool isBiometricEnabled = userProvider.isbiometricenabled;

    if (isForSetup) {
      // 👉 Settings mode — toggle biometric
      if (isBiometricEnabled) {
        // DISABLE directly, no need to authenticate again
        await userProvider.setBiometricEnabled(false); // or false
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Biometric Authentication Disabled")),
        );
        onSuccess();
      } else {
        // ENABLE biometric — ask for fingerprint
        bool authenticated = await authenticateUser(context);
        if (authenticated) {
          await userProvider.setBiometricEnabled(true); // or false
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Biometric Authentication Enabled")),
          );
          onSuccess();
        } else {
          onFailure?.call();
        }
      }
    } else {
      // 👉 Used for login or sending money
      if (!isBiometricEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Biometric not enabled in settings")),
        );
        onFailure?.call();
        return;
      }

      bool authenticated = await authenticateUser(context);
      if (authenticated) {
        onSuccess();
      } else {
        onFailure?.call();
      }
    }
  }

  /// Just authentication logic
  Future<bool> authenticateUser(BuildContext context) async {
    bool canCheckBiometric = await auth.canCheckBiometrics;
    if (!canCheckBiometric) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Biometric not available")),
      );
      return false;
    }

    bool authenticated = await auth.authenticate(
      localizedReason: "Authenticate to proceed",
    );

    if (!authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Biometric Authentication Failed")),
      );
    }

    return authenticated;
  }
}
