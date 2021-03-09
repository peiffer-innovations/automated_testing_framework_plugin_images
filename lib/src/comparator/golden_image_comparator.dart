// The majority of the code in this class was copied from the _goldens_io.dart
// file within the flutter_test package.

import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

class GoldenImageComparator {
  Future<ComparisonResult> compareLists(
    List<int>? test,
    List<int>? master,
    double? allowedDelta,
  ) async {
    if (identical(test, master)) return ComparisonResult(passed: true);

    if (test == null || master == null || test.isEmpty || master.isEmpty) {
      return ComparisonResult(
        passed: false,
        error: 'Pixel test failed, null image provided.',
      );
    }

    final testImageCodec =
        await instantiateImageCodec(Uint8List.fromList(test));
    final testImage = (await testImageCodec.getNextFrame()).image;
    final testImageRgba = await testImage.toByteData();

    final masterImageCodec =
        await instantiateImageCodec(Uint8List.fromList(master));
    final masterImage = (await masterImageCodec.getNextFrame()).image;
    final masterImageRgba = await masterImage.toByteData();

    final width = testImage.width;
    final height = testImage.height;

    if (width != masterImage.width || height != masterImage.height) {
      return ComparisonResult(
        passed: false,
        error: 'Pixel test failed, image sizes do not match.\n'
            'Master Image: ${masterImage.width} X ${masterImage.height}\n'
            'Test Image: ${testImage.width} X ${testImage.height}',
      );
    }

    var pixelDiffCount = 0;
    final totalPixels = width * height;
    final invertedMasterRgba = _invert(masterImageRgba!);
    final invertedTestRgba = _invert(testImageRgba!);

    final maskedDiffRgba = await testImage.toByteData();
    final isolatedDiffRgba = ByteData(width * height * 4);

    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        final byteOffset = (width * y + x) * 4;
        final testPixel = testImageRgba.getUint32(byteOffset);
        final masterPixel = masterImageRgba.getUint32(byteOffset);

        final diffPixel = (_readRed(testPixel) - _readRed(masterPixel)).abs() +
            (_readGreen(testPixel) - _readGreen(masterPixel)).abs() +
            (_readBlue(testPixel) - _readBlue(masterPixel)).abs() +
            (_readAlpha(testPixel) - _readAlpha(masterPixel)).abs();

        if (diffPixel != 0) {
          final invertedMasterPixel = invertedMasterRgba.getUint32(byteOffset);
          final invertedTestPixel = invertedTestRgba.getUint32(byteOffset);
          // We grab the max of the 0xAABBGGRR encoded bytes, and then convert
          // back to 0xRRGGBBAA for the actual pixel value, since this is how it
          // was historically done.
          final maskPixel = _toRGBA(math.max(
            _toABGR(invertedMasterPixel),
            _toABGR(invertedTestPixel),
          ));
          maskedDiffRgba!.setUint32(byteOffset, maskPixel);
          isolatedDiffRgba.setUint32(byteOffset, maskPixel);
          pixelDiffCount++;
        }
      }
    }

    var delta = pixelDiffCount / totalPixels;

    if (delta > allowedDelta!) {
      return ComparisonResult(
        passed: false,
        error: 'Pixel test failed, '
            '${((pixelDiffCount / totalPixels) * 100).toStringAsFixed(2)}% '
            'diff detected.',
        isolated: await _createImage(isolatedDiffRgba, width, height),
        masked: await _createImage(maskedDiffRgba!, width, height),
      );
    }
    return ComparisonResult(passed: true);
  }

  /// Inverts [imageBytes], returning a new [ByteData] object.
  ByteData _invert(ByteData imageBytes) {
    final bytes = ByteData(imageBytes.lengthInBytes);
    // Invert the RGB data (but not A).
    for (var i = 0; i < imageBytes.lengthInBytes; i += 4) {
      bytes.setUint8(i, 255 - imageBytes.getUint8(i));
      bytes.setUint8(i + 1, 255 - imageBytes.getUint8(i + 1));
      bytes.setUint8(i + 2, 255 - imageBytes.getUint8(i + 2));
      bytes.setUint8(i + 3, imageBytes.getUint8(i + 3));
    }
    return bytes;
  }

  /// Reads the red value out of a 32 bit rgba pixel.
  int _readRed(int pixel) => (pixel >> 24) & 0xff;

  /// Reads the green value out of a 32 bit rgba pixel.
  int _readGreen(int pixel) => (pixel >> 16) & 0xff;

  /// Reads the blue value out of a 32 bit rgba pixel.
  int _readBlue(int pixel) => (pixel >> 8) & 0xff;

  /// Reads the alpha value out of a 32 bit rgba pixel.
  int _readAlpha(int pixel) => pixel & 0xff;

  /// Convenience wrapper around [decodeImageFromPixels].
  Future<Image> _createImage(ByteData bytes, int width, int height) {
    final completer = Completer<Image>();
    decodeImageFromPixels(
      bytes.buffer.asUint8List(),
      width,
      height,
      PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

// Converts a 32 bit rgba pixel to a 32 bit abgr pixel
  int _toABGR(int rgba) =>
      (_readAlpha(rgba) << 24) |
      (_readBlue(rgba) << 16) |
      (_readGreen(rgba) << 8) |
      _readRed(rgba);

// Converts a 32 bit abgr pixel to a 32 bit rgba pixel
  int _toRGBA(int abgr) =>
      // This is just a mirror of the other conversion.
      _toABGR(abgr);
}

/// The result of a pixel comparison test.
///
/// The [ComparisonResult] will always indicate if a test has [passed]. The
/// optional [error] and [diffs] parameters provide further information about
/// the result of a failing test.
class ComparisonResult {
  /// Creates a new [ComparisonResult] for the current test.
  ComparisonResult({
    this.error,
    this.isolated,
    this.masked,
    required this.passed,
  });

  /// Error message used to describe the cause of the pixel comparison failure.
  final String? error;

  final Image? isolated;
  final Image? masked;

  /// Indicates whether or not a pixel comparison test has failed.
  ///
  /// This value cannot be null.
  final bool passed;
}
