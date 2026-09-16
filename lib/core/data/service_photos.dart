import 'dart:typed_data';
import 'package:image/image.dart' as img;

const maxServicePhotos = 3;
const maxServicePhotoBytes = 400000;

String prepareServicePhoto(Uint8List bytes) {
  try {
    return _prepareServicePhoto(bytes);
  } on FormatException {
    rethrow;
  } catch (_) {
    throw const FormatException('Image illisible. Choisissez une autre photo.');
  }
}

String _prepareServicePhoto(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > 12 * 1024 * 1024) {
    throw const FormatException('Choisissez une image de moins de 12 Mo.');
  }
  final decoder = img.findDecoderForData(bytes);
  final info = decoder?.startDecode(bytes);
  if (info == null || info.width * info.height > 24000000) {
    throw const FormatException(
        'Image illisible ou trop grande. Choisissez une autre photo.');
  }
  final decoded = decoder!.decodeFrame(0);
  if (decoded == null) {
    throw const FormatException('Impossible de lire cette image.');
  }
  final oriented = img.bakeOrientation(decoded);
  final resized = oriented.width <= 960 && oriented.height <= 960
      ? oriented
      : img.copyResize(oriented,
          width: oriented.width >= oriented.height ? 960 : null,
          height: oriented.height > oriented.width ? 960 : null);
  // A fresh image strips location/EXIF metadata and flattens transparency.
  final clean =
      img.Image(width: resized.width, height: resized.height, numChannels: 3);
  img.fill(clean, color: img.ColorRgb8(255, 255, 255));
  img.compositeImage(clean, resized);
  final encoded = img.encodeJpg(clean, quality: 72);
  if (encoded.length > maxServicePhotoBytes) {
    throw const FormatException(
        'Cette photo est trop volumineuse. Choisissez une image plus simple.');
  }
  return UriData.fromBytes(encoded, mimeType: 'image/jpeg').toString();
}

void validateServicePhotos(List<String> photos) {
  try {
    _validateServicePhotos(photos);
  } on FormatException {
    rethrow;
  } catch (_) {
    throw const FormatException('Ajoutez une photo valide depuis l’appareil.');
  }
}

void _validateServicePhotos(List<String> photos) {
  if (photos.length > maxServicePhotos) {
    throw const FormatException('Maximum 3 photos par offre.');
  }
  for (final photo in photos) {
    if (photo.length > maxServicePhotoBytes * 1.4) {
      throw const FormatException('Photo trop volumineuse.');
    }
    final uri = UriData.parse(photo);
    final bytes = uri.contentAsBytes();
    final decoder = img.JpegDecoder();
    final info = decoder.startDecode(bytes);
    if (uri.mimeType != 'image/jpeg' ||
        bytes.length > maxServicePhotoBytes ||
        info == null ||
        info.width > 960 ||
        info.height > 960 ||
        decoder.decodeFrame(0) == null) {
      throw const FormatException(
          'Ajoutez une photo valide depuis l’appareil.');
    }
  }
}

Uint8List servicePhotoBytes(String source) =>
    UriData.parse(source).contentAsBytes();
