import 'package:flutter/material.dart';

class LoginPhoneScreen extends StatelessWidget {
  const LoginPhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 24),
            Text(
              'Enter your phone number',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '+66...',
                labelText: 'Phone',
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null,
                child: Text('Request OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
