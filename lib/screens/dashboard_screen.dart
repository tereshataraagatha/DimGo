import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService api = ApiService();
  Map<String, dynamic>? stats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    try {
      final data = await api.getDashboardStats();
      setState(() {
        stats = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      // Handle error cleanly
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (stats == null) return const Center(child: Text("Gagal memuat data"));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Dashboard", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1A237E))),
                  Text(DateFormat("EEEE, d MMMM y", "id_ID").format(DateTime.now()), style: GoogleFonts.poppins(color: Colors.grey.shade600)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text("Hari Ini", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.6,
            children: [
              _buildStatCard("Total Produk", "${stats!['total_products']}", Icons.inventory_2_rounded, const Color(0xFF1A237E)),
              _buildStatCard("Nilai Stok", NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(stats!['total_stock_value']), Icons.monetization_on_rounded, const Color(0xFF43A047)),
            ],
          ),
          
          const SizedBox(height: 32),
          Text("Peringatan Stok Low", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1A237E))),
          const SizedBox(height: 16),
          _buildLowStockList(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(offset: const Offset(0, 4), blurRadius: 20, color: Colors.black.withValues(alpha: 0.05)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text(title, style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockList() {
    List<dynamic> lowStock = stats!['low_stock'] ?? [];
    if (lowStock.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade300, size: 48),
              const SizedBox(height: 8),
              Text("Semua stok aman!", style: GoogleFonts.poppins(color: Colors.grey.shade600)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: lowStock.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(12),
             border: Border(left: BorderSide(color: Colors.orange.shade400, width: 4)),
             boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            title: Text(item['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20)),
              child: Text("Sisa: ${item['stock']}", style: GoogleFonts.poppins(color: Colors.orange.shade800, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          ),
        );
      }).toList(),
    );
  }
}
