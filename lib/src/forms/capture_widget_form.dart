import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:automated_testing_framework_plugin_images/automated_testing_framework_plugin_images.dart';
import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:static_translations/static_translations.dart';

class CaptureWidgetForm extends TestStepForm {
  const CaptureWidgetForm();

  @override
  bool get supportsMinified => true;

  @override
  TranslationEntry get title =>
      TestImagesTranslations.atf_images_title_capture_widget;

  @override
  Widget buildForm(
    BuildContext context,
    Map<String, dynamic>? values, {
    bool minify = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (minify != true)
          buildHelpSection(
            context,
            TestImagesTranslations.atf_images_help_capture_widget,
            minify: minify,
          ),
        buildValuesSection(
          context,
          [
            buildEditText(
              context: context,
              id: 'testableId',
              label: TestStepTranslations.atf_form_widget_id,
              validators: [
                RequiredValidator(),
              ],
              values: values!,
            ),
            const SizedBox(height: 16.0),
            buildEditText(
              context: context,
              id: 'imageId',
              label: TestStepTranslations.atf_form_image_id,
              values: values,
            ),
            const SizedBox(height: 16.0),
            buildEditText(
              context: context,
              id: 'backgroundColor',
              label: TestImagesTranslations.atf_form_background_color,
              validators: [ColorValidator()],
              values: values,
            ),
            const SizedBox(height: 16.0),
            buildDropdown(
              context: context,
              defaultValue: 'true',
              id: 'goldenCompatible',
              items: [
                'true',
                'false',
              ],
              label: TestStepTranslations.atf_form_golden_compatible,
              values: values,
            ),
            if (minify != true) ...[
              const SizedBox(height: 16.0),
              buildTimeoutSection(
                context: context,
                values: values,
              ),
            ],
          ],
          minify: minify,
        ),
      ],
    );
  }
}
