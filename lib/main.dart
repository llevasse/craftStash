import 'dart:io';

import 'package:craft_stash/data/repository/stitch_repository.dart';
import 'package:craft_stash/ui/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

bool debug = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    PackageInfo.fromPlatform().then((value) {
      if (value.packageName.endsWith(".dev")) {
        debug = true;
      } else if (value.packageName == "com.example.app.prod") {
        debug = false;
      }
    });
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await StitchRepository().setStitchToIdMap();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'craft stash',
      debugShowCheckedModeBanner: debug,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.amber,
          secondary: Colors.brown,
          tertiary: Colors.amber.shade100,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
