import 'package:flutter/material.dart';
import 'package:movie_app/empMain.dart';
import 'package:movie_app/emp_login.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.white, // Change to a movie app theme color
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/deang.jpeg'),
              ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Sengaloun kumkeo", // Replace with the user's name
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "your.email@example.com", // Replace with the user's email
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

         ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text("Account"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to account settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner_sharp),
            title: const Text("EmployeeID"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const EmpLogin()),
                            
                            );
            },
          ),
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to about page
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Handle logout
            },
          ),
        ],
      ),
    );
  }
}