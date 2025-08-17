import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_tcc/theme/app_tokens.dart';

class ArenaProVibeTheme {
  ThemeData get light => _themeFromSeed(
        seed: const Color(0xFF3C78A1),
        brightness: Brightness.light,
      );

  ThemeData get dark => _themeFromSeed(
        seed: const Color(0xFF78C7FF),
        brightness: Brightness.dark,
      );

  // <<< NOVO: helper para ser usado no AppBar flexibleSpace >>>
  static Widget buildPrimaryAppBarFlexibleSpace(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.6, 1.0],
          colors: [
            cs.primary,
            Color.lerp(cs.primary, cs.tertiary, 0.18)!, // vibração leve
            Color.lerp(cs.primary, cs.primaryContainer, 0.22)!, // base suave
          ],
        ),
      ),
    );
  }

  ThemeData _themeFromSeed({
    required Color seed,
    required Brightness brightness,
  }) {
    final cs = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );

    const radius = 16.0;
    final shape16 = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,

      // <<< NOVO: expose tokens globais (mesmos da Home)
      extensions: const [
        AppTokens(radius: 16, gap: 12, useRail: false),
      ],

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        scrolledUnderElevation: 0, // evita tonalizar ao rolar
        surfaceTintColor: Colors.transparent, // desliga “clareada” do M3
      ),

      // Cards
      cardTheme: CardThemeData(
        color: cs.surfaceContainerHighest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: cs.outlineVariant),
        ),
      ),

      // FAB “Novo pedido”
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.secondary,
        foregroundColor: cs.onSecondary,
        elevation: 0,
        shape: const StadiumBorder(),
      ),

      // Botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: shape16,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cs.secondary,
          foregroundColor: cs.onSecondary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: shape16,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.outline),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: shape16,
        ),
      ),

      // Chips
      chipTheme: ChipThemeData(
        side: BorderSide(color: cs.outlineVariant),
        backgroundColor: brightness == Brightness.dark
            ? cs.surfaceContainerHigh
            : cs.surfaceContainerHighest,
        selectedColor: cs.secondaryContainer,
        secondarySelectedColor: cs.secondaryContainer,
        labelStyle: TextStyle(color: cs.onSurface),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: TextStyle(color: cs.onSurfaceVariant),
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        prefixIconColor: cs.onSurfaceVariant,
        suffixIconColor: cs.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: cs.secondary, width: 1.6),
        ),
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        iconColor: cs.onSurfaceVariant,
        textColor: cs.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // BottomSheet (filtros)
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        ),
        showDragHandle: true,
        dragHandleColor: cs.outlineVariant,
      ),

      // Diálogos
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),

      dividerTheme: DividerThemeData(color: cs.outlineVariant, thickness: 1),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: brightness == Brightness.dark
              ? Colors.black.withOpacity(0.75)
              : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.outlineVariant),
        ),
        textStyle: TextStyle(color: cs.onSurface),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: cs.secondary),

      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),

      // ====== Refinos extras p/ todas as telas ======
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: cs.secondary,
        selectionColor: cs.secondary.withOpacity(0.25),
        selectionHandleColor: cs.secondary,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        contentTextStyle: TextStyle(color: cs.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected) ? cs.secondary : cs.outline,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.all(cs.secondary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
          (s) =>
              s.contains(MaterialState.selected) ? cs.onSecondary : cs.outline,
        ),
        trackColor: MaterialStateProperty.resolveWith(
          (s) => s.contains(MaterialState.selected)
              ? cs.secondary
              : cs.outlineVariant,
        ),
      ),

      tabBarTheme: TabBarThemeData(
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: cs.secondary, width: 2),
        ),
        labelColor: cs.onSurface,
        unselectedLabelColor: cs.onSurfaceVariant,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.secondaryContainer,
        indicatorShape: const StadiumBorder(),
        elevation: 0,
        iconTheme: MaterialStatePropertyAll(
          IconThemeData(color: cs.onSurface),
        ),
        labelTextStyle: MaterialStatePropertyAll(
          TextStyle(color: cs.onSurface),
        ),
      ),

      datePickerTheme: DatePickerThemeData(
        backgroundColor: cs.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: cs.secondaryContainer,
        headerForegroundColor: cs.onSecondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(cs.secondary.withOpacity(0.6)),
        radius: const Radius.circular(12),
        thickness: MaterialStateProperty.all(6),
      ),
    );
  }
}
