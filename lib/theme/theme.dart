// Available app themes for use
import 'package:flutter/material.dart';

// -- GLOBAL THEME COMPONENTS --

TextTheme textTheme = const TextTheme(
  // Considering mapping these to M3 roles or using GoogleFonts for M3-friendly fonts
  displayLarge: TextStyle(
      fontSize: 57, fontWeight: FontWeight.normal, letterSpacing: -0.25),
  displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.normal),
  displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.normal),

  headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.normal),
  headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.normal),
  headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),

  titleLarge: TextStyle(
      fontSize: 22, fontWeight: FontWeight.w500), // Your current one is bold
  titleMedium:
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
  titleSmall:
      TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),

  bodyLarge: TextStyle(
      fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: 0.5),
  bodyMedium: TextStyle(
      fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: 0.25),
  bodySmall: TextStyle(
      fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: 0.4),

  labelLarge:
      TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
  labelMedium:
      TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
  labelSmall:
      TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
);

// M3 Buttons: Buttons have new styles.
// TextButton often has no background by default in M3 unless explicitly styled or in certain contexts.
// Your TextButtonThemeData gives it a purple background. This is fine if it's your design choice,
// but be aware it deviates from the typical M3 naked TextButton.
TextButtonThemeData textButtonThemeData = TextButtonThemeData(
  style: TextButton.styleFrom(
    // If you want a background, consider using a color from the ColorScheme for consistency
    backgroundColor:
        Colors.purpleAccent, // or a less primary color for a text button
    foregroundColor: Colors
        .purple, // M3 TextButtons typically use primary or onSurface color for text
    padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0), // M3 has specific padding/height specs
    textStyle:
        textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold), // Example
  ),
);

// ElevatedButton in M3 uses tonal elevation and often primary color for background.
ElevatedButtonThemeData elevatedButtonThemeData = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    //backgroundColor: Colors.deepPurple, // This is okay, will be used directly.
    // Or, to use the scheme's primary:
    backgroundColor: colorSchemeLight.primary, // Using scheme color
    foregroundColor: colorSchemeLight.onPrimary, // Using scheme color
    padding: const EdgeInsets.symmetric(
        horizontal: 24.0, vertical: 12.0), // Adjust padding for M3 feel
    textStyle: textTheme.labelLarge,
  ),
);

// M3 TextFields (InputDecorationTheme)
// In M3, TextFields have "filled" and "outlined" styles that look different.
// The default is often an underlined style.
InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
  isDense: true, // This is fine.
  contentPadding: const EdgeInsets.symmetric(
      vertical: 10.0, horizontal: 12.0), // M3 has different padding guides
  hintStyle: TextStyle(
      color: Colors.grey
          .shade600), // Use a color from the scheme if possible, e.g., onSurfaceVariant
  enabledBorder: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12.0)),
    //borderSide: BorderSide(color: Colors.grey.shade400 /* ideally colorScheme.outline */),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
    borderSide: BorderSide(
        color: colorSchemeLight.primary, width: 2.0),
  ),
  // For filled style (more common M3 default in some contexts):
  filled: true,
  fillColor: MaterialStateColor.resolveWith((states) {
    // Example dynamic fill color
    if (states.contains(MaterialState.hovered)) {
      return Colors.grey.shade200
          .withOpacity(0.8); // Slightly different on hover
    }
    return Colors.grey.shade200; // Default fill color
  }),
  border: const UnderlineInputBorder(
    // Or other M3 standard borders
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(8.0),
      topRight: Radius.circular(8.0),
    ),
    borderSide: BorderSide.none, // For filled, often no border line itself
  ),
);

// AppBarTheme in M3
// M3 AppBars often use surface tint for elevation and can be transparent or blend with content.
AppBarTheme appBarTheme(ColorScheme colorScheme) {
  // Pass ColorScheme to use its colors
  return AppBarTheme(
    backgroundColor:
        colorScheme.surface, // M3 often uses surface or surfaceContainer
    foregroundColor: colorScheme.onSurface, // Text/icons on the AppBar
    elevation:
        0, // M3 often uses 0 elevation with a surfaceTintColor applied if scrolled under
    surfaceTintColor: colorScheme.surfaceTint, // Key for M3 elevation effect
    centerTitle: true, // Personal preference
    titleTextStyle:
        textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
  );
}

// CardTheme in M3
// M3 Cards have different elevation styles (often lower or none, with an outline)
// and more rounded corners.
CardThemeData cardThemeData(ColorScheme colorScheme) {
  return CardThemeData(
    elevation: 1.0, // M3 tends to use subtle elevation or outlines
    // M3 cards can be 'elevated', 'filled', or 'outlined'
    // For an outlined card:
    // shape: RoundedRectangleBorder(
    //   side: BorderSide(color: colorScheme.outlineVariant),
    //   borderRadius: BorderRadius.circular(12.0), // M3 uses larger border radiuses
    // ),
    // For a filled card (subtle):
    color: colorScheme.surfaceVariant, // Or surfaceContainerHighest etc.
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
  );
}

// --- LIGHT MODE ---
// Generate the full ColorScheme first
ColorScheme colorSchemeLight = ColorScheme.fromSeed(
  seedColor: Colors.purple, // Your brand's seed color
  brightness: Brightness.light,
  primary: Colors.purple, // Use the same seed color
);

ThemeData lightMode = ThemeData(
    useMaterial3: true,
    colorScheme: colorSchemeLight,
    textTheme: textTheme, // Your custom or M3-aligned text theme
    textButtonTheme: textButtonThemeData,
    elevatedButtonTheme: elevatedButtonThemeData,
    inputDecorationTheme: inputDecorationTheme.copyWith(
      // Ensure to use colors from colorSchemeLight
      hintStyle:
          TextStyle(color: colorSchemeLight.onSurfaceVariant.withOpacity(0.6)),
      fillColor: colorSchemeLight.surfaceVariant
          .withOpacity(0.4), // Example for filled
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: colorSchemeLight.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: colorSchemeLight.primary, width: 2.0),
      ),
    ),
    appBarTheme: appBarTheme(colorSchemeLight), // Pass the scheme
    scaffoldBackgroundColor:
        colorSchemeLight.background, // M3 uses background color from scheme
    cardTheme: cardThemeData(colorSchemeLight), // Add CardTheme
    // Add other component themes as needed:
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorSchemeLight.primaryContainer,
      foregroundColor: colorSchemeLight.onPrimaryContainer,
    ),
    navigationBarTheme: NavigationBarThemeData(
      // For BottomNavigationBar's M3 equivalent
      indicatorColor: colorSchemeLight.secondaryContainer,
      backgroundColor: colorSchemeLight.surfaceVariant,
      labelTextStyle: MaterialStateProperty.all(textTheme.labelSmall
          ?.copyWith(color: colorSchemeLight.onSurfaceVariant)),
      iconTheme: MaterialStateProperty.all(
          IconThemeData(color: colorSchemeLight.onSurfaceVariant)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorSchemeLight.surface,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(28.0)), // M3 dialogs are very rounded
      titleTextStyle:
          textTheme.headlineSmall?.copyWith(color: colorSchemeLight.onSurface),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colorSchemeLight.secondaryContainer,
      labelStyle: textTheme.labelLarge
          ?.copyWith(color: colorSchemeLight.onSecondaryContainer),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      side: BorderSide.none,
    ));

// --- DARK MODE ---
ColorScheme colorSchemeDark = ColorScheme.fromSeed(
  seedColor: Colors.purple, // Use the same seed color
  brightness: Brightness.dark,
  primary: Colors.purple, // Use the same seed color
);

ThemeData darkMode = ThemeData(
    useMaterial3: true,
    colorScheme: colorSchemeDark,
    textTheme:
        textTheme, // Ensure text colors are suitable for dark mode (M3 textTheme handles this well)
    textButtonTheme:
        textButtonThemeData, // Review if background color is still desired for dark TextButtons
    elevatedButtonTheme:
        elevatedButtonThemeData, // These might need different foreground/background for dark
    inputDecorationTheme: inputDecorationTheme.copyWith(
      // Ensure to use colors from colorSchemeDark
      hintStyle:
          TextStyle(color: colorSchemeDark.onSurfaceVariant.withOpacity(0.6)),
      fillColor: colorSchemeDark.surfaceVariant.withOpacity(0.4),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: colorSchemeDark.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        borderSide: BorderSide(color: colorSchemeDark.primary, width: 2.0),
      ),
    ),
    appBarTheme: appBarTheme(colorSchemeDark),
    scaffoldBackgroundColor: colorSchemeDark.background,
    cardTheme: cardThemeData(colorSchemeDark),
    // Apply dark mode overrides for other component themes as well
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorSchemeDark.primaryContainer,
      foregroundColor: colorSchemeDark.onPrimaryContainer,
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: colorSchemeDark.secondaryContainer,
      backgroundColor: colorSchemeDark.surfaceVariant,
      labelTextStyle: MaterialStateProperty.all(textTheme.labelSmall
          ?.copyWith(color: colorSchemeDark.onSurfaceVariant)),
      iconTheme: MaterialStateProperty.all(
          IconThemeData(color: colorSchemeDark.onSurfaceVariant)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorSchemeDark.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
      titleTextStyle:
          textTheme.headlineSmall?.copyWith(color: colorSchemeDark.onSurface),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colorSchemeDark.secondaryContainer,
      labelStyle: textTheme.labelLarge
          ?.copyWith(color: colorSchemeDark.onSecondaryContainer),
    ));
