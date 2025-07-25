import 'package:api/cubit/user_detail_cubit.dart';
import 'package:api/models/user_model.dart';
import 'package:api/screen/edit_user_screen.dart';
import 'package:api/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailScreen extends StatelessWidget {
  final String userId;
  const DetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserDetailCubit(UserRepository())..getUserById(userId),
      child: DetailScreenContent(userId: userId),
    );
  }
}

class DetailScreenContent extends StatelessWidget {
  final String userId;
  const DetailScreenContent({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail User"),
        actions: [
          BlocBuilder<UserDetailCubit, UserDetailState>(
            builder: (context, state) {
              if (state is UserDetailSukses) {
                return IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, state.user.id);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          BlocBuilder<UserDetailCubit, UserDetailState>(
            builder: (context, state) {
              if (state is UserDetailSukses) {
                return IconButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditUserScreen(user: state.user),
                      ),
                    );
                    if (result is UserModel && context.mounted) {
                      context.read<UserDetailCubit>().getUserById(result.id);
                    }
                  },
                  icon: const Icon(Icons.edit_outlined),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<UserDetailCubit, UserDetailState>(
        builder: (context, state) {
          if (state is UserDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserDetailSukses) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(state.user.avatar),
                          onBackgroundImageError: (_, __) {},
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.user.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.person_pin_outlined,
                              size: 28,
                              color: Colors.blueGrey,
                            ),
                            title: const Text(
                              'ID Pengguna',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              state.user.id,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.location_on_outlined,
                              size: 28,
                              color: Colors.blueGrey,
                            ),
                            title: const Text(
                              'Alamat',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              state.user.address,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is UserDetailError) {
            return Center(child: Text(state.message));
          }

          return const Center(child: Text("Tidak ada data untuk ditampilkan."));
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus pengguna ini?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await context.read<UserDetailCubit>().deleteUser(userId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pengguna berhasil dihapus'),
                      ),
                    );
                    Navigator.of(context).pop(true);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
