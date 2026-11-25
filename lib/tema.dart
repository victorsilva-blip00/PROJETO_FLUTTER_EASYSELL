import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTema {
  AppTema._();

  static final ValueNotifier<ThemeMode> modo = ValueNotifier<ThemeMode>(
    ThemeMode.light,
  );

  static bool get escuro => modo.value == ThemeMode.dark;

  static void definirEscuro(bool valor) {
    modo.value = valor ? ThemeMode.dark : ThemeMode.light;
  }

  static final ThemeData temaEscuro = _montar(
    AppCores.modoEscuro,
    Brightness.dark,
  );

  static final ThemeData temaClaro = _montar(
    AppCores.modoClaro,
    Brightness.light,
  );

  static ThemeData _montar(AppCores c, Brightness brilho) {
    return ThemeData(
      useMaterial3: true,
      brightness: brilho,
      scaffoldBackgroundColor: c.fundo,
      colorScheme: ColorScheme.fromSeed(
        seedColor: c.roxo,
        brightness: brilho,
        surface: c.superficie,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData(brightness: brilho).textTheme,
      ).apply(bodyColor: c.texto, displayColor: c.texto),
      dividerColor: c.bordaSutil,
      appBarTheme: AppBarTheme(
        backgroundColor: c.superficie,
        foregroundColor: c.texto,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      extensions: <ThemeExtension<dynamic>>[c],
    );
  }
}

extension AppCoresContext on BuildContext {
  AppCores get cores => Theme.of(this).extension<AppCores>()!;
}

@immutable
class AppCores extends ThemeExtension<AppCores> {
  final bool ehEscuro;

  final Color fundo;
  final Color fundo2;
  final Color superficie;
  final Color navBar;

  final Color fundoA;
  final Color fundoB;
  final Color fundoC;
  final Color cardA;
  final Color cardB;
  final Color destaqueA;
  final Color destaqueB;
  final Color destaqueC;
  final Color sheetA;
  final Color sheetB;

  final Color texto;
  final Color textoSuave;
  final Color textoFraco;

  final Color bordaSutil;
  final Color bordaMedia;

  final Color trilhaInativa;

  final Color roxo;
  final Color roxoClaro;
  final Color verde;
  final Color amarelo;
  final Color vermelho;
  final Color azul;

  const AppCores({
    required this.ehEscuro,
    required this.fundo,
    required this.fundo2,
    required this.superficie,
    required this.navBar,
    required this.fundoA,
    required this.fundoB,
    required this.fundoC,
    required this.cardA,
    required this.cardB,
    required this.destaqueA,
    required this.destaqueB,
    required this.destaqueC,
    required this.sheetA,
    required this.sheetB,
    required this.texto,
    required this.textoSuave,
    required this.textoFraco,
    required this.bordaSutil,
    required this.bordaMedia,
    required this.trilhaInativa,
    required this.roxo,
    required this.roxoClaro,
    required this.verde,
    required this.amarelo,
    required this.vermelho,
    required this.azul,
  });

  static const AppCores modoEscuro = AppCores(
    ehEscuro: true,
    fundo: Color(0xFF0D1014),
    fundo2: Color(0xFF111418),
    superficie: Color(0xFF161A20),
    navBar: Color(0xFF161A20),
    fundoA: Color(0xFF0D1014),
    fundoB: Color(0xFF0D1014),
    fundoC: Color(0xFF0D1014),
    cardA: Color(0xFF161A20),
    cardB: Color(0xFF161A20),
    destaqueA: Color(0xFF161A20),
    destaqueB: Color(0xFF161A20),
    destaqueC: Color(0xFF161A20),
    sheetA: Color(0xFF161A20),
    sheetB: Color(0xFF161A20),
    texto: Color(0xFFF5F7FA),
    textoSuave: Color(0xFFB4BBC5),
    textoFraco: Color(0xFF858D98),
    bordaSutil: Color(0x17FFFFFF),
    bordaMedia: Color(0x24FFFFFF),
    trilhaInativa: Color(0xFF303640),
    roxo: Color(0xFF2563EB),
    roxoClaro: Color(0xFF60A5FA),
    verde: Color(0xFF34D399),
    amarelo: Color(0xFFFBBF24),
    vermelho: Color(0xFFFB7185),
    azul: Color(0xFF60A5FA),
  );

  static const AppCores modoClaro = AppCores(
    ehEscuro: false,
    fundo: Color(0xFFF4F6FA),
    fundo2: Color(0xFFEEF1F6),
    superficie: Color(0xFFFFFFFF),
    navBar: Color(0xFFFFFFFF),
    fundoA: Color(0xFFF4F6FA),
    fundoB: Color(0xFFF4F6FA),
    fundoC: Color(0xFFF4F6FA),
    cardA: Color(0xFFFFFFFF),
    cardB: Color(0xFFFFFFFF),
    destaqueA: Color(0xFFFFFFFF),
    destaqueB: Color(0xFFFFFFFF),
    destaqueC: Color(0xFFFFFFFF),
    sheetA: Color(0xFFFFFFFF),
    sheetB: Color(0xFFFFFFFF),
    texto: Color(0xFF111827),
    textoSuave: Color(0xFF4B5563),
    textoFraco: Color(0xFF6B7280),
    bordaSutil: Color(0x14000000),
    bordaMedia: Color(0x1F000000),
    trilhaInativa: Color(0xFFCBD5E1),
    roxo: Color(0xFF2563EB),
    roxoClaro: Color(0xFF1D4ED8),
    verde: Color(0xFF059669),
    amarelo: Color(0xFFD97706),
    vermelho: Color(0xFFE11D48),
    azul: Color(0xFF2563EB),
  );

  LinearGradient get gradFundo => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [fundoA, fundoB, fundoC],
  );

  LinearGradient get gradCard => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardA, cardB],
  );

  LinearGradient get gradDestaque => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [destaqueA, destaqueB, destaqueC],
  );

  LinearGradient get gradSheet => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [sheetA, sheetB],
  );

  static const LinearGradient gradRoxo = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF2563EB)],
  );

  @override
  AppCores copyWith() => this;

  @override
  AppCores lerp(ThemeExtension<AppCores>? other, double t) {
    if (other is! AppCores) return this;
    return t < 0.5 ? this : other;
  }
}
