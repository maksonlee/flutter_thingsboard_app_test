import 'package:flutter/material.dart';
import 'package:thingsboard_app/screens/room_screen.dart';
import 'package:thingsboard_app/screens/home_screen.dart';
import 'package:thingsboard_app/screens/more_screen.dart';

class MyTabController extends StatelessWidget {
  const MyTabController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          bottomNavigationBar: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.home), text: "Home"),
              Tab(icon: Icon(Icons.bedroom_child_outlined), text: "Room"),
              Tab(icon: Icon(Icons.more_vert), text: "More"),
            ],
          ),
          body: TabBarView(
            children: [
              HomeScreen(),
              RoomScreen(),
              MoreScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
