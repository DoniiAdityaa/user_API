import 'package:api/cubit/user_cubit.dart';
import 'package:api/service/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  final _addressController = TextEditingController();

  // 3. Tambahkan dispose untuk membersihkan controller setelah tidak digunakan
  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. HAPUS BlocProvider dari sini. Widget ini akan otomatis
    //    menggunakan UserCubit yang sudah disediakan di main.dart
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pengguna Baru')),
      body: BlocListener<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserCreateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Pengguna ${state.user.name} Berhasil Ditambahkan',
                ),
              ),
            );
            NotificationService().showNotification(
              id: Random().nextInt(100000),
              title: 'Pengguna Baru Ditambahkan',
              body: 'Pengguna ${state.user.name} berhasil ditambahkan.',
            );
            Navigator.of(context).pop(true);
          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gagal Menambahkan Pengguna: ${state.message}'),
              ),
            );
          }
        },
        child: Form(
          // 2. Gunakan nama variabel yang sudah benar
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  // 2. Gunakan nama variabel yang sudah benar
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Alamat',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alamat tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                BlocBuilder<UserCubit, UserState>(
                  builder: (context, state) {
                    if (state is UserLoading) {
                      return const ElevatedButton(
                        onPressed: null,
                        style: ButtonStyle(
                          padding: MaterialStatePropertyAll(
                            EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        child: CircularProgressIndicator.adaptive(
                          backgroundColor: Colors.white,
                        ),
                      );
                    }
                    return ElevatedButton(
                      onPressed: () {
                        // 2. Gunakan nama variabel yang sudah benar
                        if (_formKey.currentState!.validate()) {
                          context.read<UserCubit>().createUser(
                            name: _nameController.text,
                            // 2. Gunakan nama variabel yang sudah benar
                            address: _addressController.text,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Tambah Pengguna'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
