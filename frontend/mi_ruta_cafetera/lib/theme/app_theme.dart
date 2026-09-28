import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';

class AppTheme {
  AppTheme._();

  // ============================================================
  // TEMA PRINCIPAL
  // ============================================================

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.white,

      primaryContainer: AppColors.surfaceGreen,
      onPrimaryContainer: AppColors.textOnDark,

      secondary: AppColors.secondary,
      onSecondary: AppColors.white,

      secondaryContainer: AppColors.orangeSoft,
      onSecondaryContainer: AppColors.coffeeDark,

      tertiary: AppColors.tertiary,
      onTertiary: AppColors.white,

      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,

      surfaceContainerHighest:
          AppColors.surfaceVariant,

      outline: AppColors.border,
      outlineVariant: AppColors.divider,

      error: AppColors.error,
      onError: AppColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,

      // ========================================================
      // FONDO GENERAL
      // ========================================================

      scaffoldBackgroundColor:
          AppColors.background,

      fontFamily: 'Roboto',

      // ========================================================
      // APP BAR
      // ========================================================

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: AppDimensions.elevationNone,
        scrolledUnderElevation:
            AppDimensions.elevationNone,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      // ========================================================
      // CARDS
      // ========================================================

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: AppDimensions.elevationCard,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius,
          ),
          side: const BorderSide(
            color: AppColors.border,
            width: 0.7,
          ),
        ),
      ),

      // ========================================================
      // ELEVATED BUTTON
      // ========================================================

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,

          disabledBackgroundColor:
              AppColors.border,

          disabledForegroundColor:
              AppColors.textLight,

          elevation:
              AppDimensions.elevationButton,

          minimumSize: const Size(
            0,
            AppDimensions.buttonHeight,
          ),

          padding:
              const EdgeInsets.symmetric(
            horizontal:
                AppDimensions.spacingXl,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              AppDimensions.radiusXl,
            ),
          ),

          textStyle:
              const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ========================================================
      // OUTLINED BUTTON
      // ========================================================

      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor:
              AppColors.primary,

          minimumSize: const Size(
            0,
            AppDimensions.buttonHeight,
          ),

          padding:
              const EdgeInsets.symmetric(
            horizontal:
                AppDimensions.spacingXl,
          ),

          side: const BorderSide(
            color: AppColors.primary,
            width: 1.2,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              AppDimensions.radiusXl,
            ),
          ),

          textStyle:
              const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ========================================================
      // TEXT BUTTON
      // ========================================================

      textButtonTheme:
          TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor:
              AppColors.primary,

          minimumSize: const Size(
            0,
            AppDimensions.buttonHeight,
          ),

          padding:
              const EdgeInsets.symmetric(
            horizontal:
                AppDimensions.spacingMd,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              AppDimensions.radiusMd,
            ),
          ),

          textStyle:
              const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ========================================================
      // FLOATING ACTION BUTTON
      // ========================================================

      floatingActionButtonTheme:
          const FloatingActionButtonThemeData(
        backgroundColor:
            AppColors.secondary,

        foregroundColor:
            AppColors.white,

        elevation:
            AppDimensions.elevationFloating,

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(
            Radius.circular(
              AppDimensions.radiusLg,
            ),
          ),
        ),
      ),

      // ========================================================
      // INPUTS
      // ========================================================

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,

        fillColor:
            AppColors.surface,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal:
              AppDimensions.spacingLg,
          vertical:
              AppDimensions.spacingMd,
        ),

        hintStyle:
            const TextStyle(
          color: AppColors.textLight,
          fontSize: 14,
        ),

        labelStyle:
            const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),

        prefixIconColor:
            AppColors.textSecondary,

        suffixIconColor:
            AppColors.textSecondary,

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppDimensions.searchRadius,
          ),
          borderSide:
              const BorderSide(
            color: AppColors.border,
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppDimensions.searchRadius,
          ),
          borderSide:
              const BorderSide(
            color: AppColors.border,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppDimensions.searchRadius,
          ),
          borderSide:
              const BorderSide(
            color: AppColors.primary,
            width: 1.8,
          ),
        ),

        errorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppDimensions.searchRadius,
          ),
          borderSide:
              const BorderSide(
            color: AppColors.error,
          ),
        ),

        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            AppDimensions.searchRadius,
          ),
          borderSide:
              const BorderSide(
            color: AppColors.error,
            width: 1.8,
          ),
        ),
      ),

      // ========================================================
      // DIVIDER
      // ========================================================

      dividerTheme:
          const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ========================================================
      // CHIPS
      // ========================================================

      chipTheme:
          ChipThemeData(
        backgroundColor:
            AppColors.cream,

        selectedColor:
            AppColors.primary,

        disabledColor:
            AppColors.surfaceVariant,

        labelStyle:
            const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),

        secondaryLabelStyle:
            const TextStyle(
          color: AppColors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),

        padding:
            const EdgeInsets.symmetric(
          horizontal:
              AppDimensions.spacingMd,
          vertical:
              AppDimensions.spacingXs,
        ),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            AppDimensions.chipRadius,
          ),
        ),

        side:
            const BorderSide(
          color: AppColors.border,
        ),
      ),

      // ========================================================
      // SNACKBAR
      // ========================================================

      snackBarTheme:
          SnackBarThemeData(
        backgroundColor:
            AppColors.coffeeDark,

        contentTextStyle:
            const TextStyle(
          color: AppColors.white,
          fontSize: 14,
        ),

        actionTextColor:
            AppColors.secondary,

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            AppDimensions.radiusLg,
          ),
        ),

        behavior:
            SnackBarBehavior.floating,

        elevation:
            AppDimensions.elevationHigh,
      ),

      // ========================================================
      // DIALOG
      // ========================================================

      dialogTheme:
          DialogThemeData(
        backgroundColor:
            AppColors.surface,

        surfaceTintColor:
            Colors.transparent,

        elevation:
            AppDimensions.elevationFloating,

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            AppDimensions.radiusXxl,
          ),
        ),

        titleTextStyle:
            const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),

        contentTextStyle:
            const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 15,
          height: 1.4,
        ),
      ),

      // ========================================================
      // BOTTOM SHEET
      // ========================================================

      bottomSheetTheme:
          BottomSheetThemeData(
        backgroundColor:
            AppColors.surface,

        surfaceTintColor:
            Colors.transparent,

        elevation:
            AppDimensions.elevationFloating,

        modalElevation:
            AppDimensions.elevationFloating,

        shape:
            const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(
            top: Radius.circular(
              AppDimensions.sheetRadius,
            ),
          ),
        ),

        clipBehavior:
            Clip.antiAlias,
      ),

      // ========================================================
      // ICONOS
      // ========================================================

      iconTheme:
          const IconThemeData(
        color: AppColors.primary,
        size: AppDimensions.iconMd,
      ),

      // ========================================================
      // TIPOGRAFÍA
      // ========================================================

      textTheme:
          const TextTheme(
        headlineLarge:
            TextStyle(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: 1.12,
        ),

        headlineMedium:
            TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: 1.15,
        ),

        headlineSmall:
            TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),

        titleLarge:
            TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),

        titleMedium:
            TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),

        titleSmall:
            TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),

        bodyLarge:
            TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          height: 1.45,
        ),

        bodyMedium:
            TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.4,
        ),

        bodySmall:
            TextStyle(
          color: AppColors.textLight,
          fontSize: 12,
          height: 1.35,
        ),

        labelLarge:
            TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),

        labelMedium:
            TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),

        labelSmall:
            TextStyle(
          color: AppColors.textLight,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ========================================================
      // PROGRESS INDICATORS
      // ========================================================

      progressIndicatorTheme:
          const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor:
            AppColors.divider,
        circularTrackColor:
            AppColors.divider,
      ),

      // ========================================================
      // LIST TILES
      // ========================================================

      listTileTheme:
          const ListTileThemeData(
        iconColor: AppColors.primary,
        textColor: AppColors.textPrimary,

        contentPadding:
            EdgeInsets.symmetric(
          horizontal:
              AppDimensions.spacingLg,
        ),

        subtitleTextStyle:
            TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
      ),

      // ========================================================
      // CHECKBOX
      // ========================================================

      checkboxTheme:
          CheckboxThemeData(
        fillColor:
            WidgetStateProperty
                .resolveWith<Color?>(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return AppColors.primary;
            }

            return AppColors.surface;
          },
        ),

        checkColor:
            const WidgetStatePropertyAll(
          AppColors.white,
        ),

        side:
            const BorderSide(
          color: AppColors.border,
        ),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            AppDimensions.radiusSm,
          ),
        ),
      ),

      // ========================================================
      // RADIO
      // ========================================================

      radioTheme:
          const RadioThemeData(
        fillColor:
            WidgetStatePropertyAll(
          AppColors.primary,
        ),
      ),

      // ========================================================
      // SWITCH
      // ========================================================

      switchTheme:
          SwitchThemeData(
        thumbColor:
            WidgetStateProperty
                .resolveWith<Color?>(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return AppColors.white;
            }

            return AppColors.textLight;
          },
        ),

        trackColor:
            WidgetStateProperty
                .resolveWith<Color?>(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return AppColors.primary;
            }

            return AppColors.divider;
          },
        ),

        trackOutlineColor:
            const WidgetStatePropertyAll(
          AppColors.border,
        ),
      ),

      // ========================================================
      // TOOLTIP
      // ========================================================

      tooltipTheme:
          TooltipThemeData(
        decoration:
            BoxDecoration(
          color: AppColors.coffeeDark,
          borderRadius:
              BorderRadius.circular(
            AppDimensions.radiusSm,
          ),
        ),

        textStyle:
            const TextStyle(
          color: AppColors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}