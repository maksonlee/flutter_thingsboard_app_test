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
    final provider = Provider.of<ThingsBoardProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rooms"),
      ),
      body: ListView.builder(
        itemCount: provider.rooms.length,
        itemBuilder: ((context, index) => Card(
          child: ListTile(
            title: Text(provider.rooms[index].name),
            subtitle: Text(provider.rooms[index].id ?? ""),
            onTap: () {},
          ),
        )),
      ),
    );
  }
}