import 'package:api/cubit/product_cubit.dart';
import 'package:api/current_formatter.dart';
import 'package:api/screen/add_product_screen.dart';
import 'package:api/screen/edit_product_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Product')),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProductLoaded) {
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                itemCount: state.products.length,
                itemBuilder: (context, Index) {
                  final product = state.products[Index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('Harga: ${product.price.toRupiah()}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (ctx) => BlocProvider.value(
                                      value: context.read<ProductCubit>(),
                                      child: EditProductScreen(
                                        product: product,
                                      ),
                                    ),
                              ),
                            );
                          },
                          icon: Icon(Icons.edit),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  title: const Text('Konfirmasi Hapus'),
                                  content: Text(
                                    'Yakin ingin menghapus product ${product.name}?',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Batal'),
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Hapus'),
                                      onPressed: () {
                                        print('Hapus product ${product.name}');
                                        context
                                            .read<ProductCubit>()
                                            .deleteProduct(product.id);
                                        Navigator.of(dialogContext).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
          if (state is ProductError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Tekan refresh untuk memuat data'));
        },
      ),

      // Di dalam product_screen.dart
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // Panggil .value langsung dari BlocProvider
              builder:
                  (ctx) => BlocProvider.value(
                    value:
                        context
                            .read<
                              ProductCubit
                            >(), // 'value' adalah parameter di sini
                    child: const AddProductScreen(),
                  ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
