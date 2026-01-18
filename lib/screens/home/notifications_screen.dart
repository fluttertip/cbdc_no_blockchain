import 'package:flutter/material.dart';
import '../../shared/components/notification_card.dart'; // Import the reusable widget

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Notifications"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        itemCount: 6, // Hardcoded for now
        itemBuilder: (context, index) {
          return NotificationCard(
            title:
                index % 2 == 0 ? "Transaction Successful" : "New System Update",
            subtitle: index % 2 == 0
                ? "You received \$${(index + 1) * 50}"
                : "Check out the new features in your app.",
            isTransaction: index % 2 == 0,
          );
        },
      ),
    );
  }
}
