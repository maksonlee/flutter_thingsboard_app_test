import 'package:flutter/material.dart';
import 'package:thingsboard_app/screens/device_detail_screen.dart';
import 'package:provider/provider.dart';

import '../models/device_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final device = Provider.of<DeviceModel>(context, listen: false);
    device.getDevices();
  }

  @override
  Widget build(BuildContext context) {
    final device = Provider.of<DeviceModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Devices"),
      ),
      body: ListView.builder(
        itemCount: device.devices.length,
        itemBuilder: ((context, index) => Card(
              child: ListTile(
                title: Text(device.devices[index].name),
                subtitle: Text(device.devices[index].id ?? ""),
                onTap: () {
                  device.index = index;
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
