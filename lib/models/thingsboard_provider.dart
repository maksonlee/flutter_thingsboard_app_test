import 'package:flutter/material.dart';
import 'package:thingsboard_app/models/room.dart';
import 'package:thingsboard_client/thingsboard_client.dart';

import '../constants/app_constants.dart';
import '../utils/tb_secure_storage.dart';
import 'device.dart';

class ThingsBoardProvider with ChangeNotifier {
  late final ThingsboardClient tbClient;
  var devices = <String, MyDevice>{};
  var rooms = <MyRoom>[];
  String deviceId = "";
  late TelemetrySubscriber subscription;

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
              tbClient.getAuthUser()!.customerId, pageLink);
      for (var device in deviceInfos.data) {
        devices[device.id!.id!] = MyDevice(device.name, device.id!.id!, "-");
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
              tbClient.getAuthUser()!.customerId, pageLink);
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

  void subscribe() async {
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
        var id = data.data[0].entityId.id;
        for (var temp in data.data[0].timeseries["temperature"]!.reversed) {
          addData(id!, DateTime.fromMillisecondsSinceEpoch(temp.ts),
              double.parse(temp.value ?? "0"));
        }
        notifyListeners();
      }

      if (update != null) {
        if (update[0].timeseries["temperature"] != null) {
          var id = update[0].entityId.id;
          devices[id]!.temperature = update[0].timeseries["temperature"] == null
              ? "-"
              : update[0].timeseries["temperature"]![0].value!;
          addData(
              id!,
              DateTime.fromMillisecondsSinceEpoch(
                  update[0].timeseries["temperature"]![0].ts),
              double.parse(devices[id]!.temperature!));
          print(devices[id]!.temperature);
          notifyListeners();
        }
      }
    });
  }

  void addData(String devicdId, DateTime x, double y) {
    devices[devicdId]!.chartData.add(ChartData(x, y));
    if (devices[devicdId]!
        .chartData[0]
        .x
        .add(const Duration(minutes: 1))
        .isBefore(DateTime.now())) {
      devices[devicdId]!.chartData.removeAt(0);
    }
  }
}

class ChartData {
  DateTime x;
  double y;

  ChartData(this.x, this.y);
}
