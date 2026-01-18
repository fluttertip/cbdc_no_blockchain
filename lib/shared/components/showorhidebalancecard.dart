
import 'package:cbdcprovider/provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ShowOrHideBalanceCard extends StatelessWidget {
  const ShowOrHideBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AppProvider>(
        builder: (context, value, child) => Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance_wallet,
                              color: isDarkMode
                                  ? Color(0xFFE0E0E0)
                                  : Colors.black),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              value.showbalance
                                  ? Row(
                                      children: [
                                        Text(
                                          "NPR ",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: isDarkMode
                                                  ? Color(0xFFE0E0E0)
                                                  : Colors.black),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          "${value.balance.toStringAsFixed(2)}",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: isDarkMode
                                                  ? Color(0xFFE0E0E0)
                                                  : Colors.black),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Text(
                                          "NPR ",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: isDarkMode
                                                  ? Color(0xFFE0E0E0)
                                                  : Colors.black),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          "****",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: isDarkMode
                                                  ? Color(0xFFE0E0E0)
                                                  : Colors.black),
                                        ),
                                      ],
                                    ),
                              Text("Balance",
                                  style: TextStyle(
                                      fontSize: 14,
                                      // fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Color(0xFFE0E0E0)
                                          : Colors.black)),
                            ],
                          ),
                        ],
                      ),
                      //hide or show balance icon

                      value.showbalance
                          ? IconButton(
                              onPressed: () {
                                value.toogleShowBalance();
                              },
                              icon: Icon(Icons.visibility,
                                  color: isDarkMode
                                      ? Color(0xFFE0E0E0)
                                      : Colors.black),
                            )
                          : IconButton(
                              onPressed: () {
                                value.toogleShowBalance();
                              },
                              icon: Icon(Icons.visibility_off,
                                  color: isDarkMode
                                      ? Color(0xFFE0E0E0)
                                      : Colors.black),
                            )
                    ],
                  ),
                ),
              ),
            ));
  }
}
