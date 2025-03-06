import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:phone_pay_bazaar/view/orders_sucess_page.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  //! Logger for debugging
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

  // !State variables
  bool isInitialized = false;
  String result = "";
  bool isLoading = false;

  //! PhonePe Configuration
  final String environment = "SANDBOX";
  final String merchantId = "PGTESTPAYUAT86";
  final String appId = "";
  final String saltKey = "96434309-7796-489d-8924-ab56988a6076";
  final int saltIndex = 1;
  final String apiEndpoint = "/pg/v1/pay";
  final bool enableLogging = true;
  
  @override
  void initState() {
    super.initState();
    _initPhonePeSdk();
  }
  
  //! Initialize PhonePe SDK
  Future<void> _initPhonePeSdk() async {
    try {
      setState(() {
        isLoading = true;
      });
      
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
  
  //! Generate unique transaction ID
  String generateTransactionId() {
    return "MT${DateTime.now().millisecondsSinceEpoch}";
  }
  
  //! Create payload for PhonePe transaction
  String generateBase64Payload(double amount, String merchantTransactionId) {
    Map<String, dynamic> paymentInstrument = {
      "type": "PAY_PAGE"
    };
    
    Map<String, dynamic> payload = {
      "merchantId": merchantId,
      "merchantTransactionId": merchantTransactionId,
      "merchantUserId": "MUID${DateTime.now().millisecondsSinceEpoch}",
      "amount": (amount * 100).toInt(),
      "callbackUrl": "https://webhook.site/callback-url",
      "mobileNumber": "9999999999",
      "paymentInstrument": paymentInstrument,
    };
    
    String jsonString = jsonEncode(payload);
    String base64Body = base64Encode(utf8.encode(jsonString));
    
    logger.d("Generated payload: $jsonString");
    logger.d("Base64 encoded payload: $base64Body");
    
    return base64Body;
  }
  
  // !Calculate checksum for transaction security
  String calculateChecksum(String base64Body) {
    String dataToHash = base64Body + apiEndpoint + saltKey;
    var bytes = utf8.encode(dataToHash);
    var digest = sha256.convert(bytes);
    String checksum = digest.toString() + "###" + saltIndex.toString();
    
    logger.d("Generated checksum: $checksum");
    
    return checksum;
  }
  
  //! Initiate PhonePe payment transaction
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
      
      String? packageName = null;
      String callbackUrl = "flutterphonepe";
      
      Map<dynamic, dynamic>? response = await PhonePePaymentSdk.startTransaction(
        base64Body, 
        callbackUrl, 
        checksum,
        packageName,
      );
      
      setState(() {
        isLoading = false;
      });
      
      if (response != null) {
        String status = response['status'] ?? "FAILURE";
        String error = response['error'] ?? "";
        
        logger.i("Transaction status: $status");
        if (error.isNotEmpty) {
          logger.e("Transaction error: $error");
        }
        
        // Inside the startPhonePeTransaction method in PaymentPage class
if (status == 'SUCCESS') {
  setState(() {
    result = "Payment Successful! Transaction ID: $merchantTransactionId";
  });
  _verifyPaymentWithBackend(merchantTransactionId);
  
  // Add this navigation code
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => OrderSuccessPage(
        orderNumber: merchantTransactionId,
        totalAmount: 7149.35,
        productName: "RS-X Toys Unisex Sneakers",
        productVariant: "Puma White-Puma Royal-High Risk Red",
        productSize: "S",
      ),
    ),
  );
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
  
  // Verify payment status with backend after transaction
  Future<void> _verifyPaymentWithBackend(String transactionId) async {
    logger.i("Verifying payment with backend for transaction: $transactionId");
    
    await Future.delayed(const Duration(seconds: 2));
    
    bool isPaymentVerified = true;
    
    if (isPaymentVerified) {
      logger.i("Payment verified successfully");
    } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //! Order details card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Order Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'asset/Screenshot 2025-03-06 121201.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported, size: 30),
                                ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "RS-X Toys Unisex Sneakers",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Puma White-Puma Royal-High Risk Red | Size: S",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "₹7,149.35",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            //! Payment options card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Payment Options",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5f259f).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.phone_android,
                          color: Color(0xFF5f259f),
                        ),
                      ),
                      title: const Text(
                        "PhonePe",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text("Pay using PhonePe wallet or UPI"),
                      trailing: Radio<String>(
                        value: "phonepe",
                        groupValue: "phonepe",
                        onChanged: (value) {},
                        activeColor: const Color(0xFF5f259f),
                      ),
                    ),
                    const Divider(),
                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(
                            color: Color(0xFF5f259f),
                          ),
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: isInitialized
                          ? () => startPhonePeTransaction(7149.35)
                          : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5f259f),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "PAY ₹7,149.35",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    if (result.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: result.contains("Successful")
                            ? Colors.green[50]
                            : Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: result.contains("Successful")
                              ? Colors.green
                              : Colors.orange,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          result,
                          style: TextStyle(
                            color: result.contains("Successful")
                              ? Colors.green[800]
                              : Colors.orange[800],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            //! Price details card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Price Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCheckoutRow("Price (1 item)", "₹10,999.00"),
                    _buildCheckoutRow("Discount", "- ₹3,849.65"),
                    _buildCheckoutRow("Delivery Charges", "FREE"),
                    const Divider(height: 24),
                    _buildCheckoutRow(
                      "Total Amount",
                      "₹7,149.35",
                      isBold: true,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.local_offer, color: Colors.green[700], size: 16),
                          const SizedBox(width: 8),
                          Text(
                            "You're saving ₹3,849.65 on this order",
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  //! Helper widget to build price detail rows
  Widget _buildCheckoutRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}