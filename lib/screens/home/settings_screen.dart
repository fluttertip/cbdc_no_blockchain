import 'package:cbdcprovider/provider/app_provider.dart';
import 'package:cbdcprovider/screens/auth/biometric_auth.dart';
import 'package:cbdcprovider/screens/transactions/setup_transaction_pin_screen.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true; //for notificaitons toggle

  void _logout(context) {
    final userprovider = Provider.of<AppProvider>(context, listen: false);
    userprovider.logout(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: Consumer<AppProvider>(
        builder: (context, value, child) => ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Section: Security
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Security",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: FutureBuilder<String>(
                future: Provider.of<AppProvider>(context, listen: false)
                    .getTransactionPinLabel(),
                builder: (context, snapshot) {
                  return Text(snapshot.data ?? "Setup Transaction PIN");
                },
              ),
              onTap: () => PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: SetupTransactionPin(),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              ),
            ),

            ListTile(
              leading: const Icon(Icons.fingerprint),
              title: FutureBuilder(
                future: Provider.of<AppProvider>(context, listen: false)
                    .getBiometricLabel(),
                builder: (context, snapshot) {
                  return Text(
                      snapshot.data ?? "Enable Biometric Authentication");
                },
              ),
              onTap: () async {
                Biometricauth().handleBiometricAction(
                  context: context,
                  isForSetup: true, // this is for enabling/disabling
                  onSuccess: () {
                    setState(() {}); // refresh to show updated label
                  },
                );
              },
            ),

            const Divider(height: 30),

            // Section: Preferences
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Preferences",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            // Inside the Preferences section ListView
            ListTile(
              title: Text("Enable Notifications"),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                    // Optionally, save to SharedPreferences if you want to persist the setting
                  });
                },
              ),
            ),

            const Divider(height: 30),

            // Section: Support
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Support",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text("Help & Support"),
              onTap: () {
                // Navigate to Help & Support Screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About"),
              onTap: () {
                // Navigate to About Screen (app version, etc.)
              },
            ),

            const Divider(height: 30),

            // Section: Session
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Session",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () => _logout(context),
            ),

            
          ],
        ),
      ),
    );
  }
}
