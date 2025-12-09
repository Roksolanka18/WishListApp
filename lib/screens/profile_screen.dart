import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final String _userName = "Roksolana Sozanska"; 
  final String _userEmail = "roksapz@gmail.com";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Видалено: Заголовок та стрілка назад ---
            const SizedBox(height: 40), // Збільшено відступ

            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 60, // Збільшено розмір фото
                    backgroundColor: Color(0xFFF7EAF0),
                    child: Icon(Icons.person, size: 60, color: Color(0xFFF72585)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    _userEmail,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9A4D73),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- Account Section ---
            const Text(
              "Account",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildProfileOption(
              title: "Edit Profile",
              onTap: () {},
            ),
            _buildProfileOption(
              title: "Change Password",
              onTap: () {},
            ),
            const SizedBox(height: 30),

            // --- Settings Section ---
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
            ),
            _buildProfileOption(
              title: "Privacy",
              onTap: () {},
            ),
            _buildProfileOption(
              title: "Help",
              onTap: () {},
            ),
            const SizedBox(height: 40),

            // --- Log Out Button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
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

  Widget _buildProfileOption({required String title, required VoidCallback onTap}) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF9A4D73)),
      onTap: onTap,
    );
  }
}