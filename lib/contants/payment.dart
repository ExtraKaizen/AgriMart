
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// Dummy payment intent creation
Future<Map<String, dynamic>> createDummyPaymentIntent({
  required String name,
  required String address,
  required String amount,
}) async {
  print("Using dummy payment intent.");
  // Simulate a successful payment response
  await Future.delayed(Duration(seconds: 2)); // Simulate network delay
  return {
    'id': 'dummy_pi_1234567890',
    'client_secret': 'dummy_client_secret_12345',
    'amount': int.parse(amount),
    'currency': 'inr',
    'status': 'succeeded', // Or 'requires_action' if you want to simulate a step
    'description': 'Dummy Shop Payment',
    'shipping': {
      'name': name,
      'address': {
        'line1': address,
        'country': 'IN',
      },
    },
  };
}

Future createPaymentIntent({
  required String name,
  required String address,
  required String amount,
}) async {
  final bool useDummyPayment = dotenv.env["USE_DUMMY_PAYMENT"] == "true";

  if (useDummyPayment) {
    return await createDummyPaymentIntent(name: name, address: address, amount: amount);
  }

  print("Using real Stripe payment intent.");
  final url = Uri.parse('https://api.stripe.com/v1/payment_intents');
  final secretKey = dotenv.env["STRIPE_SECRET_KEY"]!;
  final body = {
    'amount': amount,
    'currency': "inr",
    'automatic_payment_methods[enabled]': 'true',
    'description': "Shop Payment",
    'shipping[name]': name,
    'shipping[address][line1]': address,
    'shipping[address][country]': "IN"
  };

  final response = await http.post(url,
      headers: {
        "Authorization": "Bearer $secretKey",
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: body);

  print(body);

  if (response.statusCode == 200) {
    var json = jsonDecode(response.body);
    print(json);
    return json;
  } else {
    print("error in calling payment intent");
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
    return null; // Return null on error to be handled by the caller
}
}
