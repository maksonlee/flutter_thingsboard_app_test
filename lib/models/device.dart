import 'package:thingsboard_app/models/thingsboard_provider.dart';

class MyDevice {
  String name;
  String? id;
  String? temperature;
  var chartData = <ChartData>[];

  MyDevice(this.name, this.id, this.temperature);
}
