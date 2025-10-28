import 'package:flutter/material.dart';

// ⚠️ CORES ANTIGAS - Mantidas para compatibilidade com widgets existentes
const Color verde = Color(0xFF66BB6A); // Verde mais discreto
const Color roxoClaro = Color(0xFF546E7A); // Azul acinzentado

// 🎨 CORES DO FRIGOSOFT (Novas)
const Color cinzaEscuroFrigo = Color(0xFF424242); // Header
const Color cinzaMedioFrigo = Color(0xFF616161); // Secundário
const Color verdeFrigo = Color(0xFF4CAF50); // Status positivo
const Color vermelhoFrigo = Color(0xFFE53935); // Status negativo
const Color laranjaFrigo = Color(0xFFFF9800); // Avisos
const Color brancoFrigo = Color(0xFFFFFFFF); // Fundo cards
const Color cinzaClaroFrigo = Color(0xFFF5F5F5); // Fundo página

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Cores principais
    colorScheme: ColorScheme.light(
      primary: cinzaEscuroFrigo,
      secondary: verdeFrigo,
      surface: brancoFrigo,
      error: vermelhoFrigo,
      onPrimary: brancoFrigo,
      onSecondary: brancoFrigo,
      onSurface: cinzaEscuroFrigo,
    ),
    
    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: cinzaEscuroFrigo,
      foregroundColor: brancoFrigo,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        color: brancoFrigo,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    ),
    
    // Scaffold
    scaffoldBackgroundColor: cinzaClaroFrigo,
    
    // Cards - CORRIGIDO: usando CardThemeData
    cardTheme: CardThemeData(
      color: brancoFrigo,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    
    // Input/TextField
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: brancoFrigo,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cinzaMedioFrigo.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cinzaMedioFrigo.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: cinzaEscuroFrigo, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    
    // Botões
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cinzaEscuroFrigo,
        foregroundColor: brancoFrigo,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: cinzaEscuroFrigo,
        foregroundColor: brancoFrigo,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: cinzaEscuroFrigo,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: const BorderSide(color: cinzaEscuroFrigo, width: 1.5),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    // Chip/Badge
    chipTheme: ChipThemeData(
      backgroundColor: cinzaClaroFrigo,
      deleteIconColor: cinzaEscuroFrigo,
      labelStyle: const TextStyle(
        color: cinzaEscuroFrigo,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Drawer
    drawerTheme: const DrawerThemeData(
      backgroundColor: brancoFrigo,
      elevation: 4,
    ),
    
    // Lista
    listTileTheme: ListTileThemeData(
      tileColor: brancoFrigo,
      selectedColor: verdeFrigo,
      iconColor: cinzaMedioFrigo,
      textColor: cinzaEscuroFrigo,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // Divider
    dividerTheme: DividerThemeData(
      color: cinzaMedioFrigo.withOpacity(0.2),
      thickness: 1,
    ),
    
    // Text Theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: cinzaEscuroFrigo,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: cinzaEscuroFrigo,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(
        color: cinzaEscuroFrigo,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: cinzaEscuroFrigo,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: cinzaEscuroFrigo,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: cinzaEscuroFrigo,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: cinzaEscuroFrigo,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: cinzaEscuroFrigo,
        fontSize: 14,
      ),
      labelLarge: TextStyle(
        color: cinzaEscuroFrigo,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
