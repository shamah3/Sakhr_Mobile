import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class WhatsAppService {
  // UltraMsg Credentials (Example)
  // In a real app, these should be kept in a secure environment file
  final String _instanceId = "instanceXXXXX"; // Replace with your Instance ID
  final String _token = "yourTokenHere";      // Replace with your Token

  /// Sends a WhatsApp OTP message using UltraMsg API
  Future<bool> sendOTP({required String phone, required String otp}) async {
    // ---- DEBUG MODE DETECTION ----
    // If you haven't put your real credentials, we'll simulate a success
    // so you can continue testing the UI/Flow.
    if (_instanceId.contains("XXXXX") || _token.contains("yourToken")) {
      debugPrint("DEVELOPER NOTICE: Using Mock WhatsApp Service.");
      debugPrint("----------------------------------------------");
      debugPrint("TO: $phone");
      debugPrint("MESSAGE: رمز التحقق الخاص بك هو: $otp");
      debugPrint("----------------------------------------------");
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      return true; // Return true to allow testing the UI flow
    }
    // -------------------------------

    final String url = "https://api.ultramsg.com/$_instanceId/messages/chat";
    
    // Message Body
    final String message = "رمز التحقق الخاص بك لتطبيق صخر هو: $otp\nصالح لمدة 5 دقائق.";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "token": _token,
          "to": phone,
          "body": message,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['sent'] == "true") {
          debugPrint("WhatsApp OTP sent successfully to $phone");
          return true;
        }
      }
      
      debugPrint("Failed to send WhatsApp message: ${response.body}");
      return false;
    } catch (e) {
      debugPrint("Error sending WhatsApp message: $e");
      return false;
    }
  }

  /// Example using Twilio (Commented out for reference)
  /*
  Future<bool> sendViaTwilio({required String phone, required String otp}) async {
    final String accountSid = 'ACXXXXXXXXXXXXXXXXXXXXXXXX';
    final String authToken = 'your_auth_token';
    final String from = 'whatsapp:+14155238886'; // Twilio Sandbox Number

    final response = await http.post(
      Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json'),
      headers: {
        'Authorization': 'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'From': from,
        'To': 'whatsapp:$phone',
        'Body': 'رمز التحقق الخاص بك هو: $otp',
      },
    );
    return response.statusCode == 201;
  }
  */
}
