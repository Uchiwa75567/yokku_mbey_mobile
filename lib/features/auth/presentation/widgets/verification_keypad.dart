import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class VerificationKeypad extends StatelessWidget {
  const VerificationKeypad({
    required this.onDigitPressed,
    required this.onBackspacePressed,
    super.key,
  });

  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;

  static const List<List<_KeypadItem>> _rows = [
    [
      _KeypadItem('1'),
      _KeypadItem('2', letters: 'ABC'),
      _KeypadItem('3', letters: 'DEF'),
    ],
    [
      _KeypadItem('4', letters: 'GHI'),
      _KeypadItem('5', letters: 'JKL'),
      _KeypadItem('6', letters: 'MNO'),
    ],
    [
      _KeypadItem('7', letters: 'PQRS'),
      _KeypadItem('8', letters: 'TUV'),
      _KeypadItem('9', letters: 'WXYZ'),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 314,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const buttonHeight = 52.0;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...List.generate(_rows.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: index == 2 ? 0 : 8),
                  child: _KeypadRow(
                    items: _rows[index],
                    height: buttonHeight,
                    onDigitPressed: onDigitPressed,
                  ),
                );
              }),
              const SizedBox(height: 8),
              _BottomKeypadRow(
                height: buttonHeight,
                onDigitPressed: onDigitPressed,
                onBackspacePressed: onBackspacePressed,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _KeypadRow extends StatelessWidget {
  const _KeypadRow({
    required this.items,
    required this.height,
    required this.onDigitPressed,
  });

  final List<_KeypadItem> items;
  final double height;
  final ValueChanged<String> onDigitPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];

          return Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(right: index == items.length - 1 ? 0 : 18),
              child: _KeypadButton(
                item: item,
                onPressed: () => onDigitPressed(item.value),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BottomKeypadRow extends StatelessWidget {
  const _BottomKeypadRow({
    required this.height,
    required this.onDigitPressed,
    required this.onBackspacePressed,
  });

  final double height;
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          const Expanded(child: SizedBox.expand()),
          const SizedBox(width: 18),
          Expanded(
            child: _KeypadButton(
              item: const _KeypadItem('0'),
              onPressed: () => onDigitPressed('0'),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(child: _BackspaceButton(onPressed: onBackspacePressed)),
        ],
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.item,
    required this.onPressed,
  });

  final _KeypadItem item;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      shadowColor: AppColors.forest.withValues(alpha: 0.08),
      borderRadius: const BorderRadius.all(Radius.circular(99)),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(99)),
        overlayColor: WidgetStatePropertyAll(
          AppColors.leaf.withValues(alpha: 0.08),
        ),
        onTap: onPressed,
        child: Semantics(
          button: true,
          label: 'Chiffre ${item.value}',
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.value,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackspaceButton extends StatelessWidget {
  const _BackspaceButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Semantics(
          button: true,
          label: 'Effacer le dernier chiffre',
          child: const Center(
            child: Icon(
              Icons.backspace_outlined,
              color: AppColors.white,
              size: 23,
            ),
          ),
        ),
      ),
    );
  }
}

class _KeypadItem {
  const _KeypadItem(this.value, {this.letters});

  final String value;
  final String? letters;
}
