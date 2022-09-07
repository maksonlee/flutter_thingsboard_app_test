import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import '../models/thingsboard_provider.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({Key? key}) : super(key: key);

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> with WidgetsBindingObserver {
  late ThingsBoardProvider provider;
  late TelemetrySubscriber subscriber;
  bool isSubscribed = false;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<ThingsBoardProvider>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    init();
  }

  void init() async {
    await provider.getDevices();
    await provider.getRooms();
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
    provider.deviceId = "";
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rooms"),
      ),
      body: getContent(),
    );
  }

  Widget getContent() {
    final provider = Provider.of<ThingsBoardProvider>(context);
    return SizedBox(
      height: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 8.0,
        runSpacing: 4.0,
        children: provider.rooms
            .map((room) => Card(
                    child: SizedBox(
                  width: 160,
                  height: 160,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(room.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                                flex: 1,
                                child: Center(
                                  child: Image.asset(
                                      "assets/images/thermometer.png"),
                                )),
                            Expanded(
                                flex: 2,
                                child: Center(
                                    child: Text(
                                        provider.devices[room.deviceId] != null
                                            ? provider.devices[room.deviceId]!
                                                .temperature
                                            : "-",
                                        style: const TextStyle(fontSize: 20)))),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                                flex: 1,
                                child: Center(
                                  child:
                                      Image.asset("assets/images/humidity.png"),
                                )),
                            Expanded(
                                flex: 2,
                                child: Center(
                                    child: Text(
                                        provider.devices[room.deviceId] != null
                                            ? provider.devices[room.deviceId]!
                                                .humidity
                                            : "-",
                                        style: const TextStyle(fontSize: 20)))),
                          ],
                        ),
                      ),
                    ],
                  ),
                )))
            .toList(),
      ),
    );
  }
}
