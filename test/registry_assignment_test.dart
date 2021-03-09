import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:automated_testing_framework_plugin_images/automated_testing_framework_plugin_images.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('', () {});

  test('capture_widget', () {
    TestImagesHelper.registerTestSteps();
    var availStep = TestStepRegistry.instance.getAvailableTestStep(
      'capture_widget',
    )!;

    expect(availStep.form.runtimeType, CaptureWidgetForm);
    expect(
        availStep.help, TestImagesTranslations.atf_images_help_capture_widget);
    expect(availStep.id, 'capture_widget');
    expect(availStep.title,
        TestImagesTranslations.atf_images_title_capture_widget);
    expect(availStep.type, null);
    expect(availStep.widgetless, false);
  });

  test('obscure_widget', () {
    TestImagesHelper.registerTestSteps();
    var availStep = TestStepRegistry.instance.getAvailableTestStep(
      'obscure_widget',
    )!;

    expect(availStep.form.runtimeType, ObscureWidgetForm);
    expect(
        availStep.help, TestImagesTranslations.atf_images_help_obscure_widget);
    expect(availStep.id, 'obscure_widget');
    expect(availStep.title,
        TestImagesTranslations.atf_images_title_obscure_widget);
    expect(availStep.type, null);
    expect(availStep.widgetless, false);
  });
}
