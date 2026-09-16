import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({required this.children, this.back = false, super.key});
  final List<Widget> children;
  final bool back;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(children: [
                            if (back) ...[
                              IconButton(
                                  tooltip: 'Retour',
                                  onPressed: () =>
                                      Navigator.of(context).maybePop(),
                                  icon: const Icon(Icons.arrow_back)),
                              const SizedBox(width: 8),
                            ],
                            const Expanded(
                                child: Text('Yokku Mbey',
                                    style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.leaf))),
                          ]),
                          const SizedBox(height: 32),
                          ...children,
                        ]),
                  ),
                ))),
      );
}
