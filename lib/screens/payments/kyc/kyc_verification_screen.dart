import 'dart:io';
import 'package:cbdcprovider/provider/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class KycVerificationScreen extends StatefulWidget {
  const KycVerificationScreen({super.key});

  @override
  State<KycVerificationScreen> createState() => _KycVerificationScreenState();
}

class _KycVerificationScreenState extends State<KycVerificationScreen> {
  XFile? _profileImage;
  XFile? _idCardImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();

  Future<void> _pickImage(bool isProfile) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isProfile) {
          _profileImage = image;
        } else {
          _idCardImage = image;
        }
      });
    }
  }

  void _submitKyc() async {
    final userprovider = Provider.of<AppProvider>(context, listen: false);
    await userprovider.submitKYC(
      context,
      _dobController.text,
      _idNumberController.text,
      _profileImage as XFile,
      _idCardImage as XFile,
    );

    // TODO: Implement backend submission logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("KYC Submitted Successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("KYC Verification"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Upload
              const Text("Upload Profile Picture",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _pickImage(true),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _profileImage != null
                      ? FileImage(File(_profileImage!.path))
                      : null,
                  child: _profileImage == null
                      ? const Icon(Icons.camera_alt, size: 30)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Full Name Input

              // Date of Birth Input
              _buildTextField(
                  _dobController, "Date of Birth", Icons.calendar_today),
              const SizedBox(height: 15),

              // ID Number Input
              _buildTextField(_idNumberController, "ID Number", Icons.badge),
              const SizedBox(height: 20),

              // ID Card Upload
              const Text("Upload Government ID",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _pickImage(false),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                    image: _idCardImage != null
                        ? DecorationImage(
                            image: FileImage(File(_idCardImage!.path)),
                            fit: BoxFit.cover)
                        : null,
                  ),
                  child: _idCardImage == null
                      ? const Center(child: Icon(Icons.upload_file, size: 40))
                      : null,
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitKyc,
                  child: const Text("Submit KYC"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
