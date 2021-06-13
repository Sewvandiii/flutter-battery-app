import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:battery_example/main.dart';
import 'package:flutter/material.dart';
import 'package:battery/battery.dart';
import 'package:battery_example/models/battery_level.dart';
import 'package:battery_example/services/battery_service.dart';

class BatteryPage extends StatefulWidget {
  @override
  _BatteryPageState createState() => _BatteryPageState();
}

class _BatteryPageState extends State<BatteryPage> {
  final battery = Battery();
  int batteryLevel = 100;
  BatteryState batteryState = BatteryState.full;

  List<BatteryLevel> _batteryList;
  BatteryService _batteryService = BatteryService();
  StreamSubscription<QuerySnapshot> batterySubsciption;

  Timer timer;
  StreamSubscription subscription;

  @override
  void initState() {
    super.initState();

    listenBatteryLevel();
    listenBatteryState();

    _batteryList = [];
    batterySubsciption?.cancel();
    batterySubsciption =
        _batteryService.getAll().listen((QuerySnapshot snapshot) {
      final List<BatteryLevel> batteriess =
          snapshot.docs.map((d) => BatteryLevel.fromMap(d.data())).toList();

      setState(() {
        this._batteryList = batteriess;
      });
    });

    _batteryService.create(new BatteryLevel(" ", batteryState.toString(), batteryLevel));
  }

  void listenBatteryState() =>
      subscription = battery.onBatteryStateChanged.listen(
        (batteryState) => setState(() => this.batteryState = batteryState),
      );

  void listenBatteryLevel() {
    updateBatteryLevel();

    timer = Timer.periodic(
      Duration(seconds: 10),
      (_) async => updateBatteryLevel(),
    );
  }

  Future updateBatteryLevel() async {
    final batteryLevel = await battery.batteryLevel;

    setState(() => this.batteryLevel = batteryLevel);
  }

  @override
  void dispose() {
    timer.cancel();
    subscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(MyApp.title),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildBatteryState(batteryState),
              const SizedBox(height: 30),
              buildBatteryLevel(batteryLevel),
            ],
          ),
        ),
      );

  Widget buildBatteryState(BatteryState batteryState) {
    final style = TextStyle(fontSize: 25, color: Colors.white);
    final double size = 280;

    switch (batteryState) {
      case BatteryState.full:
        final color = Colors.green;

        return Column(
          children: [
            Icon(Icons.battery_full, size: size, color: color),
            Text('Full!', style: style.copyWith(color: color)),
          ],
        );
      case BatteryState.charging:
        final color = Colors.green;

        return Column(
          children: [
            Icon(Icons.battery_charging_full, size: size, color: color),
            Text('Charging...', style: style.copyWith(color: color)),
          ],
        );
      case BatteryState.discharging:
      default:
        final color = Colors.red;
        return Column(
          children: [
            Icon(Icons.battery_alert, size: size, color: color),
            Text('Discharging...', style: style.copyWith(color: color)),
          ],
        );
    }
  }

  Widget buildBatteryLevel(int batteryLevel) => Text(
        '$batteryLevel%',
        style: TextStyle(
          fontSize: 40,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
}
