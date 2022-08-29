import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/thingsboard_provider.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({Key? key}) : super(key: key);

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ThingsBoardProvider>(context, listen: false);
    provider.getRooms();
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
                                      "assets/images/temperature-sensor-icon.png"),
                                )),
                            const Expanded(
                                flex: 2,
                                child: Center(
                                    child: Text("12.34",
                                        style: TextStyle(fontSize: 25)))),
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
