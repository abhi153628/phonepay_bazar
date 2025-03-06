Phone Pay Bazaar 🚀
A Flutter app with PhonePe Payment Integration.

Features
✅ Product Listings 🛒
✅ Secure Payments with PhonePe 🔒
✅ Smooth Checkout Experience 🏦

Installation
1️⃣ Clone the repository




git clone https://github.com/yourusername/phone_pay_bazaar.git
cd phone_pay_bazaar
2️⃣ Install dependencies




flutter pub get
3️⃣ Run the app




flutter run
PhonePe Payment Integration
1. Add Dependency
Add this to pubspec.yaml:

yaml


dependencies:
  phonepe_payment_sdk: ^latest_version




flutter pub get
2. Initialize PhonePe SDK
In main.dart:

dart


import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

void initializePhonePe() {
  PhonePePaymentSdk.init(
    environment: Environment.SANDBOX, // Change to PRODUCTION for live
    merchantId: "YOUR_MERCHANT_ID",
    appId: "YOUR_APP_ID",
    enableLogging: true,
  );
}
3. Set Up Server (Required!)
✅ Why? PhonePe requires a server to:

Generate a secure transaction token
Validate payments
Handle callbacks
Your server should:

Accept order details from the app
Call PhonePe API to create a payment request
Return the transaction token
4. Start a Payment
In your app, when the user clicks "Pay with PhonePe":

dart


Future<void> startPhonePePayment() async {
  String merchantTransactionId = "MT${DateTime.now().millisecondsSinceEpoch}";
  double amount = productPrice * 100; // Convert to paise

  // Get token from your server
  final transactionToken = await getTransactionTokenFromServer(
    merchantTransactionId: merchantTransactionId,
    amount: amount,
  );

  final request = {
    "merchantId": "YOUR_MERCHANT_ID",
    "merchantTransactionId": merchantTransactionId,
    "amount": amount,
    "callbackUrl": "https://your-server.com/callback",
    "paymentInstrument": { "type": "PAY_PAGE" },
  };

  try {
    final response = await PhonePePaymentSdk.startTransaction(
      body: request,
      checksum: transactionToken,
      packageName: "your.app.package.name",
    );

    if (response["status"] == "SUCCESS") {
      // Payment successful
    } else {
      // Payment failed
    }
  } catch (e) {
    // Handle errors
  }
}
5. Handle Payment Response
dart


void handlePhonePeResponse(Map<String, dynamic> response) {
  if (response["status"] == "SUCCESS") {
    // Navigate to success screen
    Navigator.push(context, MaterialPageRoute(builder: (context) => SuccessPage()));
  } else {
    // Show error message
  }
}
Testing & Debugging
✅ Use SANDBOX mode for testing.
✅ Generate transaction tokens securely on the server.
✅ Handle user cancellations & network errors properly.

Contribution

Feel free to submit pull requests and improve the app! 🚀