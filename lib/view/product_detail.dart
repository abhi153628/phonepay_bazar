import 'package:flutter/material.dart';
import 'package:phone_pay_bazaar/view/payment_page.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({Key? key}) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  //! Product information constants
  final String productId = "369449_02";
  final String productName = "RS-X Toys Unisex Sneakers";
  final double productPrice = 10999.00;
  final double discount = 3849.65;
  final int quantity = 1;

  //! UI state variables
  int selectedImageIndex = 0;
  String selectedSize = "S";
  int selectedVariant = 0;

  //! Available sizes
  final List<String> sizes = ["XS", "S", "M", "L", "XL", "XXL"];

  //! Color variants with associated images
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //! Product image carousel
            _buildProductImages(),

            //! Small divider for visual separation
            Divider(height: 1, thickness: 1, color: Colors.grey[200]),

            //! Color variants selection
            _buildColorVariants(),

            //! Size selector with reduced spacing
            _buildSizeSelector(),

            //! Action buttons (Add to cart, Buy now)
            _buildAddToCartSection(),
          ],
        ),
      ),
    );
  }

  //! Product image carousel with pagination indicators
  Widget _buildProductImages() {
    return Stack(
      children: [
        //! Main image carousel
        Container(
          height: 380,
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
                    child: Icon(Icons.image_not_supported,
                        size: 50, color: Colors.grey[400]),
                  ),
                ),
              );
            },
          ),
        ),

        //! Pagination indicators
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
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color:
                      index == selectedImageIndex ? Colors.black : Colors.grey,
                ),
              ),
            ),
          ),
        ),

        //! Back button with improved styling
        Positioned(
          top: 32,
          left: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.arrow_back_ios, size: 20),
            ),
          ),
        ),
        Positioned(
          top: 32,
          left: 330,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.favorite,
                size: 25,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // !Color variants selection with horizontal scrollable list
  Widget _buildColorVariants() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
                        color: selectedVariant == index
                            ? Colors.black
                            : Colors.grey[300]!,
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
                            child: Icon(Icons.image_not_supported,
                                size: 24, color: Colors.grey[400]),
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

  //! Size selection grid with reduced spacing
  Widget _buildSizeSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
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

  //! Action buttons section (Add to cart and Buy now)
  Widget _buildAddToCartSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
