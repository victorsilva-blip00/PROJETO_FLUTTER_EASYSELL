import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:frontend_easysell/api_service.dart';

void main() {
  setUp(ApiService.logout);

  test('demo mode provides sample data without an API connection', () async {
    ApiService.entrarModoDemo(email: 'teste@exemplo.com');

    expect(ApiService.modoDemo, isTrue);
    expect(ApiService.usuario?['email'], 'teste@exemplo.com');
    expect(await ApiService.produtos(), hasLength(3));
    expect(await ApiService.vendas(), hasLength(3));
    expect(await ApiService.funcionarios(), hasLength(2));
    expect(
      (await ApiService.getEmpresa(ApiService.companyId!))['name'],
      'Empresa de demonstração',
    );
  });

  test('demo mode rejects changes instead of pretending they were saved', () {
    ApiService.entrarModoDemo();

    expect(
      ApiService.criarProduto(
        nome: 'Teste',
        categoria: 'Geral',
        preco: 10,
        quantidade: 1,
      ),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('não pode ser salva'),
        ),
      ),
    );
  });

  test('network failures are distinguished from authentication errors', () {
    expect(
      ApiService.isConnectivityError(TimeoutException('timed out')),
      isTrue,
    );
    expect(
      ApiService.isConnectivityError(Exception('Erro 401 na API.')),
      isFalse,
    );
  });
}
