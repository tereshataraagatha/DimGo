import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ApiService api = ApiService();
  List<Product> products = [];
  bool isLoading = true;

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
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showFormDialog({Product? product}) async {
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final priceCtrl = TextEditingController(text: product?.price.toInt().toString() ?? '');
    final stockCtrl = TextEditingController(text: product?.stock.toString() ?? '');
    final categoryCtrl = TextEditingController(text: product?.category ?? 'Umum');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? "Tambah Produk" : "Edit Produk", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        scrollable: true,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(nameCtrl, "Nama Produk"),
            const SizedBox(height: 12),
            _buildTextField(categoryCtrl, "Kategori"),
            const SizedBox(height: 12),
            _buildTextField(priceCtrl, "Harga", isNumber: true),
            const SizedBox(height: 12),
            _buildTextField(stockCtrl, "Stok", isNumber: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white),
            onPressed: () async {
              final data = {
                "name": nameCtrl.text,
                "category": categoryCtrl.text,
                "price": double.tryParse(priceCtrl.text) ?? 0,
                "stock": int.tryParse(stockCtrl.text) ?? 0,
              };

              // Capture context state before async operations
              final contextState = context;
              final mountedState = mounted;

              bool success;
              if (product == null) {
                success = await api.addProduct(data);
              } else {
                data['id'] = product.id;
                success = await api.updateProduct(data);
              }

              if (mountedState) {
                if (mounted) {
                  Navigator.pop(contextState);
                }
                if (success) {
                  if (mounted) {
                    _loadProducts();
                  }
                }
                if (mounted) {
                  ScaffoldMessenger.of(contextState).showSnackBar(SnackBar(content: Text(success ? "Berhasil" : "Gagal")));
                }
              }
            },
            child: Text("Simpan", style: GoogleFonts.poppins()),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        backgroundColor: const Color(0xFF1A237E),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text("Tambah Produk", style: GoogleFonts.poppins(color: Colors.white)),
      ),
      body: Column(
        children: [
           Padding(
            padding: const EdgeInsets.all(24.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Daftar Produk", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1A237E)))
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                product.name.isNotEmpty ? product.name[0] : '?',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue.shade800)
                              ),
                            ),
                          ),
                          title: Text(product.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(product.category, style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 12)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                                child: Text("Stok: ${product.stock}", style: GoogleFonts.poppins(color: Colors.green.shade800, fontSize: 12, fontWeight: FontWeight.w500)),
                              )
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(product.price),
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF1A237E))),
                              const SizedBox(width: 8),
                              IconButton(icon: Icon(Icons.edit, color: Colors.blue.shade700), onPressed: () => _showFormDialog(product: product)),
                              IconButton(icon: Icon(Icons.delete, color: Colors.red.shade400), onPressed: () async {
                                bool confirm = await showDialog(context: context, builder: (_) => AlertDialog(
                                  title: const Text("Hapus?"),
                                  content: Text("Yakin ingin menghapus ${product.name}?"),
                                  actions: [
                                    TextButton(onPressed:()=>Navigator.pop(context, false), child: const Text("Batal")),
                                    TextButton(onPressed:()=>Navigator.pop(context, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
                                  ],
                                )) ?? false;

                                if (confirm) {
                                  await api.deleteProduct(product.id);
                                  if (mounted) {
                                    _loadProducts();
                                  }
                                }
                              }),
                            ],
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
}
