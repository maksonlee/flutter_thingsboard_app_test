import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/device_model.dart';
import 'login_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({Key? key}) : super(key: key);

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
                      final device =
                          Provider.of<DeviceModel>(context, listen: false);
                      device.tbClient.logout();
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
