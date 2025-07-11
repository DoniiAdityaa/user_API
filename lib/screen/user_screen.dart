// file: screen/user_screen.dart

import 'package:api/cubit/user_cubit.dart';
import 'package:api/screen/add_user_screen.dart';
import 'package:api/screen/detail_screen.dart';
import 'package:api/screen/login_screen.dart';
import 'package:api/service/google_auth.dart';
import 'package:api/widget/calender_botom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  DateTime _lastSelectedDate = DateTime.now();

  void _showCalendarBottomSheet(BuildContext context) async {
    final selectedDate = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return CalendarBotomSheet(initialDate: _lastSelectedDate);
      },
    );
    if (selectedDate != null && mounted) {
      setState(() {
        _lastSelectedDate = selectedDate;
      });
      context.read<UserCubit>().filterUsersByDate(selectedDate);
    }
  }

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
          // Show user info and logout button
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'user_info',
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _googleAuthService.getUserDisplayName() ?? 'User',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _googleAuthService.getUserEmail() ?? 'No email',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 18),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  _googleAuthService.getUserPhotoURL() ?? '',
                ),
                onBackgroundImageError: (_, __) {},
                child:
                    _googleAuthService.getUserPhotoURL() == null
                        ? const Icon(Icons.person)
                        : null,
              ),
            ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
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
                SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    _showCalendarBottomSheet(context);
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    BlocProvider.of<UserCubit>(context).getUsers();
                  },
                  icon: Icon(Icons.refresh_sharp),
                ),
              ],
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _logout();
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  Future<void> _logout() async {
    try {
      await _googleAuthService.signOut();

      // Navigate back to login screen and clear the navigation stack
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
