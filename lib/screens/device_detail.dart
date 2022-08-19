import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import '../models/device_model.dart';

class DeviceDetail extends StatefulWidget {
  const DeviceDetail({Key? key}) : super(key: key);

  @override
  State<DeviceDetail> createState() => _DeviceDetailState();
}

class _DeviceDetailState extends State<DeviceDetail>
    with WidgetsBindingObserver {
  late DeviceModel device;
  late TelemetrySubscriber subscription;
  bool isSubscribed = false;

  @override
  void initState() {
    super.initState();
    device = Provider.of<DeviceModel>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    subscribe();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unSubscribe();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        subscribe();
        break;
      case AppLifecycleState.paused:
        unSubscribe();
        break;
    }
  }

  void subscribe() {
    device.subscribe();
    subscription = device.subscription;
    if (!isSubscribed) {
      subscription.subscribe();
      isSubscribed = true;
    }
  }

  void unSubscribe() {
    if (isSubscribed) {
      subscription.unsubscribe();
      isSubscribed = false;
    }
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
          Expanded(
            flex: 1,
            child: Center(
              child: SfCartesianChart(
                  primaryXAxis: DateTimeAxis(),
                  series: <ChartSeries>[
                    LineSeries<ChartData, DateTime>(
                        dataSource: device.datas,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y)
                  ]),
            ),
          ),
        ],
      ),
    );
  }
}
