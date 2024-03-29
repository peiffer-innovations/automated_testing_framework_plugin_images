import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';

/// Hides / un-hides a widget by setting the opacity.
class HideWidgetStep extends TestRunnerStep {
  HideWidgetStep({
    this.hide,
    required this.testableId,
    this.timeout,
  }) : assert(testableId.isNotEmpty == true);

  static const id = 'hide_widget';

  static List<String> get behaviorDrivenDescriptions => List.unmodifiable([
        '`{{hide}}` the `{{testableId}}` widget.',
        '`{{hide}}` the `{{testableId}}` widget, and fail if the widget cannot be found within `{{timeout}}` seconds.',
      ]);

  /// Set to [true] to hide the widget and [false] to show it.
  final bool? hide;

  /// The id of the [Testable] widget to interact with.
  final String testableId;

  /// The maximum amount of time this step will wait while searching for the
  /// [Testable] on the widget tree.
  final Duration? timeout;

  @override
  String get stepId => id;

  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  ///   "hide": <bool>,
  ///   "testableId": <String>,
  ///   "timeout": <number>
  /// }
  /// ```
  ///
  /// See also:
  /// * [JsonClass.parseDurationFromSeconds]
  static HideWidgetStep fromDynamic(dynamic map) {
    HideWidgetStep result;

    if (map == null) {
      throw Exception('[HideWidgetStep.fromDynamic]: map is null');
    } else {
      result = HideWidgetStep(
        hide: map['hide'] == null ? true : JsonClass.parseBool(map['hide']),
        testableId: map['testableId'],
        timeout: JsonClass.parseDurationFromSeconds(map['timeout']),
      );
    }

    return result;
  }

  /// Executes the step.  This will first look for the [Testable] then attempt
  /// to set the opacity on the widget.
  @override
  Future<void> execute({
    required CancelToken cancelToken,
    required TestReport report,
    required TestController tester,
  }) async {
    final testableId = tester.resolveVariable(this.testableId);
    assert(testableId?.isNotEmpty == true);

    final name = "$id('$testableId', '$hide)";
    log(
      name,
      tester: tester,
    );
    final finder = await waitFor(
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

    final widgetFinder = finder.evaluate();
    var found = false;
    if (widgetFinder.isNotEmpty == true) {
      final element = widgetFinder.first as StatefulElement;

      final state = element.state;
      if (state is TestableState) {
        try {
          await state.opacity(hide == true ? 0.0 : 1.0);
          found = true;
        } catch (e) {
          found = false;
        }
      }
    }
    if (found != true) {
      throw Exception(
        'testableId: [$testableId] -- could not locate Testable with a functional [opacity] method.',
      );
    }
  }

  @override
  String getBehaviorDrivenDescription(TestController tester) {
    var result = timeout == null
        ? behaviorDrivenDescriptions[0]
        : behaviorDrivenDescriptions[1];

    result = result.replaceAll('{{hide}}', hide == false ? 'show' : 'hide');
    result = result.replaceAll('{{testableId}}', testableId);
    result = result.replaceAll(
        '{{timeout}}', timeout?.inSeconds.toString() ?? 'null');

    return result;
  }

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'hide': hide,
        'testableId': testableId,
        'timeout': timeout?.inSeconds,
      };
}
