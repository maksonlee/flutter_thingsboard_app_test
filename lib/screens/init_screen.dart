import 'package:flutter/material.dart';
import 'package:thingsboard_app/screens/login_screen.dart';
import 'package:provider/provider.dart';

import '../models/device_model.dart';
import 'my_tab_controller.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({Key? key}) : super(key: key);

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  @override
  void initState() {
    super.initState();
    final device = Provider.of<DeviceModel>(context, listen: false);
    device.init().then((isAuthenticated) {
      if (isAuthenticated) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return const MyTabController();
        }));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return const LoginScreen();
        }));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
