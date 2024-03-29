import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:automated_testing_framework_plugin_images/automated_testing_framework_plugin_images.dart';
import 'package:flutter/material.dart';
import 'package:form_validation/form_validation.dart';
import 'package:static_translations/static_translations.dart';

class CompareGoldenImageForm extends TestStepForm {
  const CompareGoldenImageForm();

  @override
  bool get supportsMinified => true;

  @override
  TranslationEntry get title =>
      TestImagesTranslations.atf_images_title_compare_golden_image;

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
            TestImagesTranslations.atf_images_help_compare_golden_image,
            minify: minify,
          ),
        buildValuesSection(
          context,
          [
            buildEditText(
              context: context,
              id: 'imageId',
              label: TestStepTranslations.atf_form_image_id,
              values: values!,
            ),
            const SizedBox(height: 16.0),
            buildEditText(
              context: context,
              defaultValue: '0.01',
              id: 'allowedDelta',
              label: TestImagesTranslations.atf_form_allowed_delta,
              validators: [
                RequiredValidator(),
                NumberValidator(),
                MaxNumberValidator(number: 1.0),
                MinNumberValidator(number: 0.0),
              ],
              values: values,
            ),
            const SizedBox(height: 16.0),
            buildDropdown(
              context: context,
              defaultValue: 'true',
              id: 'failWhenGoldenMissing',
              items: [
                'true',
                'false',
              ],
              label:
                  TestImagesTranslations.atf_form_fail_on_missing_golden_image,
              values: values,
            ),
            const SizedBox(height: 16.0),
            buildDropdown(
              context: context,
              defaultValue: 'masked',
              id: 'imageOnFail',
              items: [
                'both',
                'isolated',
                'masked',
              ],
              label: TestImagesTranslations.atf_form_image_on_fail,
              values: values,
            ),
          ],
          minify: minify,
        ),
      ],
    );
  }
}
