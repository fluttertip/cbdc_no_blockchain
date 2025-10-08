import 'package:cbdcprovider/provider/app_provider.dart';
import 'package:cbdcprovider/screens/transactions/transaction_detail_screen.dart';
import 'package:cbdcprovider/shared/components/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

// ...existing imports...

class RecentTranscation extends StatefulWidget {
  const RecentTranscation({super.key});

  @override
  State<RecentTranscation> createState() => _RecentTranscationState();
}

class _RecentTranscationState extends State<RecentTranscation> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<AppProvider>(context, listen: false);
      await provider.fetchAllUsers(); // Fetch userId-name map
      await provider.fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, userProvider, child) {
        final transactions = userProvider.transactions;
        final isLoading = userProvider.isrecenttranscationloading;
        final currentWalletId = userProvider.walletuserid;
        final userIdNameMap = userProvider.userIdNameMap;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (transactions.isEmpty) {
          return const Center(child: Text("No transactions found."));
        }

        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];

            final senderId = transaction.sender;
            final receiverId = transaction.receiver;

            bool isSender = senderId == currentWalletId;
            bool isReceiver = receiverId == currentWalletId;

            if (!isSender && !isReceiver) {
              return const SizedBox();
            }

            final isCredit = isReceiver;
            final arrowIcon =
                isCredit ? Icons.arrow_downward : Icons.arrow_upward;
            final arrowColor = isCredit ? Colors.green : Colors.red;

            final otherPartyId = isCredit ? senderId : receiverId;
            final otherPartyName = userIdNameMap[otherPartyId] ?? otherPartyId;

            final title = isCredit
                ? "fund received from $otherPartyName"
                : "fund transferred to $otherPartyName";

            final amountPrefix = isCredit ? "+" : "-";
            final amount = "$amountPrefix Rs ${transaction.amount}";

            return GestureDetector(
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: TransactionDetail(transaction: {
                    'senderId': transaction.sender,
                    'receiverId': transaction.receiver,
                    'senderName':
                        userIdNameMap[transaction.sender] ?? transaction.sender,
                    'receiverName': userIdNameMap[transaction.receiver] ??
                        transaction.receiver,
                    'amount': transaction.amount,
                    'status': transaction.status,
                    'transactionType': transaction.transactionType,
                    'description': transaction.description,
                    'createdAt': transaction.createdAt.toIso8601String(),
                  }),
                  withNavBar: false,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              child: TransactionCard(
                title: title,
                subtitle: transaction.status,
                amount: amount,
                isCredit: isCredit,
                arrowIcon: arrowIcon,
                arrowColor: arrowColor,
              ),
            );
          },
        );
      },
    );
  }
}
