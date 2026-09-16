import '../../../../core/widgets/journey_scaffold.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../harvest_detail/presentation/pages/harvest_detail_page.dart';

enum _AvailabilityChoice { now, soon }

enum _DepositChoice { none, optional, required }

enum _PickupChoice { producer, buyerDelivery }

class HarvestPublicationPage extends StatefulWidget {
  const HarvestPublicationPage({super.key});

  static const String routeName = '/publish-harvest';

  @override
  State<HarvestPublicationPage> createState() => _HarvestPublicationPageState();
}

class _HarvestPublicationPageState extends State<HarvestPublicationPage> {
  int _step = 1;
  _AvailabilityChoice _availabilityChoice = _AvailabilityChoice.now;
  _DepositChoice _depositChoice = _DepositChoice.none;
  _PickupChoice _pickupChoice = _PickupChoice.producer;
  bool _allowReservations = true;
  DateTime _startDate = DateTime(2026, 7, 15);
  DateTime _endDate = DateTime(2026, 7, 25);
  final TextEditingController _depositPercentController =
      TextEditingController(text: '20 %');
  final TextEditingController _contactPhoneController =
      TextEditingController(text: '77 000 00 00');

  @override
  void dispose() {
    _depositPercentController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_step == 1) {
      Navigator.of(context).maybePop();
      return;
    }

    setState(() => _step--);
  }

  void _continue() {
    if (_step < 3) {
      setState(() => _step++);
      return;
    }

    Navigator.of(context).pushReplacementNamed(HarvestDetailPage.routeName);
  }

  Future<void> _pickStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2026),
      lastDate: DateTime(2035),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _startDate = selectedDate;
      if (_endDate.isBefore(_startDate)) {
        _endDate = _startDate;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2035),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() => _endDate = selectedDate);
  }

  @override
  Widget build(BuildContext context) =>
      JourneyScaffold(title: 'Publier une récolte', children: [
        Row(children: [
          if (_step > 1)
            IconButton(
                tooltip: 'Étape précédente',
                onPressed: _goBack,
                icon: const Icon(Icons.arrow_back)),
          Expanded(
              child: Text('Étape $_step sur 3',
                  style: const TextStyle(color: journeyMuted))),
        ]),
        LinearProgressIndicator(value: _step / 3, minHeight: 4),
        if (_step == 1)
          _StepOneForm(onContinue: _continue)
        else if (_step == 2)
          _StepTwoForm(
              contactPhoneController: _contactPhoneController,
              onContinue: _continue)
        else
          _StepThreeForm(
              availabilityChoice: _availabilityChoice,
              depositChoice: _depositChoice,
              pickupChoice: _pickupChoice,
              allowReservations: _allowReservations,
              startDate: _startDate,
              endDate: _endDate,
              depositPercentController: _depositPercentController,
              onContinue: _continue,
              onStartDateTap: _pickStartDate,
              onEndDateTap: _pickEndDate,
              onAvailabilityChanged: (v) => setState(() {
                    _availabilityChoice = v;
                    _depositChoice = v == _AvailabilityChoice.soon
                        ? _DepositChoice.required
                        : _DepositChoice.none;
                  }),
              onDepositChanged: (v) => setState(() => _depositChoice = v),
              onPickupChanged: (v) => setState(() => _pickupChoice = v),
              onReservationsChanged: (v) =>
                  setState(() => _allowReservations = v)),
        const JourneyNotice(
            'Aperçu de publication. La diffusion des annonces et les paiements ne sont pas connectés.'),
      ]);
}

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle({
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFE2F2E3),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: const Color(0xFF125B2E), size: 18),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              color: AppColors.mutedInk,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class _MiniSectionHeader extends StatelessWidget {
  const _MiniSectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF24623B), size: 17),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassFormCard extends StatelessWidget {
  const _GlassFormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: child,
    );
  }
}

class _StepOneForm extends StatelessWidget {
  const _StepOneForm({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FormSectionTitle(
          icon: Icons.photo_camera_outlined,
          title: 'Photos du produit',
          trailing: 'Max. 5 images',
        ),
        const SizedBox(height: 11),
        const _PhotoUploadCard(),
        const SizedBox(height: 8),
        const Text(
          "Ajouter jusqu'à 5 photos",
          style: TextStyle(
            color: AppColors.mutedInk,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 17),
        const _PublicationInput(
          label: 'Nom du produit *',
          hint: 'Ex. Tomates rondes biologiques',
          compact: true,
        ),
        const SizedBox(height: 12),
        const _PublicationInput(
          label: 'Catégorie *',
          hint: 'Sélectionnez une catégorie…',
          trailing: Icons.keyboard_arrow_down_rounded,
          compact: true,
        ),
        const SizedBox(height: 12),
        const _PublicationInput(
          label: 'Description',
          hint: "Décrivez la qualité, l'origine ou les particularités…",
          height: 92,
          maxLines: 4,
          alignTop: true,
        ),
        const SizedBox(height: 18),
        _PrimaryButton(label: 'Continuer', onPressed: onContinue),
      ],
    );
  }
}

class _PhotoUploadCard extends StatelessWidget {
  const _PhotoUploadCard();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _PhotoTile(primary: true)),
        SizedBox(width: 10),
        Expanded(child: _PhotoTile()),
        SizedBox(width: 10),
        Expanded(child: _PhotoTile()),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({this.primary = false});

  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: primary ? const Color(0xFFE8F5DF) : const Color(0x99FFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: primary ? const Color(0xFFB9DDB2) : const Color(0x80FFFFFF),
        ),
      ),
      child: Icon(
        primary ? Icons.add_a_photo_outlined : Icons.image_outlined,
        color: primary ? const Color(0xFF184F2A) : const Color(0xFF9EAEA3),
        size: 25,
      ),
    );
  }
}

class _StepTwoForm extends StatelessWidget {
  const _StepTwoForm({
    required this.contactPhoneController,
    required this.onContinue,
  });

  final TextEditingController contactPhoneController;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FormSectionTitle(
          icon: Icons.scale_outlined,
          title: 'Quantité et prix',
        ),
        const SizedBox(height: 12),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _PublicationInput(
                label: 'Quantité disponible *',
                hint: 'Ex. 500',
                compact: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _PublicationInput(
                label: 'Unité de mesure *',
                hint: 'Kilogrammes (kg)',
                trailing: Icons.keyboard_arrow_down_rounded,
                compact: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _PublicationInput(
                label: 'Prix unitaire *',
                hint: 'Ex. 250 FCFA',
                compact: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _PublicationInput(
                label: 'Commande minimale',
                hint: 'Ex. 50 kg',
                compact: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _FormSectionTitle(
          icon: Icons.location_on_outlined,
          title: 'Localisation',
        ),
        const SizedBox(height: 12),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _PublicationInput(
                label: 'Région *',
                hint: 'Sélectionner',
                trailing: Icons.keyboard_arrow_down_rounded,
                compact: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _PublicationInput(
                label: 'Localité précise *',
                hint: 'Ex. Mbour',
                compact: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _PublicationInput(
          key: const ValueKey('harvest-contact-phone'),
          label: 'Numéro de contact *',
          hint: '+221 77 123 45 67',
          controller: contactPhoneController,
          keyboardType: TextInputType.phone,
          compact: true,
        ),
        const SizedBox(height: 7),
        const Text(
          'Ce numéro sera utilisé par les acheteurs pour vous contacter.',
          style: TextStyle(
            color: AppColors.mutedInk,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        _PrimaryButton(label: 'Continuer', onPressed: onContinue),
      ],
    );
  }
}

class _StepThreeForm extends StatelessWidget {
  const _StepThreeForm({
    required this.availabilityChoice,
    required this.depositChoice,
    required this.pickupChoice,
    required this.allowReservations,
    required this.startDate,
    required this.endDate,
    required this.depositPercentController,
    required this.onContinue,
    required this.onStartDateTap,
    required this.onEndDateTap,
    required this.onAvailabilityChanged,
    required this.onDepositChanged,
    required this.onPickupChanged,
    required this.onReservationsChanged,
  });

  final _AvailabilityChoice availabilityChoice;
  final _DepositChoice depositChoice;
  final _PickupChoice pickupChoice;
  final bool allowReservations;
  final DateTime startDate;
  final DateTime endDate;
  final TextEditingController depositPercentController;
  final VoidCallback onContinue;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;
  final ValueChanged<_AvailabilityChoice> onAvailabilityChanged;
  final ValueChanged<_DepositChoice> onDepositChanged;
  final ValueChanged<_PickupChoice> onPickupChanged;
  final ValueChanged<bool> onReservationsChanged;

  bool get _isSoon => availabilityChoice == _AvailabilityChoice.soon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FormSectionTitle(
          icon: Icons.event_available_outlined,
          title: 'Disponibilité',
          trailing: 'Étape finale',
        ),
        const SizedBox(height: 5),
        const Text(
          'Configurez la disponibilité et les modalités de réservation.',
          style: TextStyle(
            color: AppColors.mutedInk,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 11),
        _GlassFormCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _MiniSectionHeader(
                icon: Icons.calendar_today_outlined,
                title: 'Période de disponibilité',
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _SegmentButton(
                      label: 'Disponible maintenant',
                      selected: !_isSoon,
                      height: 40,
                      onTap: () =>
                          onAvailabilityChanged(_AvailabilityChoice.now),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SegmentButton(
                      label: 'Disponible prochainement',
                      selected: _isSoon,
                      height: 40,
                      onTap: () =>
                          onAvailabilityChanged(_AvailabilityChoice.soon),
                    ),
                  ),
                ],
              ),
              if (_isSoon) ...[
                const SizedBox(height: 12),
                const Text(
                  'Période estimée',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: _DateInputField(
                        label: 'DATE DE DÉBUT *',
                        value: _formatDate(startDate),
                        onTap: onStartDateTap,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DateInputField(
                        label: 'DATE DE FIN *',
                        value: _formatDate(endDate),
                        onTap: onEndDateTap,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 11),
        _GlassFormCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: _MiniSectionHeader(
                      icon: Icons.event_note_outlined,
                      title: 'Réservation',
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onReservationsChanged(!allowReservations),
                    child: _SwitchPill(value: allowReservations),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              const Text(
                'Autoriser les pré-réservations',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Les acheteurs pourront réserver avant la récupération.',
                style: TextStyle(
                  color: Color(0xFF5E7266),
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (allowReservations) ...[
                const SizedBox(height: 11),
                const Text(
                  'Acompte requis',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                _DepositSelector(
                  selected: depositChoice,
                  isExpandedLayout: false,
                  onChanged: onDepositChanged,
                ),
                if (depositChoice != _DepositChoice.none) ...[
                  const SizedBox(height: 9),
                  const Text(
                    "Pourcentage d'acompte",
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  _PercentageInput(controller: depositPercentController),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 11),
        _GlassFormCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _MiniSectionHeader(
                icon: Icons.local_shipping_outlined,
                title: 'Mode de récupération',
              ),
              const SizedBox(height: 9),
              _PickupSelector(
                selected: pickupChoice,
                onChanged: onPickupChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        _PrimaryButton(
          label: 'Publier la récolte',
          onPressed: onContinue,
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _SwitchPill extends StatelessWidget {
  const _SwitchPill({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 24,
      decoration: BoxDecoration(
        color: value ? const Color(0xFF007A33) : const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Align(
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _DepositSelector extends StatelessWidget {
  const _DepositSelector({
    required this.selected,
    required this.isExpandedLayout,
    required this.onChanged,
  });

  final _DepositChoice selected;
  final bool isExpandedLayout;
  final ValueChanged<_DepositChoice> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SegmentButton(
            label: 'Aucun',
            selected: selected == _DepositChoice.none,
            height: isExpandedLayout ? 43 : 40,
            onTap: () => onChanged(_DepositChoice.none),
          ),
        ),
        SizedBox(width: isExpandedLayout ? 9 : 14),
        Expanded(
          child: _SegmentButton(
            label: 'Facultatif',
            selected: selected == _DepositChoice.optional,
            height: isExpandedLayout ? 43 : 40,
            onTap: () => onChanged(_DepositChoice.optional),
          ),
        ),
        SizedBox(width: isExpandedLayout ? 9 : 14),
        Expanded(
          child: _SegmentButton(
            label: 'Obligatoire',
            selected: selected == _DepositChoice.required,
            height: isExpandedLayout ? 43 : 40,
            onTap: () => onChanged(_DepositChoice.required),
          ),
        ),
      ],
    );
  }
}

class _PickupSelector extends StatelessWidget {
  const _PickupSelector({
    required this.selected,
    required this.onChanged,
  });

  final _PickupChoice selected;
  final ValueChanged<_PickupChoice> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PickupOption(
          icon: Icons.storefront_outlined,
          label: 'Retrait producteur',
          description: 'L’acheteur récupère la récolte sur votre exploitation.',
          selected: selected == _PickupChoice.producer,
          onTap: () => onChanged(_PickupChoice.producer),
        ),
        const SizedBox(height: 8),
        _PickupOption(
          icon: Icons.local_shipping_outlined,
          label: 'Livraison acheteur',
          description: 'Vous organisez le transport jusqu’au lieu convenu.',
          selected: selected == _PickupChoice.buyerDelivery,
          onTap: () => onChanged(_PickupChoice.buyerDelivery),
        ),
      ],
    );
  }
}

class _PickupOption extends StatelessWidget {
  const _PickupOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE4F1E5) : const Color(0x99FFFFFF),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 59,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  selected ? const Color(0xFF6DA578) : const Color(0x99D7E0D9),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF28623C), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF607468),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected
                    ? const Color(0xFF087C3A)
                    : const Color(0xFF95A69A),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.height,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFEAF6EE) : AppColors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? const Color(0xFF0A7D16) : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? const Color(0xFF075F23) : AppColors.ink,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateInputField extends StatelessWidget {
  const _DateInputField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            key: ValueKey('date-field-$label'),
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 48,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 17),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE8EBF0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFF496254),
                    size: 17,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PercentageInput extends StatelessWidget {
  const _PercentageInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8EBF0)),
      ),
      child: TextField(
        key: const ValueKey('deposit-percent-input'),
        controller: controller,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          isDense: true,
        ),
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.2,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _PublicationInput extends StatelessWidget {
  const _PublicationInput({
    required this.label,
    required this.hint,
    this.trailing,
    this.height = 54,
    this.maxLines = 1,
    this.alignTop = false,
    this.compact = false,
    this.controller,
    this.keyboardType,
    super.key,
  });

  final String label;
  final String hint;
  final IconData? trailing;
  final double height;
  final int maxLines;
  final bool alignTop;
  final bool compact;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: compact ? 52 : height,
          padding: EdgeInsets.fromLTRB(16, alignTop ? 17 : 0, 13, 0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xFFE8EBF0)),
          ),
          child: Row(
            crossAxisAlignment:
                alignTop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: controller == null
                    ? Text(
                        hint,
                        maxLines: maxLines,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF9AA7BA),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    : TextField(
                        controller: controller,
                        keyboardType: keyboardType,
                        decoration: InputDecoration.collapsed(hintText: hint),
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 14,
                        ),
                      ),
              ),
              if (trailing != null)
                Icon(trailing, color: const Color(0xFF69778C), size: 21),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isPublishing = label.startsWith('Publier');
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.leaf,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          icon: Icon(
            isPublishing ? Icons.publish_rounded : Icons.arrow_forward_rounded,
            size: 20,
          ),
          label: Text(label),
        ),
      ),
    );
  }
}
