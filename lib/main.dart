import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhonePe Payment',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const PaymentPage(),
    );
  }
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  bool isInitialized = false;
  String result = "";
  bool isLoading = false;

  // PhonePe Configuration - CORRECT VALUES
  final String environment = "SANDBOX"; // Use "SANDBOX" for testing, "PRODUCTION" for live
  final String merchantId = "PGTESTPAYUAT86"; // Your merchant ID
  final String appId = ""; // Usually empty for standard integration
  final String saltKey = "96434309-7796-489d-8924-ab56988a6076";
  final int saltIndex = 1;
  final String apiEndpoint = "/pg/v1/pay";
  final bool enableLogging = true;
  
  @override
  void initState() {
    super.initState();
    _initPhonePeSdk();
  }
  
  // Initialize PhonePe SDK
  Future<void> _initPhonePeSdk() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      // Make sure parameters match exactly what's expected by the SDK
      final result = await PhonePePaymentSdk.init(
        environment,
        appId,
        merchantId,
        enableLogging,
      );
      
      setState(() {
        isInitialized = result;
        this.result = "PhonePe SDK Initialized: $result";
        isLoading = false;
      });
      
      logger.i("PhonePe SDK Initialized: $result");
    } catch (e) {
      setState(() {
        isLoading = false;
        result = "Error initializing PhonePe SDK: ${e.toString()}";
      });
      logger.e("Error initializing PhonePe SDK", error: e);
    }
  }
  
  // Generate a unique transaction ID
  String generateTransactionId() {
    return "MT${DateTime.now().millisecondsSinceEpoch}";
  }
  
  // Generate base64 encoded payload for PhonePe
  String generateBase64Payload(double amount, String merchantTransactionId) {
    Map<String, dynamic> paymentInstrument = {
      "type": "PAY_PAGE"
    };
    
    Map<String, dynamic> payload = {
      "merchantId": merchantId,
      "merchantTransactionId": merchantTransactionId,
      "merchantUserId": "MUID${DateTime.now().millisecondsSinceEpoch}",
      "amount": (amount * 100).toInt(), // Convert to paisa
      "callbackUrl": "https://webhook.site/callback-url", // Replace with your callback URL
      "mobileNumber": "9999999999", // Optional, but some value is safer
      "paymentInstrument": paymentInstrument,
    };
    
    String jsonString = jsonEncode(payload);
    String base64Body = base64Encode(utf8.encode(jsonString));
    
    logger.d("Generated payload: $jsonString");
    logger.d("Base64 encoded payload: $base64Body");
    
    return base64Body;
  }
  
  // Calculate checksum for PhonePe transaction
  String calculateChecksum(String base64Body) {
    String dataToHash = base64Body + apiEndpoint + saltKey;
    var bytes = utf8.encode(dataToHash);
    var digest = sha256.convert(bytes);
    String checksum = digest.toString() + "###" + saltIndex.toString();
    
    logger.d("Generated checksum: $checksum");
    
    return checksum;
  }
  
  // Start PhonePe transaction - FIXED PARAMETER ISSUE
  Future<void> startPhonePeTransaction(double amount) async {
    if (!isInitialized) {
      setState(() {
        result = "PhonePe SDK not initialized. Please try again.";
      });
      logger.e("Attempted to start transaction before SDK initialization");
      return;
    }
    
    try {
      setState(() {
        isLoading = true;
        result = "Initiating transaction...";
      });
      
      String merchantTransactionId = generateTransactionId();
      String base64Body = generateBase64Payload(amount, merchantTransactionId);
      String checksum = calculateChecksum(base64Body);
      
      // Use null for packageName if not needed, or your app's package for production
      String? packageName = null;
      
      // Callback URL scheme for returning to the app after payment
      String callbackUrl = "flutterphonepe"; // Your app's URL scheme
      
      // Fixed parameters according to the SDK method signature
      Map<dynamic, dynamic>? response = await PhonePePaymentSdk.startTransaction(
        base64Body, 
        callbackUrl, 
        checksum,
        packageName,
      );
      
      setState(() {
        isLoading = false;
      });
      
      // Handle the response
      if (response != null) {
        String status = response['status'] ?? "FAILURE";
        String error = response['error'] ?? "";
        
        logger.i("Transaction status: $status");
        if (error.isNotEmpty) {
          logger.e("Transaction error: $error");
        }
        
        if (status == 'SUCCESS') {
          setState(() {
            result = "Payment Successful! Transaction ID: $merchantTransactionId";
          });
          // You may want to verify this with your backend using the Check Status API
          _verifyPaymentWithBackend(merchantTransactionId);
        } else {
          setState(() {
            result = "Payment ${status.toLowerCase()}. Error: $error";
          });
        }
      } else {
        setState(() {
          result = "Transaction interrupted or cancelled by user";
        });
        logger.w("Transaction flow incomplete");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        result = "Error during transaction: ${e.toString()}";
      });
      logger.e("Error during transaction", error: e);
    }
  }
  
  // This method would call your backend to verify payment status
  Future<void> _verifyPaymentWithBackend(String transactionId) async {
    // In a real implementation, you would make an API call to your backend
    // Your backend should call PhonePe's check status API to verify the payment
    
    logger.i("Verifying payment with backend for transaction: $transactionId");
    
    // Simulate backend verification
    await Future.delayed(const Duration(seconds: 2));
    
    // Example response handling
    bool isPaymentVerified = true; // This should come from your backend
    
    if (isPaymentVerified) {
      logger.i("Payment verified successfully");
      // Proceed with order fulfillment
    } else {
      logger.w("Payment verification failed");
      setState(() {
        result = "Payment verification failed. Please contact support.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PhonePe Payment Gateway'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // PhonePe logo
              Icon(
                Icons.payment,
                size: 80,
                color: const Color(0xFF5f259f), // PhonePe purple color
              ),
              const SizedBox(height: 30),
              
              Text(
                isInitialized ? "PhonePe SDK Ready" : "Initializing PhonePe SDK...",
                style: TextStyle(
                  color: isInitialized ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                "Amount: ₹100.00",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 30),
              
              if (isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: isInitialized
                    ? () => startPhonePeTransaction(100.0) // ₹100
                    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5f259f),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    "Pay Now",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              
              const SizedBox(height: 30),
              
              Text(
                result,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: result.contains("Successful") ? Colors.green : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}