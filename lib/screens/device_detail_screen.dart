import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import '../models/thingsboard_provider.dart';

class DeviceDetailScreen extends StatefulWidget {
  const DeviceDetailScreen({Key? key}) : super(key: key);

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen>
    with WidgetsBindingObserver {
  late ThingsBoardProvider provider;
  late TelemetrySubscriber subscription;
  bool isSubscribed = false;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<ThingsBoardProvider>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    provider.devices[provider.deviceIndex].temperature = "";
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
    provider.subscribe();
    subscription = provider.subscription;
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
    final provider = Provider.of<ThingsBoardProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(provider.devices[provider.deviceIndex].name),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Card(
              child: Center(
                child: Text(
                  provider.devices[provider.deviceIndex].temperature?? "",
                  style: const TextStyle(
                    fontSize: 60,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Card(
              child: Center(
                child: SfCartesianChart(
                    primaryXAxis: DateTimeAxis(),
                    series: <ChartSeries>[
                      LineSeries<ChartData, DateTime>(
                          dataSource: provider.datas,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y)
                    ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
