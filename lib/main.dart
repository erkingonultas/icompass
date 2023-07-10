import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(
    const MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasPermission = false;

  @override
  void initState() {
    _fetchPermissionStatus();
    super.initState();
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) => {
          if (mounted)
            {
              setState(() {
                _hasPermission = (status == PermissionStatus.granted);
              })
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade800,
        title: const Text(
          'iCompass',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            return showAboutDialog(
              context: context,
              applicationName: "iCompass",
              useRootNavigator: false,
              children: [
                const Text('Designed and developed by\nErkin Gönültaş.'),
              ],
            );
          },
          icon: const Icon(Icons.info),
        ),
      ),
      body: Center(
        child: Builder(builder: (context) {
          if (_hasPermission) {
            return _buildCompass();
          } else {
            return _buildPermissionSheet();
          }
        }),
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator.adaptive();
          }
          double? direction = snapshot.data!.heading;
          if (direction == null) {
            return const Text('Device does not have sensors');
          }
          return Transform.rotate(
            angle: direction * (math.pi / 180) * -1,
            child: Image.asset(
              'lib/assets/bg.jpg',
            ),
          );
        });
  }

  Widget _buildPermissionSheet() {
    return ElevatedButton(
      child: const Text('Request Permission'),
      onPressed: () => Permission.locationWhenInUse.request().then((value) => _fetchPermissionStatus()),
    );
  }
}
