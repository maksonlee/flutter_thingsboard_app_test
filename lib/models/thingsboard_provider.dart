import 'package:flutter/material.dart';
import 'package:thingsboard_app/models/room.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import '../constants/app_constants.dart';
import '../utils/tb_secure_storage.dart';
import 'chart_data.dart';
import 'device.dart';

class ThingsBoardProvider with ChangeNotifier {
  late final ThingsboardClient tbClient;
  var devices = <String, MyDevice>{};
  var rooms = <MyRoom>[];
  String deviceId = "";
  late TelemetrySubscriber subscriber;

  Future<bool> init() async {
    var storage = TbSecureStorage();
    tbClient = ThingsboardClient(ThingsboardAppConstants.thingsBoardApiEndpoint,
        storage: storage);
    await tbClient.init();
    return tbClient.isAuthenticated();
  }

  Future<void> getDevices() async {
    devices.clear();
    var pageLink = PageLink(10);
    PageData<DeviceInfo> deviceInfos;

    do {
      deviceInfos = tbClient.getAuthUser()!.isTenantAdmin()
          ? await tbClient.getDeviceService().getTenantDeviceInfos(pageLink)
          : await tbClient.getDeviceService().getCustomerDeviceInfos(
              tbClient.getAuthUser()!.customerId!, pageLink);
      for (var device in deviceInfos.data) {
        devices[device.id!.id!] =
            MyDevice(device.name, device.id!.id!, "-", "-");
      }
      pageLink = pageLink.nextPageLink();
    } while (deviceInfos.hasNext);

    notifyListeners();
  }

  Future<void> getRooms() async {
    rooms.clear();
    var pageLink = PageLink(10);
    PageData<AssetInfo> roomInfos;

    do {
      roomInfos = tbClient.getAuthUser()!.isTenantAdmin()
          ? await tbClient.getAssetService().getTenantAssetInfos(pageLink)
          : await tbClient.getAssetService().getCustomerAssetInfos(
              tbClient.getAuthUser()!.customerId!, pageLink);
      for (var room in roomInfos.data) {
        var r = await tbClient.getAssetService().getAsset(room.id!.id!);
        var t = await tbClient
            .getEntityRelationService()
            .findByFrom(r!.id!, relationType: "Contains");
        String? id;
        if (t.isNotEmpty) {
          id = t[0].to.id!;
        }
        rooms.add(MyRoom(room.name, room.id?.id, id));
      }
      pageLink = pageLink.nextPageLink();
    } while (roomInfos.hasNext);

    notifyListeners();
  }

  void createSubscriber() async {
    var entityList = <String>[];
    if (deviceId == "") {
      for (var device in devices.values.toList()) {
        device.chartData.clear();
        entityList.add(device.id!);
      }
    } else {
      devices[deviceId]!.chartData.clear();
      entityList.add(deviceId);
    }

    var entityFilter =
        EntityListFilter(entityType: EntityType.DEVICE, entityList: entityList);
    var deviceTelemetry = <EntityKey>[
      EntityKey(type: EntityKeyType.TIME_SERIES, key: 'temperature'),
      EntityKey(type: EntityKeyType.TIME_SERIES, key: 'humidity'),
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
        keys: ['temperature', 'humidity'],
        startTs: currentTime - timeWindow,
        timeWindow: timeWindow);
    var cmd = EntityDataCmd(query: devicesQuery, tsCmd: tsCmd);
    var telemetryService = tbClient.getTelemetryService();
    subscriber = TelemetrySubscriber(telemetryService, [cmd]);
    subscriber.entityDataStream.listen((entityDataUpdate) {
      var data = entityDataUpdate.data;
      var update = entityDataUpdate.update;
      if (data != null) {
        var id = data.data[0].entityId.id;
        for (var temp in data.data[0].timeseries["temperature"]!.reversed) {
          addData(id!, temp.ts, double.parse(temp.value ?? "0"));
        }
      }

      if (update != null) {
        if (update[0].timeseries["temperature"] != null) {
          var id = update[0].entityId.id;
          devices[id]!.temperature = update[0].timeseries["temperature"] == null
              ? "-"
              : update[0].timeseries["temperature"]![0].value!;
          addData(id!, update[0].timeseries["temperature"]![0].ts,
              double.parse(devices[id]!.temperature));
        }
        if (update[0].timeseries["humidity"] != null) {
          var id = update[0].entityId.id;
          devices[id]!.humidity = update[0].timeseries["humidity"] == null
              ? "-"
              : update[0].timeseries["humidity"]![0].value!;
        }
      }
      notifyListeners();
    });
  }

  void addData(String deviceId, int x, double y) {
    var t = DateTime.fromMillisecondsSinceEpoch(x);
    devices[deviceId]!.chartData.add(ChartData(t, y));
    if (devices[deviceId]!
        .chartData[0]
        .x
        .add(const Duration(minutes: 1))
        .isBefore(DateTime.now())) {
      devices[deviceId]!.chartData.removeAt(0);
    }
  }
}
