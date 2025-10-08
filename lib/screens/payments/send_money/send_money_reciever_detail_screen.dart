import 'package:cbdcprovider/screens/payments/send_money/send_money_remarks_screen.dart';
import 'package:cbdcprovider/shared/components/custom_dial_pad.dart';
import 'package:cbdcprovider/shared/components/showorhidebalancecard.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class SendMoneyRecieverDetailScreen extends StatefulWidget {
  final String receiverId;

  const SendMoneyRecieverDetailScreen({
    Key? key,
    required this.receiverId,
  }) : super(key: key);

  @override
  _SendMoneyRecieverDetailScreenState createState() =>
      _SendMoneyRecieverDetailScreenState();
}

class _SendMoneyRecieverDetailScreenState
    extends State<SendMoneyRecieverDetailScreen> {
  TextEditingController amountController = TextEditingController();
  // String enteredAmount = "";
  // Function to add digits to the entered amount
  void addDigit(String digit) {
    setState(() {
      String currentText = amountController.text;

      if (digit == '0' || digit == '.') {
        if (currentText.isEmpty) {
          // Don't allow 0 if no digit yet
          return;
        }
      }

      if (currentText.contains('.')) {
        // Only allow one dot
        return;
      }

      amountController.text = currentText + digit;
    });
  }

// Function to remove the last digit
  void removeLastDigit() {
    setState(() {
      String currentText = amountController.text;
      if (currentText.isNotEmpty) {
        amountController.text =
            currentText.substring(0, currentText.length - 1);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    bool isFieldNotEmpty = amountController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Send Money",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDarkMode ? Color(0xFF121212) : Colors.blueAccent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Card (Same as previous page)
                ShowOrHideBalanceCard(),
                const SizedBox(height: 10),

                Card(
                  color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        //reciever name

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("first name ***",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ))
                          ],
                        ),

                        //reciever id
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              // Prevents overflow
                              child: Text(
                                "Wallet ID: ${widget.receiverId}",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: isDarkMode
                                        ? Color(0xFFE0E0E0)
                                        : Colors.black),
                                overflow: TextOverflow
                                    .ellipsis, // Adds "..." if text is too long
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                PersistentNavBarNavigator.pop(context);
                                // Navigator.pop(context);
                              },
                              icon: Icon(Icons.edit,
                                  color: isDarkMode
                                      ? Color(0xFFE0E0E0)
                                      : Colors.black),
                            ),
                          ],
                        ),
                      ],
                      // Set fixed height for the horizontal list view
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                CustomDialPad(
                  onDigitPressed: addDigit,
                  onBackspacePressed: removeLastDigit,
                  amountController: amountController,
                  isFieldNotEmpty: isFieldNotEmpty,
                  isDarkMode: isDarkMode,
                ),

                const SizedBox(height: 10),

                // Continue Button
                Container(
                  // color: Colors.red,
                  child: GestureDetector(
                    onTap: () {
                      if (amountController.text.isNotEmpty) {
                        // Proceed to next page
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: sendmoneyremarksscreen(
                            receiverId: widget.receiverId,
                            amount:
                                double.tryParse(amountController.text) ?? 0.0,
                          ),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please enter amount")));
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 68, 158, 231),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text("Continue",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
