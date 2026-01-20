import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final ApiService api = ApiService();
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    try {
      final list = await api.getProducts();
      setState(() {
        products = list;
        filteredProducts = list;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _filterProducts(String query) {
    setState(() {
      searchQuery = query;
      filteredProducts = products.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Product Grid
        Expanded(
          flex: 3,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24.0),
                color: Colors.white,
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text("Kasir", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1A237E))),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Cari produk...",
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        ),
                        onChanged: _filterProducts,
                      ),
                   ]
                )
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        padding: const EdgeInsets.all(24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return GestureDetector(
                            onTap: () {
                              Provider.of<CartProvider>(context, listen: false).addItem(product);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      ),
                                      child: Center(
                                        child: Text(product.name[0], style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue.shade200)),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                                        const SizedBox(height: 4),
                                        Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(product.price),
                                            style: GoogleFonts.poppins(color: const Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 14)),
                                        Text("Stok: ${product.stock}", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        // Cart Sidebar
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Pesanan Baru", style: GoogleFonts.poppins(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
                        child: Consumer<CartProvider>(builder: (c, cart, _) => Text("${cart.itemCount} Items", style: GoogleFonts.poppins(color: Colors.blue.shade800, fontWeight: FontWeight.bold))),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer<CartProvider>(
                    builder: (context, cart, child) {
                      if (cart.items.isEmpty) {
                        return Center(
                           child: Column(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade300),
                               const SizedBox(height: 16),
                               Text("Keranjang Kosong", style: GoogleFonts.poppins(color: Colors.grey)),
                             ],
                           )
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cart.items.length,
                        itemBuilder: (context, index) {
                          final item = cart.items.values.toList()[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48, height: 48,
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                  child: Center(child: Text(item.product.name[0], style: const TextStyle(fontWeight: FontWeight.bold))),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.product.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                      Text("@${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(item.product.price)}", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle, color: Colors.grey, size: 20),
                                      onPressed: () => cart.removeSingleItem(item.product.id),
                                    ),
                                    Text("${item.quantity}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle, color: Color(0xFF1A237E), size: 20),
                                      onPressed: () => cart.addItem(item.product),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Text(NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(item.total), style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 20, offset: const Offset(0, -4))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Subtotal", style: GoogleFonts.poppins(color: Colors.grey)),
                              Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(cart.totalAmount), style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                              Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(cart.totalAmount),
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF1A237E))),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A237E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              onPressed: cart.itemCount == 0 ? null : () async {
                                bool success = await api.processTransaction(
                                  cart.totalAmount,
                                  cart.items.values.map((e) => {
                                    "product_id": e.product.id,
                                    "quantity": e.quantity,
                                    "price": e.product.price
                                  }).toList()
                                );

                                if (context.mounted) {
                                  if (success) {
                                    cart.clear();
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Transaksi Berhasil!"), backgroundColor: Colors.green));
                                    _loadProducts(); // Refresh stock
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Transaksi Gagal"), backgroundColor: Colors.red));
                                  }
                                }
                              },
                              child: const Text("Bayar Sekarang", style: TextStyle( fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
