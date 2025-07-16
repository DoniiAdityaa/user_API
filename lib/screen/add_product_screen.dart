import 'package:api/cubit/product_cubit.dart';
import 'package:api/helpper/thousands_helpper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Product Baru')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Product'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: "Harga"),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                ThousandsHelpper(),
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                print('Menambahkan Product ${_nameController.text}');
                final name = _nameController.text;
                final price = _priceController.text;
                if (name.isNotEmpty && price.isNotEmpty) {
                  final priceInt = int.parse(price);
                  context.read<ProductCubit>().addProduct(name, priceInt);
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
