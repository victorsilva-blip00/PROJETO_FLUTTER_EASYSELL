import 'package:flutter/material.dart';

import 'tema.dart';

class FundoLateral extends StatelessWidget {
  final Widget child;

  const FundoLateral({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: context.cores.fundo, child: child);
  }
}
