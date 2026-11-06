import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// Pixel World 的绿色主题。绿色只是品牌色，不再受 PCL 主题蓝的限制。
const Color themeSeed = Color(0xFF2F6B4F);

/// 主色保留原色的饱和度；第二、第三色和中性色都用同一色相，
/// 避免 MD3 默认把第三色偏移成别的色系。错误色仍是红色。
DynamicScheme _greenScheme(bool dark) {
  final source = Hct.fromInt(themeSeed.toARGB32());
  final hue = source.hue;
  final chroma = source.chroma;
  return DynamicScheme(
    sourceColorHct: source,
    variant: Variant.fidelity,
    isDark: dark,
    primaryPalette: TonalPalette.fromHct(source),
    secondaryPalette: TonalPalette.of(hue, _max(chroma - 32, chroma * 0.5)),
    tertiaryPalette: TonalPalette.of(hue, _max(chroma - 16, chroma * 0.7)),
    neutralPalette: TonalPalette.of(hue, chroma / 8),
    neutralVariantPalette: TonalPalette.of(hue, chroma / 8 + 4),
  );
}

double _max(double a, double b) => a > b ? a : b;

ColorScheme greenColorScheme(Brightness brightness) {
  final s = _greenScheme(brightness == Brightness.dark);
  Color c(DynamicColor d) => Color(d.getArgb(s));
  final scheme = ColorScheme(
    brightness: brightness,
    primary: c(MaterialDynamicColors.primary),
    onPrimary: c(MaterialDynamicColors.onPrimary),
    primaryContainer: c(MaterialDynamicColors.primaryContainer),
    onPrimaryContainer: c(MaterialDynamicColors.onPrimaryContainer),
    primaryFixed: c(MaterialDynamicColors.primaryFixed),
    primaryFixedDim: c(MaterialDynamicColors.primaryFixedDim),
    onPrimaryFixed: c(MaterialDynamicColors.onPrimaryFixed),
    onPrimaryFixedVariant: c(MaterialDynamicColors.onPrimaryFixedVariant),
    secondary: c(MaterialDynamicColors.secondary),
    onSecondary: c(MaterialDynamicColors.onSecondary),
    secondaryContainer: c(MaterialDynamicColors.secondaryContainer),
    onSecondaryContainer: c(MaterialDynamicColors.onSecondaryContainer),
    secondaryFixed: c(MaterialDynamicColors.secondaryFixed),
    secondaryFixedDim: c(MaterialDynamicColors.secondaryFixedDim),
    onSecondaryFixed: c(MaterialDynamicColors.onSecondaryFixed),
    onSecondaryFixedVariant: c(MaterialDynamicColors.onSecondaryFixedVariant),
    tertiary: c(MaterialDynamicColors.tertiary),
    onTertiary: c(MaterialDynamicColors.onTertiary),
    tertiaryContainer: c(MaterialDynamicColors.tertiaryContainer),
    onTertiaryContainer: c(MaterialDynamicColors.onTertiaryContainer),
    tertiaryFixed: c(MaterialDynamicColors.tertiaryFixed),
    tertiaryFixedDim: c(MaterialDynamicColors.tertiaryFixedDim),
    onTertiaryFixed: c(MaterialDynamicColors.onTertiaryFixed),
    onTertiaryFixedVariant: c(MaterialDynamicColors.onTertiaryFixedVariant),
    error: c(MaterialDynamicColors.error),
    onError: c(MaterialDynamicColors.onError),
    errorContainer: c(MaterialDynamicColors.errorContainer),
    onErrorContainer: c(MaterialDynamicColors.onErrorContainer),
    surface: c(MaterialDynamicColors.surface),
    onSurface: c(MaterialDynamicColors.onSurface),
    surfaceDim: c(MaterialDynamicColors.surfaceDim),
    surfaceBright: c(MaterialDynamicColors.surfaceBright),
    surfaceContainerLowest: c(MaterialDynamicColors.surfaceContainerLowest),
    surfaceContainerLow: c(MaterialDynamicColors.surfaceContainerLow),
    surfaceContainer: c(MaterialDynamicColors.surfaceContainer),
    surfaceContainerHigh: c(MaterialDynamicColors.surfaceContainerHigh),
    surfaceContainerHighest: c(MaterialDynamicColors.surfaceContainerHighest),
    onSurfaceVariant: c(MaterialDynamicColors.onSurfaceVariant),
    outline: c(MaterialDynamicColors.outline),
    outlineVariant: c(MaterialDynamicColors.outlineVariant),
    shadow: c(MaterialDynamicColors.shadow),
    scrim: c(MaterialDynamicColors.scrim),
    inverseSurface: c(MaterialDynamicColors.inverseSurface),
    onInverseSurface: c(MaterialDynamicColors.inverseOnSurface),
    inversePrimary: c(MaterialDynamicColors.inversePrimary),
    surfaceTint: c(MaterialDynamicColors.surfaceTint),
  );
  // 首页使用米白/浅绿的底色，而不是默认的中性灰。
  if (brightness == Brightness.light) {
    return scheme.copyWith(
      surface: const Color(0xFFF7F9F1),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF2F5EB),
      surfaceContainer: const Color(0xFFEDF2E6),
      surfaceContainerHigh: const Color(0xFFE6EDDF),
      surfaceContainerHighest: const Color(0xFFDFE8D7),
    );
  }
  return scheme.copyWith(
    surface: const Color(0xFF101612),
    surfaceContainerLowest: const Color(0xFF0A0F0C),
    surfaceContainerLow: const Color(0xFF161D18),
    surfaceContainer: const Color(0xFF1B241E),
    surfaceContainerHigh: const Color(0xFF222D26),
    surfaceContainerHighest: const Color(0xFF2A372F),
  );
}

ThemeData buildTheme(Brightness brightness) {
  final scheme = greenColorScheme(brightness);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    // Windows 上 Segoe UI 没有中文字形，优先用微软雅黑
    fontFamily: 'Microsoft YaHei UI',
    fontFamilyFallback: const ['Microsoft YaHei', 'PingFang SC', 'Noto Sans CJK SC', 'sans-serif'],
    scaffoldBackgroundColor: scheme.surface,
    visualDensity: VisualDensity.standard,
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
  );
}
