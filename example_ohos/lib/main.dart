import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:disk_space_plus/disk_space_plus.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double? _totalDiskSpace;
  double? _freeDiskSpace;
  double? _freeDiskSpaceForPath;

  @override
  void initState() {
    super.initState();
    initDiskSpacePlus();
  }

  Future<void> initDiskSpacePlus() async {
    double? totalDiskSpace;
    double? freeDiskSpace;
    double? freeDiskSpaceForPath;

    totalDiskSpace = await DiskSpacePlus.getTotalDiskSpace;
    freeDiskSpace = await DiskSpacePlus.getFreeDiskSpace;
    freeDiskSpaceForPath = await DiskSpacePlus.getFreeDiskSpaceForPath('/');
    if (!mounted) return;

    setState(() {
      _totalDiskSpace = totalDiskSpace;
      _freeDiskSpace = freeDiskSpace;
      _freeDiskSpaceForPath = freeDiskSpaceForPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Center(
              child: Text('Total space on device (MB): $_totalDiskSpace\n'),
            ),
            Center(
              child: Text('Free space on device (MB): $_freeDiskSpace\n'),
            ),
            Center(
              child: Text(
                  'Free space for path "/" (MB): $_freeDiskSpaceForPath\n'),
            ),
          ],
        ),
      ),
    );
  }
}
