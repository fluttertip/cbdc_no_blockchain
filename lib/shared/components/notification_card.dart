import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isTransaction;

  NotificationCard({
    required this.title,
    required this.subtitle,
    required this.isTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isTransaction
              ? Colors.green.withOpacity(0.1)
              : Colors.blue.withOpacity(0.1),
          child: Icon(
            isTransaction ? Icons.check_circle : Icons.info,
            color: isTransaction ? Colors.green : Colors.blue,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}
