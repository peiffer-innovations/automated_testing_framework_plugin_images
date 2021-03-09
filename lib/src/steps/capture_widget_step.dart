import 'dart:async';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:json_theme/json_theme.dart';

class CaptureWidgetStep extends TestRunnerStep {
  CaptureWidgetStep({
    this.backgroundColor,
    this.goldenCompatible,
    this.imageId,
    required this.testableId,
    this.timeout,
  }) : assert(testableId.isNotEmpty == true);

  /// The background color to use in the widget capture.  Will be effectively
  /// [Colors.transparent] if not set.
  final Color? backgroundColor;

  /// Set to [false] if the image being taken is not compatible with being a
  /// golden image.
  final bool? goldenCompatible;

  /// The id to use for the screenshot.  Defaults to 'widget_$testableId' if not
  /// set.
  final String? imageId;

  /// The id of the [Testable] widget to interact with.
  final String testableId;

  /// The maximum amount of time this step will wait while searching for the
  /// [Testable] on the widget tree.
  final Duration? timeout;

  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  ///   "backgroundColor": <String>,
  ///   "goldenCompatible": <bool>,
  ///   "imageId": <String>,
  ///   "testableId": <String>,
  ///   "timeout": <number>
  /// }
  /// ```
  ///
  /// See also:
  /// * [JsonClass.parseDurationFromSeconds]
  /// * [ThemeDecoder.decodeColor]
  static CaptureWidgetStep fromDynamic(dynamic map) {
    CaptureWidgetStep result;

    if (map == null) {
      throw Exception('[CaptureWidgetStep.fromDynamic]: map is null');
    } else {
      result = CaptureWidgetStep(
        backgroundColor: ThemeDecoder.decodeColor(map['backgroundColor']),
        goldenCompatible: map['goldenCompatible'] == null
            ? true
            : JsonClass.parseBool(map['goldenCompatible']),
        imageId: map['imageId'],
        testableId: map['testableId'],
        timeout: JsonClass.parseDurationFromSeconds(map['timeout']),
      );
    }

    return result;
  }

  /// Executes the step.  This will first look for the [Testable], attempt to
  /// capture the image of the widget, and set it on the [report] as a
  /// screenshot.
  @override
  Future<void> execute({
    required CancelToken cancelToken,
    required TestReport report,
    required TestController tester,
  }) async {
    String? imageId = tester.resolveVariable(this.imageId);
    String? testableId = tester.resolveVariable(this.testableId);
    assert(testableId?.isNotEmpty == true);

    var name = "capture_widget('$testableId')";
    log(
      name,
      tester: tester,
    );
    var finder = await waitFor(
      testableId,
      cancelToken: cancelToken,
      tester: tester,
      timeout: timeout,
    );

    await sleep(
      tester.delays.postFoundWidget,
      cancelStream: cancelToken.stream,
      tester: tester,
    );

    var widgetFinder = finder.evaluate();
    var found = false;
    if (widgetFinder.isNotEmpty == true) {
      var element = widgetFinder.first as StatefulElement;

      var state = element.state;
      if (state is TestableState) {
        try {
          found = true;
          var image = await state.captureImage(backgroundColor);
          if (image != null) {
            report.attachScreenshot(
              image,
              goldenCompatible: goldenCompatible ?? true,
              id: imageId ?? 'widget_$testableId',
            );
          }
        } catch (e) {
          found = false;
        }
      }
    }
    if (found != true) {
      throw Exception(
        'testableId: [$testableId] -- could not locate Testable with a functional [captureImage] method.',
      );
    }
  }

  /// Overidden to ignore the delay
  @override
  Future<void> postStepSleep(Duration duration) async {}

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'backgroundColor': ThemeEncoder.encodeColor(backgroundColor),
        'imageId': imageId,
        'testableId': testableId,
        'timeout': timeout?.inSeconds,
      };
}
