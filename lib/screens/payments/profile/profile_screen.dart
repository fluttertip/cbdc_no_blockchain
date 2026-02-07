import 'package:cbdcprovider/provider/app_provider.dart';
import 'package:cbdcprovider/screens/payments/kyc/kyc_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Consumer<AppProvider>(
          builder: (context, user, child) {
            final kyc = user.kycStatus.trim().toLowerCase();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (kyc != "not_submitted") _buildProfileHeader(user),
                const SizedBox(height: 20),
                _buildKYCStatus(context, kyc),
                const SizedBox(height: 20),
                _buildProfileInfo(user, kyc),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AppProvider user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey.shade300,
          child: const Icon(Icons.person, size: 60, color: Colors.grey),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildKYCStatus(BuildContext context, String kycStatus) {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    VoidCallback? action;

    switch (kycStatus) {
      case "approved":
        statusColor = Colors.green;
        statusIcon = Icons.verified;
        statusText = "KYC Verified";
        break;

      case "pending":
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        statusText = "KYC Pending";
        break;

      case "rejected":
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = "KYC Rejected - Tap to Re-Submit";
        action = () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: KycVerificationScreen(),
            withNavBar: false,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        };
        break;

      default: // "not_submitted" or unknown
        statusColor = Colors.redAccent;
        statusIcon = Icons.warning;
        statusText = "Submit Your KYC";
        action = () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: KycVerificationScreen(),
            withNavBar: false,
            pageTransitionAnimation: PageTransitionAnimation.cupertino,
          );
        };
    }

    return GestureDetector(
      onTap: action,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: statusColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(statusIcon, color: statusColor, size: 26),
            const SizedBox(width: 10),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(AppProvider user, String kycStatus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _profileField("Full Name", user.fullName),
        const SizedBox(height: 20),
        _profileField("Email", user.email),
        const SizedBox(height: 20),
        if (kycStatus == "approved")
          Column(
            children: [
              _profileField("Date of Birth", user.dob),
              const SizedBox(height: 20),
              _profileField("Citizenship No", user.citizenidno),
              const SizedBox(height: 20),
              _buildGovtIDImage(user),
            ],
          ),
      ],
    );
  }

  Widget _profileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.isNotEmpty ? value : "Not Provided",
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildGovtIDImage(AppProvider user) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
        color: Colors.grey.shade200,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 50, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              'Government ID (Coming Soon)',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
