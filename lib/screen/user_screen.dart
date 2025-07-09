// file: screen/user_screen.dart

import 'package:api/cubit/user_cubit.dart';
import 'package:api/repository/user_repository.dart';
import 'package:api/screen/add_user_screen.dart';
import 'package:api/screen/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserCubit>().getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.network_check),
            onPressed: () async {
              final repository = UserRepository();
              print('[UI] Testing connection...');
              await repository.testConnectionDetails();
              final isConnected = await repository.testConnection();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isConnected ? 'Connection successful!' : 'Connection failed!',
                    ),
                    backgroundColor: isConnected ? Colors.green : Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddUserScreen()),
          );
          // Jika user baru berhasil dibuat, muat ulang daftar
          if (result == true && context.mounted) {
            context.read<UserCubit>().getUsers();
          }
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Cari nama pengguna...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onChanged: (query) {
                context.read<UserCubit>().searchUsers(query);
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is UserSukses) {
                  if (state.users.isEmpty) {
                    return const Center(
                      child: Text("Pengguna tidak ditemukan."),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<UserCubit>().getUsers();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: state.users.length,
                      itemBuilder: (context, index) {
                        final user = state.users[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              // Tunggu hasil dari DetailScreen
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          DetailScreen(userId: user.id),
                                ),
                              );
                              // Jika ada perubahan (edit/delete), muat ulang daftar
                              if (result == true && context.mounted) {
                                context.read<UserCubit>().getUsers();
                              }
                            },
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(user.avatar),
                                onBackgroundImageError: (_, __) {},
                              ),
                              title: Text(
                                user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                user.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }

                if (state is UserError) {
                  return Center(child: Text("Error: ${state.message}"));
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
