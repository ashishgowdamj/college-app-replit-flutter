import 'package:flutter/material.dart';
import '../../ui/design_system.dart';

class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget body;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final bool showBack;
  final Widget? floatingActionButton;
  final String? bottomNavCurrentRoute;
  final Widget? bottomNavigationBar;

  const AppScaffold({
    super.key,
    this.title,
    this.leading,
    this.actions,
    required this.body,
    this.bottom,
    this.centerTitle = true,
    this.showBack = false,
    this.floatingActionButton,
    this.bottomNavCurrentRoute,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: title != null
          ? AppBar(
              title: Text(
                title!,
                style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3),
              ),
              centerTitle: centerTitle,
              elevation: Elevations.appBar,
              leading: showBack || (leading == null && canPop)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).maybePop(),
                    )
                  : leading,
              actions: actions,
              bottom: bottom,
            )
          : null,
      body: Container(
        color: AppTokens.bg,
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
