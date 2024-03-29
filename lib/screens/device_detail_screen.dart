import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import '../models/chart_data.dart';
import '../models/thingsboard_provider.dart';

class DeviceDetailScreen extends StatefulWidget {
  const DeviceDetailScreen({super.key});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen>
    with WidgetsBindingObserver {
  late ThingsBoardProvider provider;
  late TelemetrySubscriber subscriber;
  bool isSubscribed = false;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<ThingsBoardProvider>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    provider.devices[provider.deviceId]!.temperature = "-";
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
    if (state == AppLifecycleState.resumed) {
      subscribe();
    } else {
      unSubscribe();
    }
  }

  void subscribe() {
    provider.createSubscriber();
    subscriber = provider.subscriber;
    if (!isSubscribed) {
      subscriber.subscribe();
      isSubscribed = true;
    }
  }

  void unSubscribe() {
    if (isSubscribed) {
      subscriber.unsubscribe();
      isSubscribed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThingsBoardProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(provider.devices[provider.deviceId]!.name),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Card(
              child: Center(
                child: Text(
                  provider.devices[provider.deviceId]!.temperature,
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
                    primaryXAxis: const DateTimeAxis(),
                    series: List.from(<ChartSeries>[
                      LineSeries<ChartData, DateTime>(
                          dataSource:
                              provider.devices[provider.deviceId]!.chartData,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y)
                    ])),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
