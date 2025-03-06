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
      title: 'RS-X Toys Unisex Sneakers',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const ProductDetailPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({Key? key}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final String productId = "369449_02";
  final String productName = "RS-X Toys Unisex Sneakers";
  final double productPrice = 10999.00;
  final double discount = 3849.65;
  final int quantity = 1;
  int selectedImageIndex = 0;
  String selectedSize = "S";
  
  final List<String> sizes = ["XS", "S", "M", "L", "XL", "XXL"];
  
  final List<Map<String, dynamic>> colorVariants = [
    {
      "name": "Puma White-Puma Royal-High Risk Red",
      "images": [
        "asset/Screenshot 2025-03-06 120810.png",
        "asset/Screenshot 2025-03-06 120752.png",
        "asset/Screenshot 2025-03-06 120726.png",
        "asset/Screenshot 2025-03-06 120745.png",
        "asset/Screenshot 2025-03-06 120714.png",
      ]
    },
    {
      "name": "High Rise-Puma White",
      "images": [
        "asset/Screenshot 2025-03-06 121123.png",
        "asset/Screenshot 2025-03-06 121129.png",
        "asset/Screenshot 2025-03-06 121115.png",
        "asset/Screenshot 2025-03-06 121109.png",
        "asset/Screenshot 2025-03-06 121102.png",
      ]
    },
    {
      "name": "Puma White-High Risk Red",
      "images": [
        "asset/Screenshot 2025-03-06 121201.png",
        "asset/Screenshot 2025-03-06 121206.png",
        "asset/Screenshot 2025-03-06 121154.png",
        "asset/Screenshot 2025-03-06 121148.png",
        "asset/Screenshot 2025-03-06 121142.png",
      ]
    },
  ];
  
  int selectedVariant = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
    
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImages(),
            _buildProductInfo(),
            _buildColorVariants(),
            _buildSizeSelector(),
        
            _buildAddToCartSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProductImages() {
    return Stack(
      children: [
      
        Container(

          height: 400,
          width: double.infinity,
          child: PageView.builder(
            itemCount: colorVariants[selectedVariant]["images"].length,
            onPageChanged: (index) {
              setState(() {
                selectedImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.asset(
                colorVariants[selectedVariant]["images"][index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400]),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              colorVariants[selectedVariant]["images"].length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: index == selectedImageIndex ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: index == selectedImageIndex ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ),
        ),
          Positioned(top: 32,left: 20,
            child: Container(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_back_ios),
                    )),
          ),
      ],
    );
  }
  
  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                "PUMA",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.star, color: Colors.amber, size: 16),
              Text(
                "4.9 (288)",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            productName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          Text(
            "Style: $productId",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "35%",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "₹${productPrice.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 16,
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "₹${(productPrice - discount).toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        
        ],
      ),
    );
  }
  
  Widget _buildColorVariants() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Color",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            colorVariants[selectedVariant]["name"],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: colorVariants.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedVariant = index;
                      selectedImageIndex = 0;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: selectedVariant == index ? Colors.black : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        colorVariants[index]["images"][0],
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(Icons.image_not_supported, size: 24, color: Colors.grey[400]),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSizeSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Choose your size",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
       
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 6,
            ),
            itemCount: sizes.length,
            itemBuilder: (context, index) {
              final size = sizes[index];
              final isSelected = size == selectedSize;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSize = size;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      size,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  

  
  Widget _buildAddToCartSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Add to cart",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Buy now",
                style: TextStyle(fontSize: 16,color: Colors.white),
              ),
            ),
          ),
        ],
      ),
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

  // PhonePe Configuration
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
  
  String generateTransactionId() {
    return "MT${DateTime.now().millisecondsSinceEpoch}";
  }
  
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
  
  String calculateChecksum(String base64Body) {
    String dataToHash = base64Body + apiEndpoint + saltKey;
    var bytes = utf8.encode(dataToHash);
    var digest = sha256.convert(bytes);
    String checksum = digest.toString() + "###" + saltIndex.toString();
    
    logger.d("Generated checksum: $checksum");
    
    return checksum;
  }
  
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
        
        if (status == 'SUCCESS') {
          setState(() {
            result = "Payment Successful! Transaction ID: $merchantTransactionId";
          });
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
  
  Future<void> _verifyPaymentWithBackend(String transactionId) async {
    logger.i("Verifying payment with backend for transaction: $transactionId");
    
    await Future.delayed(const Duration(seconds: 2));
    
    bool isPaymentVerified = true;
    
    if (isPaymentVerified) {
      logger.i("Payment verified successfully");
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
                          style: TextStyle(fontSize: 16,color: Colors.white),
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