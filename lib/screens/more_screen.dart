import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/thingsboard_provider.dart';
import 'login_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("Log out"),
                    onTap: () {
                      final provider =
                          Provider.of<ThingsBoardProvider>(context, listen: false);
                      provider.tbClient.logout();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return const LoginScreen();
                      }));
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
