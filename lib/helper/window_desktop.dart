import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

Future<void> initWindowForDesktop() async {
  if (!Platform.isWindows) return; // only do this on Windows

  // Must come after WidgetsFlutterBinding.ensureInitialized()
  await windowManager.ensureInitialized();

  const options = WindowOptions(
    size: Size(600, 920),
    minimumSize: Size(600, 920),
    center: false,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
