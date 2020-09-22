import 'package:static_translations/static_translations.dart';

class TestImagesTranslations {
  static const atf_form_background_color = TranslationEntry(
    key: 'atf_form_background_color',
    value: 'Background Color',
  );

  static const atf_form_fail_on_missing_golden_image = TranslationEntry(
    key: 'atf_form_fail_on_missing_golden_image',
    value: 'Fail on missing Golden Image?',
  );

  static const atf_form_hide = TranslationEntry(
    key: 'atf_form_hide',
    value: 'Hide',
  );

  static const atf_form_image_on_fail = TranslationEntry(
    key: 'atf_form_image_on_fail',
    value: 'On Fail Image',
  );

  static const atf_form_obscure_color = TranslationEntry(
    key: 'atf_form_obscure_color',
    value: 'Obscure Color',
  );

  static const atf_images_error_not_color = TranslationEntry(
    key: 'atf_images_error_not_color',
    value: 'Invalid color.  Colors must match: "#aarrggbb".',
  );

  static const atf_images_help_compare_golden_image = TranslationEntry(
    key: 'atf_images_help_compare_golden_image',
    value:
        'Compare the image of a given id in the current test report with a golden image from the same test.',
  );

  static const atf_images_help_capture_widget = TranslationEntry(
    key: 'atf_images_help_capture_widget',
    value: 'Captures the image from a specific widget only.',
  );

  static const atf_images_help_hide_widget = TranslationEntry(
    key: 'atf_images_help_hide_widget',
    value:
        'Hides (or shows) the widget.  Set the opacity to 0 to hide it and 1 to show it.',
  );

  static const atf_images_help_obscure_widget = TranslationEntry(
    key: 'atf_images_help_obscure_widget',
    value:
        'Obscures the widget with the given color.  Set to empty or transparent (#00000000) to un-obscure an already obscured widget.',
  );

  static const atf_images_title_capture_widget = TranslationEntry(
    key: 'atf_images_title_capture_widget',
    value: 'Capture Widget',
  );

  static const atf_images_title_compare_golden_image = TranslationEntry(
    key: 'atf_images_title_compare_golden_image',
    value: 'Compare Golden Image',
  );

  static const atf_images_title_hide_widget = TranslationEntry(
    key: 'atf_images_title_hide_widget',
    value: 'Hide Widget',
  );

  static const atf_images_title_obscure_widget = TranslationEntry(
    key: 'atf_images_title_obscure_widget',
    value: 'Obscure Widget',
  );
}
