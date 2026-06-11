import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Profil", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF2563EB),
                  child: Icon(Icons.person_rounded, size: 50, color: Colors.white),
                ),
                SizedBox(height: 16),
                Text(
                  "Jean Dupont",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                Text(
                  "jean.dupont@email.com",
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "Paramètres du compte",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 16),
          _buildProfileOption(Icons.person_outline_rounded, "Informations personnelles"),
          _buildProfileOption(Icons.notifications_none_rounded, "Notifications"),
          _buildProfileOption(Icons.security_rounded, "Sécurité & Mot de passe"),
          _buildProfileOption(Icons.language_rounded, "Langue & Région"),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEE2E2),
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text("Se déconnecter"),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF64748B)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {},
      ),
    );
  }
}
