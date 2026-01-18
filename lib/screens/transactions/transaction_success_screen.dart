import 'package:flutter/material.dart';

class TranscationSucess extends StatefulWidget {
  const TranscationSucess({super.key});

  @override
  State<TranscationSucess> createState() => _TranscationSucessState();
}

class _TranscationSucessState extends State<TranscationSucess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Transcation Success")),
      body: const Center(
        child: Text("Transcation was successful"),
      ),
    );
  }
}
