import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

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

  @override
  void dispose() {
    _depositPercentController.dispose();
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

    Navigator.of(context).maybePop();
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
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.center,
            child: SizedBox(
              width: 440,
              height: 956,
              child: _HarvestPublicationCanvas(
                step: _step,
                availabilityChoice: _availabilityChoice,
                depositChoice: _depositChoice,
                pickupChoice: _pickupChoice,
                allowReservations: _allowReservations,
                startDate: _startDate,
                endDate: _endDate,
                depositPercentController: _depositPercentController,
                onBack: _goBack,
                onContinue: _continue,
                onStartDateTap: _pickStartDate,
                onEndDateTap: _pickEndDate,
                onAvailabilityChanged: (choice) {
                  setState(() {
                    _availabilityChoice = choice;
                    _depositChoice = choice == _AvailabilityChoice.soon
                        ? _DepositChoice.required
                        : _DepositChoice.none;
                  });
                },
                onDepositChanged: (choice) {
                  setState(() => _depositChoice = choice);
                },
                onPickupChanged: (choice) {
                  setState(() => _pickupChoice = choice);
                },
                onReservationsChanged: (value) {
                  setState(() => _allowReservations = value);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HarvestPublicationCanvas extends StatelessWidget {
  const _HarvestPublicationCanvas({
    required this.step,
    required this.availabilityChoice,
    required this.depositChoice,
    required this.pickupChoice,
    required this.allowReservations,
    required this.startDate,
    required this.endDate,
    required this.depositPercentController,
    required this.onBack,
    required this.onContinue,
    required this.onStartDateTap,
    required this.onEndDateTap,
    required this.onAvailabilityChanged,
    required this.onDepositChanged,
    required this.onPickupChanged,
    required this.onReservationsChanged,
  });

  final int step;
  final _AvailabilityChoice availabilityChoice;
  final _DepositChoice depositChoice;
  final _PickupChoice pickupChoice;
  final bool allowReservations;
  final DateTime startDate;
  final DateTime endDate;
  final TextEditingController depositPercentController;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;
  final ValueChanged<_AvailabilityChoice> onAvailabilityChanged;
  final ValueChanged<_DepositChoice> onDepositChanged;
  final ValueChanged<_PickupChoice> onPickupChanged;
  final ValueChanged<bool> onReservationsChanged;

  @override
  Widget build(BuildContext context) {
    final body = switch (step) {
      1 => _StepOneForm(onContinue: onContinue),
      2 => _StepTwoForm(onContinue: onContinue),
      _ => _StepThreeForm(
          availabilityChoice: availabilityChoice,
          depositChoice: depositChoice,
          pickupChoice: pickupChoice,
          allowReservations: allowReservations,
          startDate: startDate,
          endDate: endDate,
          depositPercentController: depositPercentController,
          onContinue: onContinue,
          onStartDateTap: onStartDateTap,
          onEndDateTap: onEndDateTap,
          onAvailabilityChanged: onAvailabilityChanged,
          onDepositChanged: onDepositChanged,
          onPickupChanged: onPickupChanged,
          onReservationsChanged: onReservationsChanged,
        ),
    };

    return ColoredBox(
      color: AppColors.white,
      child: Stack(
        children: [
          Positioned(
            left: 29,
            right: 16,
            top: step == 3 ? 70 : 113,
            child: _PublicationHeader(
              title: step == 3 ? 'Disponibilité' : 'Publier une récolte',
              step: step,
              onBack: onBack,
            ),
          ),
          body,
          const _PublicationBottomNavigation(),
        ],
      ),
    );
  }
}

class _PublicationHeader extends StatelessWidget {
  const _PublicationHeader({
    required this.title,
    required this.step,
    required this.onBack,
  });

  final String title;
  final int step;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BackButton(onPressed: onBack),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.04,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Étape $step sur 3',
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 40,
      child: Material(
        color: const Color(0xFF9AC99C),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: const Icon(
            Icons.chevron_left,
            color: AppColors.white,
            size: 34,
          ),
        ),
      ),
    );
  }
}

class _StepOneForm extends StatelessWidget {
  const _StepOneForm({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          const Positioned(
            left: 29,
            right: 16,
            top: 210,
            child: _PhotoUploadCard(),
          ),
          const Positioned(
            left: 36,
            right: 53,
            top: 380,
            child: _PublicationInput(
              label: 'Nom du produit *',
              hint: 'Ex. Tomate fraîche',
            ),
          ),
          const Positioned(
            left: 36,
            right: 53,
            top: 483,
            child: _PublicationInput(
              label: 'Catégorie *',
              hint: 'Sélectionner une catégorie',
              trailing: Icons.keyboard_arrow_down,
            ),
          ),
          const Positioned(
            left: 36,
            right: 53,
            top: 583,
            child: _PublicationInput(
              label: 'Description',
              hint: 'Décrivez la qualité, la variété...',
              height: 127,
              maxLines: 4,
              alignTop: true,
            ),
          ),
          Positioned(
            left: 52,
            right: 63,
            top: 787,
            child: _PrimaryButton(label: 'Continuer', onPressed: onContinue),
          ),
        ],
      ),
    );
  }
}

class _PhotoUploadCard extends StatelessWidget {
  const _PhotoUploadCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      padding: const EdgeInsets.fromLTRB(24, 30, 22, 26),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F7EF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          SizedBox.square(
            dimension: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFD4F5E2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, color: Color(0xFF007A33), size: 28),
            ),
          ),
          SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ajouter jusqu'à 5 photos",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF007A33),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Photo claire du produit',
                  style: TextStyle(
                    color: Color(0xFF7A8698),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTwoForm extends StatelessWidget {
  const _StepTwoForm({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          const Positioned(
            left: 27,
            right: 24,
            top: 229,
            child: Text(
              'Quantité et prix',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
          const Positioned(
            left: 24,
            right: 20,
            top: 277,
            child: Row(
              children: [
                Expanded(
                  child: _PublicationInput(
                    label: 'Quantité *',
                    hint: '500',
                    compact: true,
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  child: _PublicationInput(
                    label: 'Unité *',
                    hint: 'Kilogramme (kg)',
                    compact: true,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 24,
            right: 20,
            top: 371,
            child: Row(
              children: [
                Expanded(
                  child: _PublicationInput(
                    label: 'Prix par unité *',
                    hint: '400 FCFA',
                    compact: true,
                  ),
                ),
                SizedBox(width: 24),
                Expanded(
                  child: _PublicationInput(
                    label: 'Commande minimale',
                    hint: '50 kg',
                    compact: true,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 27,
            right: 24,
            top: 476,
            child: Text(
              'Localisation',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
          const Positioned(
            left: 28,
            right: 63,
            top: 524,
            child: _PublicationInput(label: 'Région *', hint: 'Kaolack'),
          ),
          const Positioned(
            left: 28,
            right: 63,
            top: 615,
            child: _PublicationInput(label: 'Localité *', hint: 'Nioro du Rip'),
          ),
          Positioned(
            left: 52,
            right: 63,
            top: 787,
            child: _PrimaryButton(label: 'Continuer', onPressed: onContinue),
          ),
        ],
      ),
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
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            left: _isSoon ? 39 : 44,
            right: _isSoon ? 39 : 44,
            top: 160,
            child: const Text(
              'Quand la récolte sera-t-elle disponible\n?',
              style: TextStyle(
                color: Color(0xFF071A0F),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.25,
                letterSpacing: 0,
              ),
            ),
          ),
          Positioned(
            left: _isSoon ? 39 : 44,
            right: _isSoon ? 51 : 46,
            top: 221,
            child: _AvailabilityCard(
              title: 'Disponible maintenant',
              subtitle: 'Le produit est déjà prêt à être vendu.',
              selected: availabilityChoice == _AvailabilityChoice.now,
              selectedColor: const Color(0xFF0A7D16),
              selectedBackground: const Color(0xFFF0FAF3),
              onTap: () => onAvailabilityChanged(_AvailabilityChoice.now),
            ),
          ),
          Positioned(
            left: _isSoon ? 39 : 44,
            right: _isSoon ? 51 : 46,
            top: 308,
            child: _AvailabilityCard(
              title: 'Disponible prochainement',
              subtitle: 'La récolte sera disponible plus tard.',
              selected: availabilityChoice == _AvailabilityChoice.soon,
              selectedColor: const Color(0xFFFF7A2B),
              selectedBackground: const Color(0xFFFFF4EA),
              onTap: () => onAvailabilityChanged(_AvailabilityChoice.soon),
            ),
          ),
          if (_isSoon) ...[
            const Positioned(
              left: 39,
              right: 51,
              top: 402,
              child: Text(
                'Période estimée',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
            Positioned(
              left: 39,
              right: 51,
              top: 441,
              child: Row(
                children: [
                  Expanded(
                    child: _DateInputField(
                      label: 'DATE DE DÉBUT *',
                      value: _formatDate(startDate),
                      onTap: onStartDateTap,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DateInputField(
                      label: 'DATE DE FIN *',
                      value: _formatDate(endDate),
                      onTap: onEndDateTap,
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              left: 39,
              right: 51,
              top: 522,
              child: Text(
                'Cette période est estimative et modifiable.',
                style: TextStyle(
                  color: Color(0xFFA5B1C2),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
          if (_isSoon)
            Positioned(
              left: 39,
              right: 51,
              top: 549,
              child: _ReservationToggle(
                value: allowReservations,
                onChanged: onReservationsChanged,
              ),
            )
          else
            Positioned(
              left: 44,
              right: 46,
              top: 416,
              child: _CompactReservationToggle(
                value: allowReservations,
                onChanged: onReservationsChanged,
              ),
            ),
          Positioned(
            left: _isSoon ? 39 : 44,
            right: _isSoon ? 51 : 46,
            top: _isSoon ? 612 : 533,
            child: const Text(
              'Acompte',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
          Positioned(
            left: _isSoon ? 31 : 44,
            right: _isSoon ? 59 : 46,
            top: _isSoon ? 649 : 557,
            child: _DepositSelector(
              selected: depositChoice,
              isExpandedLayout: _isSoon,
              onChanged: onDepositChanged,
            ),
          ),
          if (_isSoon) ...[
            const Positioned(
              left: 31,
              right: 59,
              top: 716,
              child: Text(
                "Pourcentage d'acompte",
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
            Positioned(
              left: 31,
              right: 59,
              top: 737,
              child: _PercentageInput(controller: depositPercentController),
            ),
          ] else ...[
            const Positioned(
              left: 44,
              right: 46,
              top: 621,
              child: Text(
                'Mode de récupération',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
            Positioned(
              left: 44,
              right: 46,
              top: 644,
              child: _PickupSelector(
                  selected: pickupChoice, onChanged: onPickupChanged),
            ),
          ],
          Positioned(
            left: _isSoon ? 48 : 52,
            right: _isSoon ? 67 : 63,
            top: _isSoon ? 794 : 800,
            child: _PrimaryButton(
              label: 'Publier la récolte',
              onPressed: onContinue,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.selectedColor,
    required this.selectedBackground,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final Color selectedColor;
  final Color selectedBackground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? selectedBackground : AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 73,
          padding: const EdgeInsets.fromLTRB(14, 9, 15, 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? selectedColor : const Color(0xFFE8EBF0),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              _RadioDot(color: selectedColor, selected: selected),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8190A6),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        height: 1,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.color, required this.selected});

  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: selected ? color : const Color(0xFF9AA7BA)),
        color: selected ? color : AppColors.white,
      ),
      child: selected
          ? const Center(
              child: SizedBox.square(
                dimension: 7,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _CompactReservationToggle extends StatelessWidget {
  const _CompactReservationToggle({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Réservation',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () => onChanged(!value),
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(17, 0, 15, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Autoriser les réservations',
                        style: TextStyle(
                          color: AppColors.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    Icon(
                      value ? Icons.check_circle : Icons.circle_outlined,
                      color: value
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF95A2B5),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReservationToggle extends StatelessWidget {
  const _ReservationToggle({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF7F8FA),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 58,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(17, 0, 16, 0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Autoriser les pré-réservations',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                _SwitchPill(value: value),
              ],
            ),
          ),
        ),
      ),
    );
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
    return Row(
      children: [
        SizedBox(
          width: 188,
          child: _SegmentButton(
            label: 'Retrait producteur',
            selected: selected == _PickupChoice.producer,
            height: 42,
            onTap: () => onChanged(_PickupChoice.producer),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SegmentButton(
            label: 'Livraison acheteur',
            selected: selected == _PickupChoice.buyerDelivery,
            height: 42,
            onTap: () => onChanged(_PickupChoice.buyerDelivery),
          ),
        ),
      ],
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
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
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
  });

  final String label;
  final String hint;
  final IconData? trailing;
  final double height;
  final int maxLines;
  final bool alignTop;
  final bool compact;

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
                child: Text(
                  hint,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF9AA7BA),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
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
    return SizedBox(
      height: 59,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF007A00),
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _PublicationBottomNavigation extends StatelessWidget {
  const _PublicationBottomNavigation();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SizedBox(
        height: 63,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: Color(0xFFE8EBF0))),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _PublicationNavItem(
                    icon: Icons.home,
                    label: 'Accueil',
                    isActive: true,
                  ),
                  _PublicationNavItem(
                    icon: Icons.search,
                    label: 'Recherche',
                  ),
                  SizedBox(width: 66),
                  _PublicationNavItem(
                    icon: Icons.chat_bubble_outline,
                    label: 'Réservations',
                  ),
                  _PublicationNavItem(
                    icon: Icons.person_outline,
                    label: 'Profil',
                  ),
                ],
              ),
              Positioned(
                left: 184,
                top: -22,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF49B653),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF49B653).withValues(alpha: 0.24),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child:
                      const Icon(Icons.add, color: AppColors.white, size: 33),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PublicationNavItem extends StatelessWidget {
  const _PublicationNavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF49B653) : const Color(0xFF98A3B3);

    return SizedBox(
      width: 80,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
