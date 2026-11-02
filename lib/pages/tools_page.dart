import 'package:flutter/material.dart';

import '../widgets/side_nav.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 12),
      child: ContentPanel(child: MigratingPlaceholder(title: '工具')),
    );
  }
}
