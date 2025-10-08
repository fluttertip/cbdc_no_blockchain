
import 'package:cbdcprovider/provider/app_provider.dart';
import 'package:cbdcprovider/screens/transactions/transaction_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  Future<void> _refreshTransactions() async {
    try {
      final userproviders = Provider.of<AppProvider>(context, listen: false);
      await userproviders.fetchTransactions();
      setState(() {}); // Rebuild UI after fetching
    } catch (e) {
      debugPrint("Refresh error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to refresh transactions.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Transaction History"),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTransactions,
        edgeOffset: 20,
        displacement: 40,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                MediaQuery.of(context).padding.top,
            child: RecentTranscation(),
          ),
        ),
      ),
    );
  }
}
