import 'dart:typed_data';
import 'dart:ui';

import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:automated_testing_framework_plugin_images/automated_testing_framework_plugin_images.dart';
import 'package:json_class/json_class.dart';
import 'package:json_theme/json_theme.dart';

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
            imageOnFail == 'both' ||
            imageOnFail == 'isolated' ||
            imageOnFail == 'masked');

  static const id = 'compare_golden_image';

  /// Name of the variable that when set to `true` can be set on a
  /// [TestController] to be able disable the golden images.
  static const kDisableGoldenImageVariable = 'disable_golden_image';

  /// Name of the variable that when set to `true` can be set on a
  /// [TestController] to be able override golden images failure on missing.
  static const kDisableGoldenImageFailOnMissingVariable =
      'disable_golden_image_fail_on_missing';

  static List<String> get behaviorDrivenDescriptions => List.unmodifiable([
        'compare the last image to the saved golden image, `{{failWhenGoldenMissing}}` if a golden image is missing, ensure the images match with less than an `{{allowedDelta}}`% difference, and create {{aAn}} `{{imageOnFail}}` image on failure.',
        'compare the `{{imageId}}` the saved golden image, `{{failWhenGoldenMissing}}` if a golden image is missing, ensure the images match with less than an `{{allowedDelta}}`% difference, and create {{aAn}} `{{imageOnFail}}` image on failure.',
      ]);

  final dynamic allowedDelta;
  final bool? failWhenGoldenMissing;
  final String? imageId;
  final String? imageOnFail;

  @override
  String get stepId => id;

  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  ///   "allowedDelta": <double>,
  ///   "failWhenGoldenMissing": <bool>,
  ///   "imageId": <String>,
  ///   "imageOnFail": <String>
  /// }
  /// ```
  ///
  /// See also:
  /// * [JsonClass.parseDurationFromSeconds]
  /// * [ThemeDecoder.decodeColor]
  static CompareGoldenImageStep fromDynamic(dynamic map) {
    CompareGoldenImageStep result;

    if (map == null) {
      throw Exception('[CompareGoldenImageStep.fromDynamic]: map is null');
    } else {
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
    required CancelToken cancelToken,
    required TestReport report,
    required TestController tester,
  }) async {
    var enabled = JsonClass.parseBool(
          tester.getVariable(kDisableGoldenImageVariable),
        ) !=
        true;

    enabled = enabled &&
        JsonClass.parseBool(
              tester.getVariable(ScreenshotStep.kDisableScreenshotVariable),
            ) !=
            true;

    if (enabled == true) {
      var allowedDelta = JsonClass.parseDouble(
        tester.resolveVariable(this.allowedDelta),
        0.01,
      );
      var imageId = this.imageId;

      try {
        imageId ??= report.images
            .where((image) => image.goldenCompatible == true)
            .last
            .id;
      } catch (e) {
        // no-op
      }
      if (imageId?.isNotEmpty != true) {
        throw Exception('$id: No imageId found');
      }

      var name =
          "$id('$imageId', '$failWhenGoldenMissing', '$imageOnFail', '$allowedDelta')";
      log(
        name,
        tester: tester,
      );

      Uint8List? actual;
      try {
        actual =
            report.images.where((image) => image.id == imageId).first.image;
      } catch (e) {
        // no-op
      }
      if (actual == null) {
        throw Exception('imageId: [$imageId] -- error loading actual image');
      }

      var master = await tester.testImageReader(
        deviceInfo: report.deviceInfo!,
        imageId: imageId!,
        suiteName: report.suiteName,
        testName: report.name!,
        testVersion: report.version,
      );

      if (master == null) {
        var disableFailOnMissing = JsonClass.parseBool(
          tester.getVariable(kDisableGoldenImageFailOnMissingVariable),
        );
        if (failWhenGoldenMissing == true && !disableFailOnMissing) {
          throw Exception('imageId: [$imageId] -- unable to load golden');
        }
      } else {
        var comparitor = GoldenImageComparator();
        var result =
            await comparitor.compareLists(actual, master, allowedDelta);

        if (result.passed != true) {
          var failImages = [];

          switch (imageOnFail) {
            case 'both':
              failImages.add(result.isolated);
              failImages.add(result.masked);
              break;

            case 'isolated':
              failImages.add(result.isolated);
              break;

            default:
              failImages.add(result.masked);
              break;
          }

          for (var failImage in failImages) {
            if (failImage != null) {
              report.attachScreenshot(
                (await failImage.toByteData(format: ImageByteFormat.png))!
                    .buffer
                    .asUint8List(),
                goldenCompatible: false,
                id: 'failed-${imageId}',
              );
            }
          }
          throw Exception('${result.error}');
        }
      }
    }
  }

  @override
  String getBehaviorDrivenDescription(TestController tester) {
    var result = imageId == null
        ? behaviorDrivenDescriptions[0]
        : behaviorDrivenDescriptions[1];

    result = result.replaceAll('{{allowedDelta}}',
        allowedDelta == null ? '0' : allowedDelta!.toString());
    result = result.replaceAll('{{imageId}}', imageId ?? 'null');
    result = result.replaceAll(
      '{{failWhenGoldenMissing}}',
      failWhenGoldenMissing == true ? 'fail' : 'not fail',
    );
    result =
        result.replaceAll('{{aAn}}', imageOnFail == 'isolated' ? 'an' : 'a');
    result = result.replaceAll(
        '{{imageOnFail}}', imageOnFail == 'isolated' ? 'isolated' : 'masked');

    return result;
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
        'allowedDelta': allowedDelta,
        'failWhenGoldenMissing': failWhenGoldenMissing,
        'imageId': imageId,
        'imageOnFail': imageOnFail,
      };
}
