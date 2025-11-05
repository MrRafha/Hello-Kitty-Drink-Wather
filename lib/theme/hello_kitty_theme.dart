import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelloKittyTheme {
  // Cores principais do tema Hello Kitty
  static const Color primaryPink = Color(0xFFFF69B4);
  static const Color lightPink = Color(0xFFFFB6C1);
  static const Color pastelPink = Color(0xFFFFE4E1);
  static const Color softPink = Color(0xFFFFF0F5);
  static const Color deepPink = Color(0xFFFF1493);
  static const Color waterBlue = Color(0xFF87CEEB);
  static const Color softBlue = Color(0xFFE0F6FF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color darkGray = Color(0xFF666666);

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: _createMaterialColor(primaryPink),
      primaryColor: primaryPink,
      scaffoldBackgroundColor: softPink,
      fontFamily: 'Nunito',
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: pastelPink,
        foregroundColor: deepPink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: deepPink,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Nunito',
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: white,
        elevation: 8,
        shadowColor: primaryPink.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
          shadowColor: primaryPink.withOpacity(0.5),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: deepPink,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      
      // FloatingActionButton Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryPink,
        foregroundColor: white,
        elevation: 8,
        shape: CircleBorder(),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: deepPink,
        unselectedItemColor: lightPink,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Nunito',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          fontFamily: 'Nunito',
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        fillColor: white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: lightPink, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: lightPink, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryPink, width: 2),
        ),
        labelStyle: const TextStyle(
          color: deepPink,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(
          color: lightPink,
          fontFamily: 'Nunito',
        ),
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryPink,
        linearTrackColor: pastelPink,
        circularTrackColor: pastelPink,
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryPink;
          }
          return lightPink;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return waterBlue;
          }
          return pastelPink;
        }),
      ),
      
      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryPink,
        inactiveTrackColor: pastelPink,
        thumbColor: primaryPink,
        overlayColor: primaryPink.withOpacity(0.2),
        valueIndicatorColor: primaryPink,
        valueIndicatorTextStyle: const TextStyle(
          color: white,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: deepPink,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Nunito',
        ),
        displayMedium: TextStyle(
          color: deepPink,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Nunito',
        ),
        displaySmall: TextStyle(
          color: deepPink,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Nunito',
        ),
        headlineLarge: TextStyle(
          color: deepPink,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          fontFamily: 'Nunito',
        ),
        headlineMedium: TextStyle(
          color: deepPink,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Nunito',
        ),
        headlineSmall: TextStyle(
          color: deepPink,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Nunito',
        ),
        titleLarge: TextStyle(
          color: darkGray,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Nunito',
        ),
        titleMedium: TextStyle(
          color: darkGray,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Nunito',
        ),
        titleSmall: TextStyle(
          color: darkGray,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Nunito',
        ),
        bodyLarge: TextStyle(
          color: darkGray,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          fontFamily: 'Nunito',
        ),
        bodyMedium: TextStyle(
          color: darkGray,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          fontFamily: 'Nunito',
        ),
        bodySmall: TextStyle(
          color: darkGray,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          fontFamily: 'Nunito',
        ),
        labelLarge: TextStyle(
          color: primaryPink,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Nunito',
        ),
        labelMedium: TextStyle(
          color: primaryPink,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Nunito',
        ),
        labelSmall: TextStyle(
          color: primaryPink,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          fontFamily: 'Nunito',
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: primaryPink,
        size: 24,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: pastelPink,
        selectedColor: primaryPink,
        labelStyle: const TextStyle(
          color: deepPink,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // Método auxiliar para criar MaterialColor
  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  // Gradientes personalizados
  static const LinearGradient pinkGradient = LinearGradient(
    colors: [pastelPink, softPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient waterGradient = LinearGradient(
    colors: [waterBlue, softBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [primaryPink, lightPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}