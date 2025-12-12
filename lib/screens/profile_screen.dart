// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../auth_repository.dart'; 
import '../providers/app_user_provider.dart';
import '../providers/notification_provider.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryPink = Color(0xFFF72585);
  static const Color softBackground = Color(0xFFF7EAF0);

  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppUserProvider>(context, listen: false).fetchUserProfile();
    });
  }

  Future<void> _logOut() async {
    try {
      final authRepository = Provider.of<AuthRepository>(context, listen: false);
      
      await authRepository.signOut();
      
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during logout: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<AppUserProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    
    final AppUser? user = userProvider.user;
    final ProfileLoadState loadState = userProvider.loadState;
    final int unreadCount = notificationProvider.unreadCount;
    final String displayName = user?.name ?? 'User';
    final String displayEmail = user?.email ?? 'Loading...';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40), 

            if (loadState == ProfileLoadState.loading)
              const Center(child: CircularProgressIndicator(color: primaryPink))
            else if (loadState == ProfileLoadState.loaded && user != null)
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 80, 
                      backgroundColor: softBackground,
                      // якщо є URL, відображаємо CachedNetworkImage
                      backgroundImage: user.profilePictureUrl != null 
                          ? CachedNetworkImageProvider(user.profilePictureUrl!)
                          : null,
                      child: (user.profilePictureUrl == null || user.profilePictureUrl!.isEmpty)
                          ? const Icon(Icons.person, size: 60, color: Color(0xFFF72585))
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text(displayEmail, style: const TextStyle(fontSize: 14, color: Color(0xFF9A4D73))),
                  ],
                ),
              )
            else
              const Center(child: Text("Error loading profile.")),

            const SizedBox(height: 40),
            
            const Text(
              "Account",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            _buildProfileOption(
              title: "Edit Profile",
              onTap: () {
                Navigator.pushNamed(context, '/edit_profile');
              },
            ),
            _buildProfileOption(
              title: "Change Password",
              onTap: () {},
            ),
            const SizedBox(height: 30),

            const Text(
              "Settings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            _buildProfileOption(
              title: "Notifications",
              onTap: () {
                Navigator.pushNamed(context, '/notifications');
              },
              trailing: unreadCount > 0 ? Chip(label: Text('$unreadCount', style: const TextStyle(color: Colors.white)), backgroundColor: primaryPink) : null,
            ),
            _buildProfileOption(title: "Privacy", onTap: () {}),
            _buildProfileOption(title: "Help", onTap: () {}),
            
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _logOut, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF7EAF0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: BorderSide.none,
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Color(0xFFF72585),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({required String title, required VoidCallback onTap, Widget? trailing}) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF9A4D73)),
      onTap: onTap,
    );
  }
}