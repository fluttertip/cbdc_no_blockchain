import 'package:cbdcprovider/provider/app_provider.dart';
import 'package:cbdcprovider/screens/transactions/transaction_detail_screen.dart';
import 'package:cbdcprovider/shared/components/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

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
      // fetchAllUsers removed from provider; only fetch transactions
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

            // Support both Map and model shapes:
            final senderId = (transaction is Map)
                ? (transaction['senderId'] ??
                      (transaction['sender'] is Map
                          ? transaction['sender']['_id']
                          : transaction['sender']))
                : (transaction.sender ?? '');
            final receiverId = (transaction is Map)
                ? (transaction['receiverId'] ??
                      (transaction['receiver'] is Map
                          ? transaction['receiver']['_id']
                          : transaction['receiver']))
                : (transaction.receiver ?? '');

            bool isSender = senderId == currentWalletId;
            bool isReceiver = receiverId == currentWalletId;

            if (!isSender && !isReceiver) {
              return const SizedBox();
            }

            final isCredit = isReceiver;
            final arrowIcon = isCredit
                ? Icons.arrow_downward
                : Icons.arrow_upward;
            final arrowColor = isCredit ? Colors.green : Colors.red;

            final otherPartyId = isCredit ? senderId : receiverId;
            final otherPartyName = (transaction is Map)
                ? (isCredit
                      ? (transaction['senderName'] ?? otherPartyId)
                      : (transaction['receiverName'] ?? otherPartyId))
                : (isCredit
                      ? (transaction.senderName ?? otherPartyId)
                      : (transaction.receiverName ?? otherPartyId));

            final title = isCredit
                ? "fund received from $otherPartyName"
                : "fund transferred to $otherPartyName";

            final amountValue = (transaction is Map)
                ? (transaction['amount'] ?? 0)
                : (transaction.amount ?? 0);
            final amountPrefix = isCredit ? "+" : "-";
            final amount = "$amountPrefix Rs $amountValue";

            return GestureDetector(
              onTap: () {
                final txMap = (transaction is Map)
                    ? {
                        'senderId': senderId,
                        'receiverId': receiverId,
                        'senderName': (transaction['senderName'] ?? senderId),
                        'receiverName':
                            (transaction['receiverName'] ?? receiverId),
                        'amount': amountValue,
                        'status':
                            transaction['status'] ??
                            transaction['transactionStatus'],
                        'transactionType':
                            transaction['transactionType'] ??
                            transaction['type'],
                        'description': transaction['description'] ?? '',
                        'createdAt':
                            (transaction['createdAt'] ??
                            DateTime.now().toIso8601String()),
                      }
                    : {
                        'senderId': senderId,
                        'receiverId': receiverId,
                        'senderName': transaction.senderName ?? senderId,
                        'receiverName': transaction.receiverName ?? receiverId,
                        'amount': amountValue,
                        'status': transaction.status,
                        'transactionType': transaction.transactionType,
                        'description': transaction.description,
                        'createdAt': transaction.createdAt.toIso8601String(),
                      };

                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: TransactionDetail(transaction: txMap),
                  withNavBar: false,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              child: TransactionCard(
                title: title,
                subtitle: (transaction is Map)
                    ? (transaction['status'] ?? '')
                    : (transaction.status ?? ''),
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