// lib/utils/theme.dart - Enhanced Minimalistic Modern Theme
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Modern Color Palette - Ultra Minimalistic
  static const Color primaryColor = Color(0xFF0066FF);
  static const Color primaryLight = Color(0xFF4D94FF);
  static const Color primaryDark = Color(0xFF0052CC);
  static const Color primarySurface = Color(0xFFF0F7FF);
  
  static const Color secondaryColor = Color(0xFF6366F1);
  static const Color accentColor = Color(0xFF06D6A0);
  
  // Status Colors - Refined
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFFF8C00);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);
  
  // Neutral Colors - Ultra Refined
  static const Color backgroundColor = Color(0xFFFDFDFD);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color cardColor = Color(0xFFFFFFFF);
  
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color dividerColor = Color(0xFFF1F5F9);
  static const Color overlayColor = Color(0x0A000000);

  // Modern Typography
  static const String fontFamily = 'SF Pro Display';

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: textPrimary,
      letterSpacing: -1.2,
      height: 1.1,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: -0.8,
      height: 1.15,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: -0.6,
      height: 1.2,
    ),
    headlineLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: -0.4,
      height: 1.25,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      letterSpacing: -0.3,
      height: 1.3,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      letterSpacing: -0.2,
      height: 1.35,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      letterSpacing: -0.1,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      height: 1.4,
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: textSecondary,
      letterSpacing: 0.1,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.6,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: textSecondary,
      height: 1.5,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: textPrimary,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: textSecondary,
      letterSpacing: 0.1,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: textTertiary,
      letterSpacing: 0.2,
    ),
  );

  // Modern Spacing System - Mathematical Progression
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing14 = 14.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;
  static const double spacing80 = 80.0;

  // Modern Border Radius - Consistent Scale
  static const double radius2 = 2.0;
  static const double radius4 = 4.0;
  static const double radius6 = 6.0;
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius20 = 20.0;
  static const double radius24 = 24.0;
  static const double radius32 = 32.0;
  static const double radiusFull = 9999.0;

  // Ultra Modern Shadows - Layered & Subtle
  static const List<BoxShadow> shadowXs = [
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 1,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 3,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 2,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 3,
      offset: Offset(0, 2),
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 16,
      offset: Offset(0, 10),
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 6,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> shadowXl = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 24,
      offset: Offset(0, 20),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 8),
      spreadRadius: -4,
    ),
  ];

  // Animated Shadows for Interactive Elements
  static List<BoxShadow> getInteractiveShadow(bool isPressed) {
    return isPressed ? shadowSm : shadowMd;
  }

  static List<BoxShadow> getFloatingShadow(bool isElevated) {
    return isElevated ? shadowLg : shadowSm;
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: Brightness.light,
      
      // Enhanced Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: primarySurface,
        onPrimaryContainer: primaryDark,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFF0F0FF),
        onSecondaryContainer: Color(0xFF1A1A2E),
        tertiary: accentColor,
        onTertiary: Colors.white,
        surface: surfaceColor,
        onSurface: textPrimary,
        surfaceContainerHighest: surfaceVariant,
        onSurfaceVariant: textSecondary,
        error: errorColor,
        onError: Colors.white,
        outline: borderColor,
        outlineVariant: dividerColor,
        shadow: Color(0x1A000000),
        scrim: Color(0x80000000),
        inverseSurface: Color(0xFF1C1C1E),
        onInverseSurface: Color(0xFFF2F2F7),
        inversePrimary: primaryLight,
      ),
      
      textTheme: textTheme,
      
      // App Bar with Blur Effect
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor.withValues(alpha: 0.85),
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 0,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(
          color: textPrimary,
          size: 22,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
        ),
        toolbarHeight: 64,
      ),

      // Modern Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing16,
          ),
          minimumSize: const Size(0, 52),
          maximumSize: const Size(double.infinity, 52),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          animationDuration: const Duration(milliseconds: 200),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return primaryDark;
              } else if (states.contains(WidgetState.hovered)) {
                return primaryLight;
              } else if (states.contains(WidgetState.disabled)) {
                return textTertiary;
              }
              return primaryColor;
            },
          ),
          elevation: WidgetStateProperty.resolveWith<double>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return 1;
              } else if (states.contains(WidgetState.hovered)) {
                return 3;
              }
              return 0;
            },
          ),
        ),
      ),

      // Modern Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          side: const BorderSide(color: borderColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing16,
          ),
          minimumSize: const Size(0, 52),
          maximumSize: const Size(double.infinity, 52),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          animationDuration: const Duration(milliseconds: 200),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return primaryColor.withValues(alpha: 0.08);
              } else if (states.contains(WidgetState.hovered)) {
                return primaryColor.withValues(alpha: 0.04);
              }
              return Colors.transparent;
            },
          ),
          side: WidgetStateProperty.resolveWith<BorderSide>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.focused) || 
                  states.contains(WidgetState.pressed)) {
                return const BorderSide(color: primaryColor, width: 2);
              }
              return const BorderSide(color: borderColor, width: 1.5);
            },
          ),
        ),
      ),

      // Modern Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: spacing20,
            vertical: spacing12,
          ),
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius8),
          ),
          textStyle: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          animationDuration: const Duration(milliseconds: 150),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return primaryColor.withValues(alpha: 0.12);
              } else if (states.contains(WidgetState.hovered)) {
                return primaryColor.withValues(alpha: 0.06);
              }
              return Colors.transparent;
            },
          ),
        ),
      ),

      // Modern Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: textTertiary,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(
          color: primaryColor,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.all(spacing20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius16),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius16),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius16),
          borderSide: BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius16),
          borderSide: BorderSide(color: errorColor, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius16),
          borderSide: BorderSide(color: dividerColor, width: 1),
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: errorColor,
          height: 1.4,
        ),
        helperStyle: textTheme.bodySmall?.copyWith(
          color: textSecondary,
          height: 1.4,
        ),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),

      // Modern Card Theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius20),
          side: BorderSide(color: borderColor.withValues(alpha: 0.6), width: 0.5),
        ),
        margin: const EdgeInsets.all(spacing8),
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),

      // Modern List Tile
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacing20,
          vertical: spacing8,
        ),
        minLeadingWidth: 40,
        minVerticalPadding: spacing8,
        horizontalTitleGap: spacing16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius12)),
        ),
        tileColor: Colors.transparent,
        selectedTileColor: Color(0x08000000),
        iconColor: textSecondary,
        textColor: textPrimary,
        titleTextStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.4,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
        ),
      ),

      // Modern Divider
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 0.5,
        space: 1,
        indent: 0,
        endIndent: 0,
      ),

      // Modern Chip
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        deleteIconColor: textSecondary,
        disabledColor: dividerColor,
        selectedColor: primarySurface,
        secondarySelectedColor: primaryColor.withValues(alpha: 0.12),
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        labelStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: primaryColor,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
          side: BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing8,
        ),
        pressElevation: 0,
        elevation: 0,
      ),

      // Modern Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        height: 80,
        indicatorColor: primarySurface,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius16),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return textTheme.labelSmall?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w700,
              );
            }
            return textTheme.labelSmall?.copyWith(
              color: textTertiary,
              fontWeight: FontWeight.w500,
            );
          },
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: primaryColor,
                size: 24,
              );
            }
            return const IconThemeData(
              color: textTertiary,
              size: 22,
            );
          },
        ),
      ),

      // Modern Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: primaryColor,
        unselectedLabelColor: textSecondary,
        indicatorColor: primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: primaryColor,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(radius2),
        ),
        labelStyle: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        overlayColor: WidgetStatePropertyAll(
          primaryColor.withValues(alpha: 0.08),
        ),
        splashFactory: InkRipple.splashFactory,
        tabAlignment: TabAlignment.start,
      ),

      // Modern FAB
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 3,
        focusElevation: 6,
        hoverElevation: 6,
        highlightElevation: 8,
        disabledElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius20),
        ),
        iconSize: 24,
        sizeConstraints: const BoxConstraints(
          minWidth: 56,
          minHeight: 56,
        ),
        largeSizeConstraints: const BoxConstraints(
          minWidth: 64,
          minHeight: 64,
        ),
        smallSizeConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
      ),

      // Modern Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceColor,
        modalBackgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radius32),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: dividerColor,
        dragHandleSize: Size(40, 4),
        clipBehavior: Clip.antiAliasWithSaveLayer,
      ),

      // Modern Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shadowColor: const Color(0x30000000),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius24)),
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: spacing24,
          vertical: spacing24,
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: textSecondary,
          height: 1.6,
        ),
        actionsPadding: const EdgeInsets.all(spacing20),
      ),

      // Modern Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1F2937),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: primaryLight,
        disabledActionTextColor: Colors.white38,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius16),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        actionOverflowThreshold: 0.25,
        showCloseIcon: false,
        closeIconColor: Colors.white70,
      ),

      // Modern Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return Colors.white;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }
            return textTertiary;
          },
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        trackOutlineWidth: WidgetStateProperty.all(0),
        thumbIcon: WidgetStateProperty.all(null),
      ),

      // Modern Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }
            return Colors.transparent;
          },
        ),
        checkColor: WidgetStateProperty.all(Colors.white),
        overlayColor: WidgetStateProperty.all(
          primaryColor.withValues(alpha: 0.08),
        ),
        side: BorderSide(
          color: borderColor,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius4),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),

      // Modern Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }
            return borderColor;
          },
        ),
        overlayColor: WidgetStateProperty.all(
          primaryColor.withValues(alpha: 0.08),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),

      // Modern Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: borderColor,
        thumbColor: primaryColor,
        overlayColor: primaryColor.withValues(alpha: 0.12),
        valueIndicatorColor: primaryColor,
        valueIndicatorTextStyle: textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 12,
          pressedElevation: 4,
          elevation: 2,
        ),
        overlayShape: const RoundSliderOverlayShape(
          overlayRadius: 20,
        ),
        trackShape: const RoundedRectSliderTrackShape(),
        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
        showValueIndicator: ShowValueIndicator.onlyForDiscrete,
        activeTickMarkColor: Colors.transparent,
        inactiveTickMarkColor: Colors.transparent,
      ),

      // Modern Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: borderColor,
        circularTrackColor: borderColor,
        refreshBackgroundColor: surfaceColor,
      ),

      // Material 3 Ripple Effect
      splashFactory: InkRipple.splashFactory,
      highlightColor: primaryColor.withValues(alpha: 0.04),
      splashColor: primaryColor.withValues(alpha: 0.08),
      hoverColor: primaryColor.withValues(alpha: 0.04),
      focusColor: primaryColor.withValues(alpha: 0.08),

      // Visual Density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Platform Brightness
      platform: TargetPlatform.android,
    );
  }

  // Helper methods for consistent spacing
  static EdgeInsets get paddingXS => const EdgeInsets.all(spacing4);
  static EdgeInsets get paddingSM => const EdgeInsets.all(spacing8);
  static EdgeInsets get paddingMD => const EdgeInsets.all(spacing16);
  static EdgeInsets get paddingLG => const EdgeInsets.all(spacing24);
  static EdgeInsets get paddingXL => const EdgeInsets.all(spacing32);

  static EdgeInsets get paddingHorizontalXS => const EdgeInsets.symmetric(horizontal: spacing4);
  static EdgeInsets get paddingHorizontalSM => const EdgeInsets.symmetric(horizontal: spacing8);
  static EdgeInsets get paddingHorizontalMD => const EdgeInsets.symmetric(horizontal: spacing16);
  static EdgeInsets get paddingHorizontalLG => const EdgeInsets.symmetric(horizontal: spacing24);
  static EdgeInsets get paddingHorizontalXL => const EdgeInsets.symmetric(horizontal: spacing32);

  static EdgeInsets get paddingVerticalXS => const EdgeInsets.symmetric(vertical: spacing4);
  static EdgeInsets get paddingVerticalSM => const EdgeInsets.symmetric(vertical: spacing8);
  static EdgeInsets get paddingVerticalMD => const EdgeInsets.symmetric(vertical: spacing16);
  static EdgeInsets get paddingVerticalLG => const EdgeInsets.symmetric(vertical: spacing24);
  static EdgeInsets get paddingVerticalXL => const EdgeInsets.symmetric(vertical: spacing32);

  // Enhanced Status Colors with Dynamic Opacity
  static Color getStatusColor(String status, {double opacity = 1.0}) {
    switch (status.toLowerCase()) {
      case 'pending':
        return warningColor.withValues(alpha: opacity);
      case 'in_progress':
      case 'ongoing':
        return infoColor.withValues(alpha: opacity);
      case 'completed':
      case 'selesai':
        return successColor.withValues(alpha: opacity);
      case 'cancelled':
      case 'dibatalkan':
        return errorColor.withValues(alpha: opacity);
      default:
        return textSecondary.withValues(alpha: opacity);
    }
  }

  static Color getPriorityColor(String priority, {double opacity = 1.0}) {
    switch (priority.toLowerCase()) {
      case 'low':
        return successColor.withValues(alpha: opacity);
      case 'medium':
        return warningColor.withValues(alpha: opacity);
      case 'high':
        return const Color(0xFFFF6B35).withValues(alpha: opacity);
      case 'critical':
        return errorColor.withValues(alpha: opacity);
      default:
        return textSecondary.withValues(alpha: opacity);
    }
  }

  // Dynamic shadows based on elevation
  static List<BoxShadow> getElevationShadow(int elevation) {
    switch (elevation) {
      case 1:
        return shadowXs;
      case 2:
        return shadowSm;
      case 3:
      case 4:
        return shadowMd;
      case 5:
      case 6:
        return shadowLg;
      default:
        return shadowXl;
    }
  }

  // Context-aware colors
  static Color getContextualColor(BuildContext context, String type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (type) {
      case 'surface':
        return isDark ? const Color(0xFF1C1C1E) : surfaceColor;
      case 'background':
        return isDark ? const Color(0xFF000000) : backgroundColor;
      case 'text_primary':
        return isDark ? const Color(0xFFFFFFFF) : textPrimary;
      case 'text_secondary':
        return isDark ? const Color(0xFFAAAAAA) : textSecondary;
      default:
        return primaryColor;
    }
  }
}