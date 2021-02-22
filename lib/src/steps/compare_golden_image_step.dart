import 'dart:ui';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:automated_testing_framework_plugin_images/automated_testing_framework_plugin_images.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:json_theme/json_theme.dart';
import 'package:meta/meta.dart';

/// Compares the images and fails if more that [allowedDelta] percentage of
/// pixels are different.  By default, the difference is allowed to be 1% of the
/// total pixels.
class CompareGoldenImageStep extends TestRunnerStep {
  CompareGoldenImageStep({
    this.allowedDelta,
    this.failWhenGoldenMissing,
    this.imageId,
    this.imageOnFail,
  }) : assert(imageOnFail == null ||
            imageOnFail == 'isolated' ||
            imageOnFail == 'masked');

  final dynamic allowedDelta;
  final bool failWhenGoldenMissing;
  final String imageId;
  final String imageOnFail;

  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  ///   "allowedDelta": <double>,
  ///   "failWhenGoldenMissing": <bool>,
  ///   "imageId": <String>
  /// }
  /// ```
  ///
  /// See also:
  /// * [JsonClass.parseDurationFromSeconds]
  /// * [ThemeDecoder.decodeColor]
  static CompareGoldenImageStep fromDynamic(dynamic map) {
    CompareGoldenImageStep result;

    if (map != null) {
      result = CompareGoldenImageStep(
        allowedDelta: JsonClass.parseDouble(map['allowedDelta']),
        failWhenGoldenMissing: map['failWhenGoldenMissing'] == null
            ? true
            : JsonClass.parseBool(map['failWhenGoldenMissing']),
        imageId: map['imageId'],
        imageOnFail: map['imageOnFail'],
      );
    }

    return result;
  }

  /// Executes the step.  This will first look for the actual image, then
  /// attempt to load the image from the golden cache.  It will compare the
  /// images and return a result.
  @override
  Future<void> execute({
    @required CancelToken cancelToken,
    @required TestReport report,
    @required TestController tester,
  }) async {
    var allowedDelta = JsonClass.parseDouble(
      tester.resolveVariable(this.allowedDelta),
      0.01,
    );
    var imageId = this.imageId ??
        report?.images
            ?.where((image) => image.goldenCompatible == true)
            ?.last
            ?.id;
    if (imageId?.isNotEmpty != true) {
      throw Exception('compare_golden_image: No imageId found');
    }

    var name =
        "compare_golden_image('$imageId', '$failWhenGoldenMissing', '$imageOnFail', '$allowedDelta')";
    log(
      name,
      tester: tester,
    );

    var actual =
        report?.images?.where((image) => image.id == imageId)?.first?.image;
    if (actual == null) {
      throw Exception('imageId: [$imageId] -- error loading actual image');
    }

    var master = await tester.testImageReader(
      deviceInfo: report.deviceInfo,
      imageId: imageId,
      suiteName: report.suiteName,
      testName: report.name,
      testVersion: report.version,
    );

    if (master == null) {
      if (failWhenGoldenMissing == true) {
        throw Exception('imageId: [$imageId] -- error loading golden image');
      }
    } else {
      var comparitor = GoldenImageComparator();
      var result = await comparitor.compareLists(actual, master, allowedDelta);

      if (result.passed != true) {
        var failImage =
            imageOnFail == 'isolated' ? result.isolated : result.masked;
        if (failImage != null) {
          report?.attachScreenshot(
            (await failImage.toByteData(format: ImageByteFormat.png))
                .buffer
                .asUint8List(),
            goldenCompatible: false,
            id: 'failed-${imageId}',
          );
        }
        throw Exception('${result.error}');
      }
    }
  }

  /// Overidden to ignore the delay
  @override
  Future<void> preStepSleep(Duration duration) async {}

  /// Overidden to ignore the delay
  @override
  Future<void> postStepSleep(Duration duration) async {}

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'failWhenGoldenMissing': failWhenGoldenMissing,
        'imageId': imageId,
        'imageOnFail': imageOnFail,
      };
}
