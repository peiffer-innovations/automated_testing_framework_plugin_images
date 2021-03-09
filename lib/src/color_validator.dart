import 'package:automated_testing_framework_plugin_images/automated_testing_framework_plugin_images.dart';
import 'package:form_validation/form_validation.dart';
import 'package:static_translations/static_translations.dart';

class ColorValidator extends ValueValidator {
  @override
  Map<String, dynamic> toJson() => {};

  @override
  String? validate({
    String? label,
    Translator? translator,
    String? value,
  }) {
    var valid = true;

    if (value?.isNotEmpty == true) {
      var colorRegex = r'^#[A-Fa-f0-9]{8}';

      var regex = RegExp(colorRegex);
      valid = regex.hasMatch(value!);
    }

    return valid == true
        ? null
        : translator!
            .translate(TestImagesTranslations.atf_images_error_not_color);
  }
}
