import 'package:cbdcprovider/provider/app_provider.dart';
import 'package:cbdcprovider/screens/payments/send_money/send_money_reciever_detail_screen.dart';
import 'package:cbdcprovider/screens/transactions/setup_transaction_pin_screen.dart';
// import 'package:cbdcprovider/screens/transcations/setup_transaction_pin_screen.dart';
import 'package:cbdcprovider/shared/components/showorhidebalancecard.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class SendMoneyScreen extends StatefulWidget {
  final String? scannedWalletId;

  const SendMoneyScreen({Key? key, this.scannedWalletId}) : super(key: key);

  @override
  _SendMoneyScreenState createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  late TextEditingController receiverController;

  @override
  void initState() {
    super.initState();
    receiverController =
        TextEditingController(text: widget.scannedWalletId ?? "");
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Send Money",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: isDarkMode ? Color(0xFF121212) : Colors.blueAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ShowOrHideBalanceCard
              ShowOrHideBalanceCard(),

              const SizedBox(height: 15),

              // Recent Fund Transfer List (Horizontal ListView)
              Card(
                color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Text("Recent fund transfer",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Color(0xFFE0E0E0)
                                        : Colors.black87))),
                      ),
                      Container(
                        color: Colors.transparent,
                        height:
                            68, // Set fixed height for the horizontal list view
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: List.generate(5, (index) {
                            return Card(
                              color: isDarkMode
                                  ? Color.fromARGB(255, 51, 51, 51)
                                  : const Color.fromARGB(163, 231, 228, 228),
                              margin: const EdgeInsets.only(right: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Name $index",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(height: 5),
                                    Text(
                                        "NPR ${(100 + index * 20).toStringAsFixed(2)}",
                                        style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),

              Card(
                color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Receiver Wallet ID Input
                      TextField(
                        controller: receiverController,
                        decoration: InputDecoration(
                          labelText: "Receiver Wallet ID",
                          labelStyle: TextStyle(
                              color: isDarkMode
                                  ? Color(0xFFE0E0E0)
                                  : Colors.black87),
                          prefixIcon: Icon(
                            Icons.account_balance_wallet,
                            color: Colors.blueAccent,
                            size: 25,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor:
                              isDarkMode ? Color(0xFF2C2C2C) : Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Proceed Button
                      GestureDetector(
                        onTap: () async {
                          if (receiverController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Please enter valid details")),
                            );
                            return;
                          }

                          final userProvider =
                              Provider.of<AppProvider>(context, listen: false);
                          final pinStatus =
                              await userProvider.getTransactionPinLabel();

                          if (pinStatus == "Change Transaction PIN") {
                            // Transaction PIN is already set ➝ proceed
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: SendMoneyRecieverDetailScreen(
                                receiverId: receiverController.text,
                              ),
                              withNavBar: false,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Setup transaction PIN first")),
                            );
                            // PIN not set ➝ redirect to setup screen
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen:
                                  SetupTransactionPin(), // Make sure this screen is imported
                              withNavBar: false,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          }
                        },
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 75, 164, 236),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text("proceed",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),

              Card(
                color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.security,
                              color: isDarkMode ? Colors.white : Colors.black),
                          const SizedBox(width: 10),
                          Text("Secure your fund transfer",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Color(0xFFE0E0E0)
                                      : Colors.black)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                          "cbdcprovider uses blockchain technology to secure your fund transfer. Your each transaction is secured. Feel free to transfer your fund.",
                          style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode
                                  ? Color(0xFFE0E0E0)
                                  : Colors.black)),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      // ),
    );
  }
}
