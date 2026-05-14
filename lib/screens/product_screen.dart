import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final productService = ProductService();
  List<Product> products = [];
  bool isLoading = true;

  static const backgroundColor = Color(0xFF09090F);
  static const cardColor = Color(0xFF141420);
  static const inputColor = Color(0xFF1B1B2B);
  static const primaryColor = Color(0xFF5B5CFF);
  static const secondaryText = Color(0xFF9CA3AF);

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  String formatRupiah(int price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  Future<void> loadProducts() async {
    setState(() => isLoading = true);
    try {
      final data = await productService.getProducts();
      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> addProduct(String name, String price, String desc) async {
    final success = await productService.addProduct(name, int.parse(price), desc);
    if (success) {
      loadProducts();
      Navigator.pop(context);
    }
  }

  Future<void> deleteProduct(int id, String name) async {
    final success = await productService.deleteProduct(id);
    if (success) {
      setState(() => products.removeWhere((p) => p.id == id));
      showSnackbar('Produk "$name" berhasil dihapus', false);
    } else {
      showSnackbar('Gagal menghapus produk', true);
    }
  }

  Future<void> submitTugas(Product p, String githubUrl) async {
    final success = await productService.submitTugas(p, githubUrl);
    if (success) {
      showSnackbar('Submit berhasil!', false);
    }
  }

  void showSnackbar(String message, bool error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? const Color(0xFFE53935) : const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void showAddDialog() {
    final nameC = TextEditingController();
    final priceC = TextEditingController();
    final descC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text('Tambah Produk', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              buildInput(hint: 'Nama Produk', icon: Icons.inventory_2_outlined, controller: nameC),
              const SizedBox(height: 12),
              buildInput(hint: 'Harga', icon: Icons.payments_outlined, controller: priceC, keyboard: TextInputType.number),
              const SizedBox(height: 12),
              buildInput(hint: 'Deskripsi', icon: Icons.notes_rounded, controller: descC),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => addProduct(nameC.text, priceC.text, descC.text),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('Tambah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void showSubmitDialog(Product p) {
    final githubC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: cardColor, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text('Submit Tugas', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(p.name, style: const TextStyle(color: secondaryText, fontSize: 13)),
              const SizedBox(height: 20),
              buildInput(hint: 'Github URL', icon: Icons.link_rounded, controller: githubC),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () { submitTugas(p, githubC.text); Navigator.pop(ctx); },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void confirmDelete(Product p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus "${p.name}"?', style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text('Data tetap tersimpan di server.', style: TextStyle(color: secondaryText, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal', style: TextStyle(color: secondaryText))),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); deleteProduct(p.id, p.name); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget buildInput({required String hint, required IconData icon, required TextEditingController controller, TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      cursorColor: primaryColor,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        prefixIcon: Icon(icon, color: primaryColor, size: 20),
        filled: true,
        fillColor: inputColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddDialog,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          buildGlow(top: -100, right: -80, color: Colors.blue, size: 250),
          buildGlow(bottom: -100, left: -60, color: Colors.purple, size: 220),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Daftar Produk', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(isLoading ? 'Memuat...' : '${products.length} produk tersedia', style: const TextStyle(fontSize: 13, color: secondaryText)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator(color: primaryColor))
                      : products.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.inventory_2_outlined, size: 48, color: secondaryText.withOpacity(0.4)),
                                  const SizedBox(height: 12),
                                  const Text('Belum ada produk', style: TextStyle(color: secondaryText, fontSize: 15)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                              itemCount: products.length,
                              itemBuilder: (_, i) {
                                final p = products[i];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(child: Text(p.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white))),
                                          Text(formatRupiah(p.price), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: primaryColor)),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(p.description, style: const TextStyle(fontSize: 13, color: secondaryText, height: 1.5)),
                                      const SizedBox(height: 14),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(onPressed: () => confirmDelete(p), style: TextButton.styleFrom(foregroundColor: const Color(0xFFE53935)), child: const Text('Hapus', style: TextStyle(fontSize: 13))),
                                          const SizedBox(width: 4),
                                          ElevatedButton(
                                            onPressed: () => showSubmitDialog(p),
                                            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                            child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGlow({double? top, double? bottom, double? left, double? right, required Color color, required double size}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color.withOpacity(0.35), color.withOpacity(0)])),
      ),
    );
  }
}
