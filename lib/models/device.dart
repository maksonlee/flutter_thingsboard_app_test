import 'chart_data.dart';

class MyDevice {
  String name;
  String? id;
  String temperature;
  String humidity;
  var chartData = <ChartData>[];

  MyDevice(this.name, this.id, this.temperature, this.humidity);
}
