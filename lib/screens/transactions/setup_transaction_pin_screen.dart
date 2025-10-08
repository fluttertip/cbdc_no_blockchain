
import 'package:cbdcprovider/provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetupTransactionPin extends StatefulWidget {
  const SetupTransactionPin({super.key});

  @override
  State<SetupTransactionPin> createState() => _SetupTransactionPinState();
}

class _SetupTransactionPinState extends State<SetupTransactionPin> {
  final TextEditingController _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submitPin() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = Provider.of<AppProvider>(context, listen: false);
    await userProvider.setupTransactionPin(_pinController.text);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Transaction PIN saved")));

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Set Transaction PIN"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Enter 4-digit PIN",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "PIN cannot be empty";
                  }
                  if (value.length != 4) {
                    return "PIN must be 4 digits";
                  }
                  if (!RegExp(r'^\d{4}$').hasMatch(value)) {
                    return "PIN must be numeric";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitPin,
                child: const Text("Set PIN"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
