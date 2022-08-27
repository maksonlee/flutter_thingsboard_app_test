import 'package:flutter/material.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import '../constants/app_constants.dart';
import '../utils/tb_secure_storage.dart';
import 'device.dart';

class DeviceModel with ChangeNotifier {
  late final ThingsboardClient tbClient;
  var devices = <MyDevice>[];
  int index = -1;
  String? temperature;
  late TelemetrySubscriber subscription;
  var datas = <ChartData>[];

  Future<bool> init() async {
    var storage = TbSecureStorage();
    tbClient = ThingsboardClient(ThingsboardAppConstants.thingsBoardApiEndpoint,
        storage: storage);
    await tbClient.init();
    return tbClient.isAuthenticated();
  }

  void getDevices() async {
    devices.clear();
    var pageLink = PageLink(10);
    PageData<DeviceInfo> deviceInfos;

    do {
      deviceInfos = tbClient.getAuthUser()!.isTenantAdmin()
          ? await tbClient.getDeviceService().getTenantDeviceInfos(pageLink)
          : await tbClient.getDeviceService().getCustomerDeviceInfos(
              tbClient.getAuthUser()!.customerId, pageLink);
      for (var device in deviceInfos.data) {
        devices.add(MyDevice(device.name, device.id?.id));
      }
      pageLink = pageLink.nextPageLink();
    } while (deviceInfos.hasNext);

    notifyListeners();
  }

  void subscribe() async {
    datas.clear();
    var entityFilter = EntityNameFilter(
        entityType: EntityType.DEVICE, entityNameFilter: devices[index].name);
    var deviceTelemetry = <EntityKey>[
      EntityKey(type: EntityKeyType.TIME_SERIES, key: 'temperature'),
    ];
    var devicesQuery = EntityDataQuery(
        entityFilter: entityFilter,
        latestValues: deviceTelemetry,
        pageLink: EntityDataPageLink(
          pageSize: 10,
        ));

    var currentTime = DateTime.now().millisecondsSinceEpoch;
    var timeWindow = const Duration(hours: 1).inMilliseconds;
    var tsCmd = TimeSeriesCmd(
        keys: ['temperature'],
        startTs: currentTime - timeWindow,
        timeWindow: timeWindow);
    var cmd = EntityDataCmd(query: devicesQuery, tsCmd: tsCmd);
    var telemetryService = tbClient.getTelemetryService();
    subscription = TelemetrySubscriber(telemetryService, [cmd]);
    subscription.entityDataStream.listen((entityDataUpdate) {
      var data = entityDataUpdate.data;
      var update = entityDataUpdate.update;
      if (data != null) {
        for (var temp in data.data[0].timeseries["temperature"]!.reversed) {
          addData(DateTime.fromMillisecondsSinceEpoch(temp.ts),
              double.parse(temp.value ?? "0"));
        }
        notifyListeners();
      }

      if (update != null) {
        if (update[0].timeseries["temperature"] != null) {
          temperature = update[0].timeseries["temperature"]![0].value;
          addData(
              DateTime.fromMillisecondsSinceEpoch(
                  update[0].timeseries["temperature"]![0].ts),
              double.parse(temperature!));
          print(temperature);
          notifyListeners();
        }
      }
    });
  }

  void addData(DateTime x, double y) {
    datas.add(ChartData(x, y));
    if (datas[0].x.add(const Duration(minutes: 1)).isBefore(DateTime.now())) {
      datas.removeAt(0);
    }
  }
}

class ChartData {
  DateTime x;
  double y;

  ChartData(this.x, this.y);
}
