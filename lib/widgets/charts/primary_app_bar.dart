// lib/widgets/primary_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PrimaryAppBar(
      {super.key, required this.title, this.actions, this.bottom});

  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final overlay = (cs.primary.computeLuminance() > 0.5)
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;

    return AppBar(
      title: Text(title),
      centerTitle: theme.appBarTheme.centerTitle ?? true,
      backgroundColor: Colors.transparent,
      foregroundColor: cs.onPrimary,
      elevation: theme.appBarTheme.elevation ?? 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: overlay,
      actions: actions,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.6, 1.0],
            colors: [
              cs.primary,
              Color.lerp(cs.primary, cs.tertiary, 0.18)!,
              Color.lerp(cs.primary, cs.primaryContainer, 0.22)!,
            ],
          ),
        ),
      ),
      bottom: bottom ??
          PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: (theme.colorScheme.outlineVariant),
            ),
          ),
      toolbarHeight: theme.appBarTheme.toolbarHeight ?? kToolbarHeight,
      titleTextStyle: theme.appBarTheme.titleTextStyle ??
          theme.textTheme.titleLarge?.copyWith(
            color: cs.onPrimary,
            fontWeight: FontWeight.w700,
          ),
      iconTheme:
          theme.appBarTheme.iconTheme ?? IconThemeData(color: cs.onPrimary),
      actionsIconTheme: theme.appBarTheme.actionsIconTheme,
      shape: theme.appBarTheme.shape,
    );
  }
}
