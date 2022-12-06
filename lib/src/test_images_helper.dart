import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:automated_testing_framework_plugin_images/automated_testing_framework_plugin_images.dart';

class TestImagesHelper {
  /// Registers the test steps to the optional [registry].  If not set, the
  /// default [TestStepRegistry] will be used.
  static void registerTestSteps([TestStepRegistry? registry]) {
    (registry ?? TestStepRegistry.instance).registerCustomSteps([
      TestStepBuilder(
        availableTestStep: const AvailableTestStep(
          form: CaptureWidgetForm(),
          help: TestImagesTranslations.atf_images_help_capture_widget,
          id: 'capture_widget',
          keys: {
            'backgroundColor',
            'goldenCompatible',
            'imageId',
            'testableId',
            'timeout',
          },
          quickAddValues: {'goldenCompatible': true},
          title: TestImagesTranslations.atf_images_title_capture_widget,
          widgetless: false,
          type: null,
        ),
        testRunnerStepBuilder: CaptureWidgetStep.fromDynamic,
      ),
      TestStepBuilder(
        availableTestStep: const AvailableTestStep(
          form: CompareGoldenImageForm(),
          help: TestImagesTranslations.atf_images_help_compare_golden_image,
          id: 'compare_golden_image',
          keys: {
            'allowedDelta',
            'failWhenGoldenMissing',
            'imageId',
            'imageOnFail',
          },
          quickAddValues: {},
          title: TestImagesTranslations.atf_images_title_compare_golden_image,
          widgetless: true,
          type: null,
        ),
        testRunnerStepBuilder: CompareGoldenImageStep.fromDynamic,
      ),
      TestStepBuilder(
        availableTestStep: const AvailableTestStep(
          form: HideWidgetForm(),
          help: TestImagesTranslations.atf_images_help_hide_widget,
          id: 'hide_widget',
          keys: {'opacity', 'testableId', 'timeout'},
          quickAddValues: {'hide': 'true'},
          title: TestImagesTranslations.atf_images_title_hide_widget,
          widgetless: false,
          type: null,
        ),
        testRunnerStepBuilder: HideWidgetStep.fromDynamic,
      ),
      TestStepBuilder(
        availableTestStep: const AvailableTestStep(
          form: ObscureWidgetForm(),
          help: TestImagesTranslations.atf_images_help_obscure_widget,
          id: 'obscure_widget',
          keys: {'color', 'testableId', 'timeout'},
          quickAddValues: {'color': '#FF000000'},
          title: TestImagesTranslations.atf_images_title_obscure_widget,
          widgetless: false,
          type: null,
        ),
        testRunnerStepBuilder: ObscureWidgetStep.fromDynamic,
      ),
    ]);
  }
}
