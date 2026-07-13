import 'package:flutter/material.dart';

/// Tema centralizado do app — Material 3, semente âmbar/caramelo com
/// superfícies neutras e limpas (estilo apps de delivery modernos).
///
/// Use os tokens de [AppColors] apenas para estados semânticos que o
/// [ColorScheme] não cobre (sucesso, aviso). Para o resto, prefira sempre
/// `Theme.of(context).colorScheme.*` para manter a consistência.
class AppColors {
  AppColors._();

  /// Cor-semente da marca (caramelo tostado). Gera toda a paleta M3.
  static const Color seed = Color(0xFFB5651D);

  /// Estados semânticos (fora do ColorScheme padrão do M3).
  static const Color success = Color(0xFF2E7D32);
  static const Color successContainer = Color(0xFFDCF3DD);
  static const Color warning = Color(0xFFB26A00);
  static const Color warningContainer = Color(0xFFFDECCB);
}

class AppRadii {
  AppRadii._();
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.light,
    ).copyWith(
      // Fundo neutro e claro em vez do creme carregado — visual mais "clean".
      surface: const Color(0xFFFDFCFB),
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF7F5F3),
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      // --- AppBar: superfície clara, sem o marrom pesado ---
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        surfaceTintColor: colorScheme.surfaceTint,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),

      // --- Cards: elevação sutil e cantos consistentes ---
      cardTheme: CardTheme(
        elevation: 0,
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),

      // --- Botões preenchidos (ação primária) ---
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
      ),

      // --- ElevatedButton alinhado ao estilo preenchido (evita brancos lavados) ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
          disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
      ),

      // --- Botões contornados (ação secundária) ---
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: colorScheme.outline),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
      ),

      // --- Campos de formulário: preenchidos, cantos suaves, foco claro ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
      ),

      // --- Chips de filtro ---
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        selectedColor: colorScheme.primaryContainer,
        checkmarkColor: colorScheme.onPrimaryContainer,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
        secondaryLabelStyle: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.6)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),

      // --- Navegação inferior (M3 NavigationBar) ---
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        elevation: 3,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
          );
        }),
      ),

      // --- SnackBar flutuante e arredondado ---
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.sm)),
        insetPadding: const EdgeInsets.all(16),
      ),

      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withOpacity(0.6),
        thickness: 1,
        space: 1,
      ),

      // --- Tipografia com pesos mais expressivos ---
      textTheme: base.textTheme.copyWith(
        headlineSmall: base.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
