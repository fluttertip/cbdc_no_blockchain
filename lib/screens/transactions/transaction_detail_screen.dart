import 'package:flutter/material.dart';

class TransactionDetail extends StatelessWidget {
  final Map<dynamic, dynamic> transaction;

  const TransactionDetail({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    // Safe access with null-aware operators
    bool isCredit = transaction['isCredit'] ?? false;

    String senderName = transaction['sender']?['details']?['name'] ?? 'Unknown';
    String receiverName =
        transaction['receiver']?['details']?['name'] ?? 'Unknown';

    String status = transaction['status'] ?? 'N/A';
    String description = transaction['description'] ?? 'N/A';
    String transactionType = transaction['transactionType'] ?? 'N/A';
    String createdAt = transaction['createdAt'] ?? 'N/A';
    String updatedAt = transaction['updatedAt'] ?? 'N/A';
    int amount = transaction['amount'] ?? 0;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Transaction Details"),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.black : Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black45 : Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      isCredit ? "+ Rs $amount" : "- Rs $amount",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isCredit ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  const Divider(height: 24, thickness: 1),
                  _detailRow("Sender", senderName),
                  _detailRow("Receiver", receiverName),
                  _detailRow("Amount", amount.toString()),
                  _detailRow("Status", status.toUpperCase()),
                  _detailRow("Type", transactionType),
                  _detailRow("Description", description),
                  _detailRow("Created At", createdAt),
                  _detailRow("Updated At", updatedAt),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back"),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDarkMode ? Colors.black : Colors.deepPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            width: 150,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
