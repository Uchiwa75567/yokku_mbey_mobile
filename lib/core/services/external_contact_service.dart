import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

abstract final class ExternalContactService {
  static Future<void> showContactOptions(
    BuildContext context, {
    required String phoneNumber,
    required String contactName,
    String? message,
  }) async {
    final normalizedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final whatsappPhone = normalizedPhone.replaceFirst('+', '');
    final whatsappMessage = Uri.encodeComponent(
      message ?? 'Bonjour $contactName, je vous contacte depuis YOKKU MBEY.',
    );

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contacter $contactName',
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(phoneNumber),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.call_outlined),
                ),
                title: const Text('Appeler'),
                subtitle: const Text('Ouvrir l’application Téléphone'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _launch(
                    context,
                    Uri(scheme: 'tel', path: normalizedPhone),
                  );
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE7F8EE),
                  child: Icon(
                    Icons.chat_outlined,
                    color: Color(0xFF087C3A),
                  ),
                ),
                title: const Text('WhatsApp'),
                subtitle: const Text('Continuer hors de YOKKU MBEY'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _launch(
                    context,
                    Uri.parse(
                      'https://wa.me/$whatsappPhone?text=$whatsappMessage',
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _launch(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune application compatible n’est disponible.'),
        ),
      );
    }
  }
}
