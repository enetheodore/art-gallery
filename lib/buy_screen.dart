import 'package:flutter/material.dart';

class BuyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy Art'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Negotiation Options:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text('Price Negotiation'),
              onTap: () {
                // Handle price negotiation option
              },
            ),
            ListTile(
              title: Text('Terms Negotiation'),
              onTap: () {
                // Handle terms negotiation option
              },
            ),
            Divider(),
            Text(
              'Payment Options:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text('Credit Card'),
              onTap: () {
                // Handle credit card payment option
              },
            ),
            ListTile(
              title: Text('PayPal'),
              onTap: () {
                // Handle PayPal payment option
              },
            ),
            Divider(),
            Text(
              'Contact Us:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text('Email: example@example.com'),
              onTap: () {
                // Handle email contact option
              },
            ),
            ListTile(
              title: Text('Phone: +1234567890'),
              onTap: () {
                // Handle phone contact option
              },
            ),
          ],
        ),
      ),
    );
  }
}
