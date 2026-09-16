import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../data/service_photos.dart';
import 'journey_scaffold.dart';

class ServicePhoto extends StatelessWidget {
  const ServicePhoto(
      {required this.source, this.fit = BoxFit.cover, super.key});
  final String source;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) {
    Widget missing(BuildContext context, Object error, StackTrace? stack) =>
        const Center(
            child: Icon(Icons.broken_image_outlined, color: journeyMuted));
    if (source.startsWith('assets/')) {
      return Image.asset(source, fit: fit, errorBuilder: missing);
    }
    try {
      return Image.memory(servicePhotoBytes(source),
          fit: fit, gaplessPlayback: true, errorBuilder: missing);
    } on FormatException {
      return missing(context, '', null);
    }
  }
}

class ServicePhotoField extends StatefulWidget {
  const ServicePhotoField(
      {required this.photos,
      required this.onChanged,
      this.required = false,
      this.pickPhoto,
      this.onBusyChanged,
      super.key});
  final List<String> photos;
  final ValueChanged<List<String>> onChanged;
  final bool required;
  final Future<XFile?> Function(ImageSource)? pickPhoto;
  final ValueChanged<bool>? onBusyChanged;
  @override
  State<ServicePhotoField> createState() => _ServicePhotoFieldState();
}

class _ServicePhotoFieldState extends State<ServicePhotoField> {
  bool _busy = false;
  String? _error;
  final _picker = ImagePicker();
  final _field = GlobalKey<FormFieldState<List<String>>>();

  @override
  void initState() {
    super.initState();
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        widget.pickPhoto == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _recover());
    }
  }

  Future<void> _recover() async {
    try {
      final response = await _picker.retrieveLostData();
      if (!mounted || response.isEmpty) return;
      if (response.files?.isNotEmpty == true) {
        await _process(() async => response.files!.first);
      } else if (response.exception != null) {
        setState(
            () => _error = 'La prise de photo a été interrompue. Réessayez.');
      }
    } on MissingPluginException {
      // The picker is unavailable in widget tests and unsupported hosts.
    } on PlatformException {
      if (mounted) {
        setState(
            () => _error = 'Impossible de récupérer la photo interrompue.');
      }
    }
  }

  void _change(List<String> photos) {
    widget.onChanged(photos);
    _field.currentState?.didChange(photos);
  }

  Future<void> _add(ImageSource source) => _process(() =>
      widget.pickPhoto?.call(source) ??
      _picker.pickImage(
          source: source,
          maxWidth: 1280,
          maxHeight: 1280,
          imageQuality: 80,
          requestFullMetadata: false));

  Future<void> _process(Future<XFile?> Function() pick) async {
    if (!mounted) return;
    if (_busy || widget.photos.length >= maxServicePhotos) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    widget.onBusyChanged?.call(true);
    try {
      final file = await pick();
      if (file == null) return;
      if (await file.length() > 12 * 1024 * 1024) {
        throw const FormatException('Photo trop volumineuse (maximum 12 Mo).');
      }
      final photo =
          await compute(prepareServicePhoto, await file.readAsBytes());
      if (mounted) _change([...widget.photos, photo]);
    } on FormatException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } on PlatformException {
      if (mounted) {
        setState(() => _error =
            'Accès aux photos indisponible. Vérifiez les autorisations et réessayez.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Impossible d’ajouter cette photo. Essayez une autre image.');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        widget.onBusyChanged?.call(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraAvailable = kIsWeb ||
        [TargetPlatform.android, TargetPlatform.iOS]
            .contains(defaultTargetPlatform);
    return FormField<List<String>>(
      key: _field,
      initialValue: widget.photos,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) => widget.required && (value ?? widget.photos).isEmpty
          ? 'Ajoutez une photo de votre matériel.'
          : null,
      builder: (state) =>
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(
            widget.required
                ? 'Photos du matériel *'
                : 'Photos de votre activité (facultatif)',
            style: const TextStyle(
                color: journeyInk, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        if (widget.photos.isNotEmpty)
          Wrap(spacing: 10, runSpacing: 10, children: [
            for (var i = 0; i < widget.photos.length; i++)
              SizedBox(
                  width: 92,
                  height: 100,
                  child: Stack(children: [
                    Positioned.fill(
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ServicePhoto(source: widget.photos[i]))),
                    Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton.filled(
                            tooltip: 'Supprimer la photo ${i + 1}',
                            icon: const Icon(Icons.close, size: 17),
                            onPressed: _busy
                                ? null
                                : () {
                                    final next = [...widget.photos]
                                      ..removeAt(i);
                                    _change(next);
                                  })),
                  ])),
          ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          if (cameraAvailable)
            OutlinedButton.icon(
                onPressed: _busy || widget.photos.length >= maxServicePhotos
                    ? null
                    : () => _add(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: const Text('Prendre une photo')),
          OutlinedButton.icon(
              onPressed: _busy || widget.photos.length >= maxServicePhotos
                  ? null
                  : () => _add(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text('Choisir une photo')),
        ]),
        if (_busy)
          const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator()),
        const SizedBox(height: 8),
        Text('${widget.photos.length} / $maxServicePhotos photos',
            style: const TextStyle(fontSize: 12, color: journeyMuted)),
        if (_error != null || state.hasError)
          Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error ?? state.errorText!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error))),
      ]),
    );
  }
}
