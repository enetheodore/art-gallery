import 'package:flutter/material.dart';

class BuyScreen extends StatefulWidget {
  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy Art'),
        backgroundColor: Colors.blueGrey, // Custom app bar color
        elevation: 0, // No shadow
      ),
      backgroundColor: Colors.grey[200], // Background color for the screen
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('Negotiation Options'),
            _buildOptionItem('Price Negotiation', Icons.attach_money, () {
              // Handle price negotiation option
            }),
            _buildOptionItem('Terms Negotiation', Icons.description, () {
              // Handle terms negotiation option
            }),
            Divider(color: Colors.blueGrey), // Custom divider color

            _buildSectionTitle('Payment Options'),
            _buildOptionItem('Credit Card', Icons.credit_card, () {
              // Handle credit card payment option
            }),
            _buildOptionItem('PayPal', Icons.payment, () {
              // Handle PayPal payment option
            }),
            Divider(color: Colors.blueGrey),

            _buildSectionTitle('Contact Us'),
            _buildContactItem('Email: example@example.com', Icons.email, () {
              // Handle email contact option
            }),
            _buildContactItem('Phone: +1234567890', Icons.phone, () {
              // Handle phone contact option
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
      ),
    );
  }

  Widget _buildOptionItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey), // Custom leading icon color
      title: Text(title, style: TextStyle(color: Colors.blueGrey)),
      onTap: onTap,
    );
  }

  Widget _buildContactItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title, style: TextStyle(color: Colors.blueGrey)),
      onTap: onTap,
    );
  }
}
