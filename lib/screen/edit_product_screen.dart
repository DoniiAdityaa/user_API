import 'package:api/cubit/product_cubit.dart';
import 'package:api/helpper/thousands_helpper.dart';
import 'package:api/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product; // Menerima data produk yang akan diedit
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    final initialPrice = NumberFormat.decimalPattern(
      'id_ID',
    ).format(widget.product.price);
    _priceController = TextEditingController(text: initialPrice);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Product')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Product'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Harga'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                ThousandsHelpper(),
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              child: const Text('Simpan'),
              onPressed: () {
                final updatedProduct = ProductModel(
                  id: widget.product.id, // Gunakan ID yang sama
                  name: _nameController.text,
                  price: int.parse(_priceController.text),
                );
                context.read<ProductCubit>().updateProduct(updatedProduct);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
