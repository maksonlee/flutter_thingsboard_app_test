import 'package:flutter/material.dart';
import 'package:thingsboard_app/screens/device_detail_screen.dart';
import 'package:provider/provider.dart';

import '../models/thingsboard_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ThingsBoardProvider>(context, listen: false);
    provider.getDevices();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThingsBoardProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Devices"),
      ),
      body: ListView.builder(
        itemCount: provider.devices.length,
        itemBuilder: ((context, index) => Card(
              child: ListTile(
                title: Text(provider.devices.values.toList()[index].name),
                subtitle: Text(provider.devices.values.toList()[index].id!),
                onTap: () {
                  provider.deviceId =
                      provider.devices.values.toList()[index].id!;
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const DeviceDetailScreen();
                  }));
                },
              ),
            )),
      ),
    );
  }
}
