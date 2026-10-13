import 'package:flutter/material.dart';

/// Semantic colours used outside the [ColorScheme], per brightness.
class AppColors extends ThemeExtension<AppColors> {
  final Color accent;
  final Color success;
  final Color successContainer;
  final Color warning;

  const AppColors({
    required this.accent,
    required this.success,
    required this.successContainer,
    required this.warning,
  });

  static const dark = AppColors(
    accent: Color(0xFF7CACF8),
    success: Color(0xFF4CB58C),
    successContainer: Color(0xFF1F4D3C),
    warning: Color(0xFFE2A84B),
  );

  static const light = AppColors(
    accent: Color(0xFF1F5FD0),
    success: Color(0xFF1E8A5F),
    successContainer: Color(0xFFCDEBDD),
    warning: Color(0xFF9A5B00),
  );

  static AppColors of(BuildContext context) => Theme.of(context).extension<AppColors>()!;

  @override
  AppColors copyWith({Color? accent, Color? success, Color? successContainer, Color? warning}) {
    return AppColors(
      accent: accent ?? this.accent,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

const _seed = Color(0xFF2F6FED);

ThemeData buildDarkTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark).copyWith(
    primary: AppColors.dark.accent,
    onPrimary: const Color(0xFF0A2A5C),
    primaryContainer: const Color(0xFF1B3A6B),
    onPrimaryContainer: const Color(0xFFD9E6FF),
    surface: const Color(0xFF0F1318),
    onSurface: const Color(0xFFE4E8EE),
    onSurfaceVariant: const Color(0xFF9CA6B4),
    surfaceContainerLowest: const Color(0xFF0B0E12),
    surfaceContainerLow: const Color(0xFF151A21),
    surfaceContainer: const Color(0xFF191F27),
    surfaceContainerHigh: const Color(0xFF1F262F),
    surfaceContainerHighest: const Color(0xFF28303B),
    outline: const Color(0xFF5B6675),
    outlineVariant: const Color(0xFF2E3742),
  );
  return _buildTheme(scheme, AppColors.dark, cardColor: scheme.surfaceContainer);
}

ThemeData buildLightTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light).copyWith(
    primary: AppColors.light.accent,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFDCE7FF),
    onPrimaryContainer: const Color(0xFF0B2B63),
    surface: const Color(0xFFF5F7FA),
    onSurface: const Color(0xFF161B22),
    onSurfaceVariant: const Color(0xFF55606E),
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFEEF1F5),
    surfaceContainer: const Color(0xFFE9EDF2),
    surfaceContainerHigh: const Color(0xFFE3E8EE),
    surfaceContainerHighest: const Color(0xFFDCE2EA),
    outline: const Color(0xFF7A8594),
    outlineVariant: const Color(0xFFCDD4DD),
  );
  return _buildTheme(scheme, AppColors.light, cardColor: scheme.surfaceContainerLowest);
}

ThemeData _buildTheme(ColorScheme scheme, AppColors colors, {required Color cardColor}) {
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    fontFamily: 'Roboto',
    extensions: [colors],
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
