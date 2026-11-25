import 'package:flutter/material.dart';

import 'api_service.dart';
import 'app_shell.dart';
import 'cadastro.dart';
import 'esqueci_senha.dart';
import 'tema.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool mostrarSenha = false;
  bool carregando = false;

  AppCores get c => context.cores;

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> entrar() async {
    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();
    final senha = senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      _mensagem('Preencha o e-mail e a senha.');
      return;
    }

    if (carregando) return;

    setState(() => carregando = true);

    try {
      await ApiService.login(email, senha);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } catch (e) {
      if (!mounted) return;
      if (ApiService.isConnectivityError(e)) {
        entrarModoDemo();
        return;
      }
      _mensagem(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => carregando = false);
      }
    }
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: c.superficie,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  void abrirCadastro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Cadastro()),
    );
  }

  void abrirEsqueciSenha() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EsqueciSenha()),
    );
  }

  void entrarModoDemo() {
    ApiService.entrarModoDemo(email: emailController.text);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: c.fundo,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 860;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                  maxWidth: 1024,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _topBar(),
                    SizedBox(height: isWide ? 88 : 56),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: _intro(centered: false)),
                          const SizedBox(width: 80),
                          Expanded(child: _cardLogin()),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _intro(centered: true),
                          const SizedBox(height: 40),
                          _cardLogin(),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: c.texto,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
            children: [
              const TextSpan(text: 'EasySell'),
              TextSpan(
                text: '.',
                style: TextStyle(color: c.azul),
              ),
            ],
          ),
        ),
        const Spacer(),
        Material(
          color: c.superficie,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: () => AppTema.definirEscuro(!AppTema.escuro),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: c.bordaMedia),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                AppTema.escuro
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                color: c.textoSuave,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _intro({required bool centered}) {
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          'BEM-VINDO DE VOLTA',
          textAlign: centered ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            color: c.azul,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Entre e retome o controle.',
          textAlign: centered ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            color: c.texto,
            fontSize: 48,
            height: 1,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.7,
          ),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Text(
            'Acompanhe seu estoque, financeiro, clientes e equipe em um só lugar.',
            textAlign: centered ? TextAlign.center : TextAlign.left,
            style: TextStyle(color: c.textoSuave, fontSize: 15, height: 1.7),
          ),
        ),
      ],
    );
  }

  Widget _cardLogin() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: c.superficie,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.bordaSutil),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACESSAR CONTA',
            style: TextStyle(
              color: c.azul,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Faça seu login.',
            style: TextStyle(
              color: c.texto,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Informe seus dados para continuar.',
            style: TextStyle(color: c.textoSuave, fontSize: 14),
          ),
          const SizedBox(height: 28),
          _label('E-mail'),
          const SizedBox(height: 8),
          _campo(
            controller: emailController,
            hint: 'voce@empresa.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          _label('Senha'),
          const SizedBox(height: 8),
          _campo(
            controller: senhaController,
            hint: 'Digite sua senha',
            obscureText: !mostrarSenha,
            suffixIcon: IconButton(
              tooltip: mostrarSenha ? 'Ocultar senha' : 'Mostrar senha',
              onPressed: () => setState(() => mostrarSenha = !mostrarSenha),
              icon: Icon(
                mostrarSenha
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: c.textoFraco,
                size: 18,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: abrirEsqueciSenha,
              style: TextButton.styleFrom(
                foregroundColor: c.azul,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('Esqueci minha senha'),
            ),
          ),
          const SizedBox(height: 8),
          _botaoEntrar(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: carregando ? null : entrarModoDemo,
              style: OutlinedButton.styleFrom(
                foregroundColor: c.texto,
                side: BorderSide(color: c.bordaMedia),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Explorar em modo demonstração',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Usa dados fictícios e não salva alterações.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textoFraco, fontSize: 11),
          ),
          const SizedBox(height: 24),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  'Ainda não tem uma conta? ',
                  style: TextStyle(color: c.textoFraco, fontSize: 13),
                ),
                GestureDetector(
                  onTap: abrirCadastro,
                  child: Text(
                    'Criar cadastro',
                    style: TextStyle(
                      color: c.azul,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String texto) {
    return Text(
      texto,
      style: TextStyle(
        color: c.texto,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autocorrect: false,
      style: TextStyle(color: c.texto, fontSize: 14),
      cursorColor: c.azul,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.textoFraco, fontSize: 13),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: c.ehEscuro
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: c.bordaMedia),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: c.azul, width: 1.3),
        ),
      ),
    );
  }

  Widget _botaoEntrar() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: carregando ? null : entrar,
        style: ElevatedButton.styleFrom(
          backgroundColor: c.azul,
          foregroundColor: Colors.white,
          disabledBackgroundColor: c.azul.withValues(alpha: 0.65),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: carregando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Entrar',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
