import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter/material.dart';
import 'package:json_class/json_class.dart';
import 'package:json_theme/json_theme.dart';
import 'package:meta/meta.dart';

/// Obscures / un-obscures a widget with an overlay of a specified [color].  If
/// the [color] is [null] or [Colors.transparent] then the widget will
/// un-obscure.
class ObscureWidgetStep extends TestRunnerStep {
  ObscureWidgetStep({
    this.color,
    @required this.testableId,
    this.timeout,
  }) : assert(testableId?.isNotEmpty == true);

  /// The color to use to obscure the widget.  Will be [Colors.transparent] if
  /// not set.
  final Color color;

  /// The id of the [Testable] widget to interact with.
  final String testableId;

  /// The maximum amount of time this step will wait while searching for the
  /// [Testable] on the widget tree.
  final Duration timeout;

  /// Creates an instance from a JSON-like map structure.  This expects the
  /// following format:
  ///
  /// ```json
  /// {
  ///   "color": <String>,
  ///   "testableId": <String>,
  ///   "timeout": <number>
  /// }
  /// ```
  ///
  /// See also:
  /// * [JsonClass.parseDurationFromSeconds]
  /// * [ThemeDecoder.decodeColor]
  static ObscureWidgetStep fromDynamic(dynamic map) {
    ObscureWidgetStep result;

    if (map != null) {
      result = ObscureWidgetStep(
        color: ThemeDecoder.decodeColor(map['color']),
        testableId: map['testableId'],
        timeout: JsonClass.parseDurationFromSeconds(map['timeout']),
      );
    }

    return result;
  }

  /// Executes the step.  This will first look for the [Testable] then instruct
  /// the widget to obscure itself using the given [color].  If [color] is null
  /// or set to [Colors.transparent] then this effectively un-obscures the
  /// widget.
  @override
  Future<void> execute({
    @required TestReport report,
    @required TestController tester,
  }) async {
    String testableId = tester.resolveVariable(this.testableId);
    assert(testableId?.isNotEmpty == true);

    var name = "obscure_widget('$testableId')";
    log(
      name,
      tester: tester,
    );
    var finder = await waitFor(
      testableId,
      tester: tester,
      timeout: timeout,
    );

    await sleep(
      tester.delays.postFoundWidget,
      tester: tester,
    );

    var widgetFinder = finder.evaluate();
    var found = false;
    if (widgetFinder?.isNotEmpty == true) {
      StatefulElement element = widgetFinder.first;

      var state = element.state;
      if (state is TestableState) {
        try {
          await state.obscure(color);
          found = true;
        } catch (e) {
          found = false;
        }
      }
    }
    if (found != true) {
      throw Exception(
        'testableId: [$testableId] -- could not locate Testable with a functional [obscure] method.',
      );
    }
  }

  /// Converts this to a JSON compatible map.  For a description of the format,
  /// see [fromDynamic].
  @override
  Map<String, dynamic> toJson() => {
        'color': ThemeEncoder.encodeColor(color),
        'testableId': testableId,
        'timeout': timeout?.inSeconds,
      };
}