import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import '../models/device_model.dart';

class DeviceDetail extends StatefulWidget {
  const DeviceDetail({Key? key}) : super(key: key);

  @override
  State<DeviceDetail> createState() => _DeviceDetailState();
}

class _DeviceDetailState extends State<DeviceDetail> {
  late TelemetrySubscriber subscription;

  @override
  void initState() {
    super.initState();
    final device = Provider.of<DeviceModel>(context, listen: false);
    device.subscribe();
    subscription = device.subscription;
  }

  @override
  void deactivate() {
    subscription.unsubscribe();
    super.deactivate();
  }

  @override
  void dispose() {
    subscription.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = Provider.of<DeviceModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(device.devices[device.index].name),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                device.temperature ?? "",
                style: const TextStyle(
                  fontSize: 60,
                  color: Colors.deepOrange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
