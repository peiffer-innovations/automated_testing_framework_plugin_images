import 'dart:convert';
import 'dart:io';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:automated_testing_framework_example/automated_testing_framework_example.dart';
import 'package:automated_testing_framework_plugin_firebase_storage/automated_testing_framework_plugin_firebase_storage.dart';
import 'package:automated_testing_framework_plugin_images/automated_testing_framework_plugin_images.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

void main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      // ignore: avoid_print
      print('${record.error}');
    }
    if (record.stackTrace != null) {
      // ignore: avoid_print
      print('${record.stackTrace}');
    }
  });

  WidgetsFlutterBinding.ensureInitialized();

  final credentials =
      json.decode(await rootBundle.loadString('assets/login.json'));
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: credentials['username'],
    password: credentials['password'],
  );

  final store = FirebaseStorageTestStore(
    storage: FirebaseStorage.instance,
  );

  TestImagesHelper.registerTestSteps();

  var gestures = TestableGestures();
  if (kIsWeb ||
      Platform.isFuchsia ||
      Platform.isLinux ||
      Platform.isMacOS ||
      Platform.isWindows) {
    gestures = TestableGestures(
      widgetLongPress: null,
      widgetSecondaryLongPress: TestableGestureAction.open_test_actions_page,
      widgetSecondaryTap: TestableGestureAction.open_test_actions_dialog,
    );
  }

  final allTests = List<String>.from(
    json.decode(
      await rootBundle.loadString(
        'assets/all_tests.json',
      ),
    ),
  );

  allTests.addAll(
    List<String>.from(
      json.decode(
        await rootBundle.loadString(
          'packages/automated_testing_framework_example/assets/all_tests.json',
        ),
      ),
    ),
  );

  runApp(App(
    options: TestExampleOptions(
      autorun: kProfileMode,
      enabled: true,
      gestures: gestures,
      goldenImageWriter: store.goldenImageWriter,
      testImageReader: store.testImageReader,
      testReader: AssetTestStore(testAssets: allTests).testReader,
      testWidgetsEnabled: true,
      testWriter: ClipboardTestStore.testWriter,
    ),
  ));
}
