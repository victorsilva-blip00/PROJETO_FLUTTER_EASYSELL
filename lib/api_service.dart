import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  ApiService._();

  // Não coloque barra no final: as rotas abaixo já começam com "/".
  static const String baseUrl = 'https://easysellback.onrender.com';

  static String? token;
  static String? userId;
  static String? companyId;
  static Map<String, dynamic>? usuario;
  static bool modoDemo = false;

  static bool isConnectivityError(Object error) {
    if (error is TimeoutException || error is http.ClientException) return true;
    final message = error.toString().toLowerCase();
    return message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('client failed to fetch') ||
        message.contains('xmlhttprequest error') ||
        message.contains('failed to fetch') ||
        message.contains('connection refused') ||
        message.contains('connection reset') ||
        message.contains('network is unreachable') ||
        message.contains('timed out') ||
        message.contains('service unavailable') ||
        RegExp(r'(?:http|erro)\s*5\d\d').hasMatch(message);
  }

  static void entrarModoDemo({String? email}) {
    modoDemo = true;
    token = null;
    userId = 'demo-user';
    companyId = 'demo-company';
    usuario = {
      'id': userId,
      'name': 'Conta de demonstração',
      'email': email?.trim().isNotEmpty == true
          ? email!.trim()
          : 'demo@easysell.app',
      'role': 'administrador',
      'empresaId': companyId,
    };
  }

  static void _requireOnline() {
    if (modoDemo) {
      throw Exception(
        'Modo demonstração: esta alteração não pode ser salva sem conexão com a API.',
      );
    }
  }

  static List<Map<String, dynamic>> get _demoProdutos => [
    {
      '_id': 'demo-produto-1',
      'name': 'Camiseta básica',
      'categoria': 'Vestuário',
      'preco': 59.90,
      'price': 59.90,
      'quantidade': 24,
      'stock': 24,
    },
    {
      '_id': 'demo-produto-2',
      'name': 'Caneca Easy',
      'categoria': 'Acessórios',
      'preco': 32.50,
      'price': 32.50,
      'quantidade': 7,
      'stock': 7,
    },
    {
      '_id': 'demo-produto-3',
      'name': 'Ecobag',
      'categoria': 'Acessórios',
      'preco': 45.00,
      'price': 45.00,
      'quantidade': 0,
      'stock': 0,
    },
  ];

  static List<Map<String, dynamic>> get _demoVendas => [
    {
      '_id': 'demo-venda-1',
      'Numero': '1042',
      'name': 'Mariana Costa',
      'IdProduto': 'demo-produto-1',
      'Preco_gasto': 119.80,
      'Quantidade': 2,
      'status': 'Concluída',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      '_id': 'demo-venda-2',
      'Numero': '1041',
      'name': 'Rafael Lima',
      'IdProduto': 'demo-produto-2',
      'Preco_gasto': 65.00,
      'Quantidade': 2,
      'status': 'Concluída',
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String(),
    },
    {
      '_id': 'demo-venda-3',
      'Numero': '1040',
      'name': 'Joana Alves',
      'IdProduto': 'demo-produto-1',
      'Preco_gasto': 59.90,
      'Quantidade': 1,
      'status': 'Pendente',
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 2))
          .toIso8601String(),
    },
  ];

  static List<Map<String, dynamic>> get _demoFuncionarios => [
    {
      '_id': 'demo-equipe-1',
      'name': 'Ana Souza',
      'cpf': '000.000.000-00',
      'funcao': 'Atendimento',
      'status': 'Ativo',
    },
    {
      '_id': 'demo-equipe-2',
      'name': 'Lucas Martins',
      'cpf': '111.111.111-11',
      'funcao': 'Vendas',
      'status': 'Ativo',
    },
  ];

  static String _somenteNumeros(String valor) {
    return valor.replaceAll(RegExp(r'\D'), '');
  }

  static Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (token != null && token!.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<T> _withRetry<T>(
    Future<T> Function() request, {
    int maxTentativas = 3,
  }) async {
    for (var tentativa = 1; tentativa <= maxTentativas; tentativa++) {
      try {
        return await request().timeout(const Duration(seconds: 30));
      } on TimeoutException {
        if (tentativa == maxTentativas) rethrow;
      } catch (error) {
        final mensagem = error.toString().toLowerCase();
        final ehRecuperavel =
            mensagem.contains('client failed to fetch') ||
            mensagem.contains('failed host lookup') ||
            mensagem.contains('connection refused') ||
            mensagem.contains('connection reset by peer') ||
            mensagem.contains('socketexception') ||
            mensagem.contains('timed out');

        if (!ehRecuperavel || tentativa == maxTentativas) {
          rethrow;
        }
      }

      await Future.delayed(Duration(seconds: tentativa));
    }

    throw Exception('Falha ao conectar com a API.');
  }

  static dynamic _json(http.Response response) {
    dynamic body;

    try {
      if (response.body.isEmpty) {
        body = null;
      } else {
        body = jsonDecode(response.body);
      }
    } catch (_) {
      body = response.body;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Erro ${response.statusCode} na API.';

      if (body is Map && body['message'] != null) {
        final value = body['message'];

        if (value is List) {
          message = value.join('\n');
        } else {
          message = value.toString();
        }
      }

      throw Exception(message);
    }

    return body;
  }

  static String? _idFrom(dynamic value) {
    if (value == null) return null;
    if (value is Map) return (value['_id'] ?? value['id'])?.toString();
    final text = value.toString();
    return text.isEmpty || text == 'null' ? null : text;
  }

  static Map<String, dynamic> _map(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return {};
  }

  static List<Map<String, dynamic>> _list(dynamic data) {
    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password, {
    bool permitirEmpresaAusente = false,
  }) async {
    modoDemo = false;
    final response = await _withRetry(
      () => http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      ),
    );

    final data = _map(_json(response));

    token = data['accessToken']?.toString();
    userId = data['sub']?.toString();
    companyId = _idFrom(
      data['empresaId'] ?? data['companyId'] ?? data['company'],
    );

    usuario = Map<String, dynamic>.from(data);

    try {
      await me();
    } catch (error) {
      if (isConnectivityError(error)) rethrow;
    }

    if (companyId == null || companyId!.isEmpty) {
      if (permitirEmpresaAusente) {
        return {...data, ...?usuario};
      }
      logout();
      throw Exception(
        'Esta conta ainda não tem uma empresa vinculada. Conclua o cadastro '
        'da empresa ou fale com o suporte.',
      );
    }

    return {...data, ...?usuario};
  }

  static Future<void> solicitarRecuperacaoSenha(String email) async {
    _requireOnline();
    final response = await _withRetry(
      () => http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: _headers,
        body: jsonEncode({'email': email.trim()}),
      ),
    );

    _json(response);
  }

  static Future<void> redefinirSenha({
    required String email,
    required String codigo,
    required String novaSenha,
  }) async {
    _requireOnline();
    final response = await _withRetry(
      () => http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: _headers,
        body: jsonEncode({
          'email': email.trim(),
          'code': codigo.trim(),
          'password': novaSenha,
        }),
      ),
    );

    _json(response);
  }

  static Future<Map<String, dynamic>> me() async {
    if (modoDemo) return usuario ?? {};
    final response = await _withRetry(
      () => http.get(Uri.parse('$baseUrl/auth/me'), headers: _headers),
    );

    final data = _map(_json(response));

    usuario = {...?usuario, ...data};

    userId =
        data['userId']?.toString() ??
        data['_id']?.toString() ??
        data['sub']?.toString() ??
        userId;

    companyId =
        _idFrom(
          data['empresaId'] ??
              data['empresaid'] ??
              data['companyId'] ??
              data['company'],
        ) ??
        companyId;

    return data;
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password, {
    required String nomeEmpresa,
    required String categoria,
    required String cnpj,
    required String cpfResponsavel,
  }) async {
    _requireOnline();
    final response = await _withRetry(
      () => http.post(
        Uri.parse('$baseUrl/user'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': 'administrador',
        }),
      ),
    );

    late final Map<String, dynamic> data;
    try {
      data = _map(_json(response));
    } catch (error) {
      throw Exception(
        'Falha ao criar o usuário (HTTP ${response.statusCode}): '
        '${error.toString().replaceFirst('Exception: ', '')}',
      );
    }

    final id =
        _idFrom(data) ?? _idFrom(data['user']) ?? _idFrom(data['usuario']);

    if (id == null || id.isEmpty) {
      throw Exception(
        'A API criou a conta, mas não retornou o identificador do usuário. '
        'Verifique a resposta da criação e tente novamente.',
      );
    }

    try {
      await bootstrapCompany(
        id,
        nomeEmpresa,
        categoria: categoria,
        cnpj: cnpj,
        cpfResponsavel: cpfResponsavel,
      );
    } catch (error) {
      throw Exception(
        'A conta foi criada, mas não foi possível cadastrar a empresa. '
        'Não tente cadastrar novamente com o mesmo e-mail; entre em contato '
        'com o suporte. Detalhe: ${error.toString().replaceFirst('Exception: ', '')}',
      );
    }

    return data;
  }

  static Future<Map<String, dynamic>> bootstrapCompany(
    String id,
    String name, {
    required String categoria,
    required String cnpj,
    required String cpfResponsavel,
  }) async {
    _requireOnline();
    final response = await _withRetry(
      () => http.post(
        Uri.parse('$baseUrl/company/bootstrap/$id'),
        headers: _headers,
        body: jsonEncode({
          'name': name.trim(),
          'categoria': categoria.trim(),
          'cnpj': _somenteNumeros(cnpj),
          'cpfResponsavel': _somenteNumeros(cpfResponsavel),
        }),
      ),
    );

    final data = _map(_json(response));

    companyId =
        _idFrom(data) ?? _idFrom(data['empresa']) ?? _idFrom(data['company']);

    if (token != null &&
        token!.isNotEmpty &&
        id == userId &&
        companyId != null) {
      try {
        final updateResponse = await _withRetry(
          () => http.patch(
            Uri.parse('$baseUrl/user/$id'),
            headers: _headers,
            body: jsonEncode({'company': companyId}),
          ),
        );

        if (updateResponse.statusCode >= 200 &&
            updateResponse.statusCode < 300) {
          final updatedUser = _map(_json(updateResponse));

          usuario = {...?usuario, ...updatedUser, 'empresaId': companyId};
        }
      } catch (_) {}
    }

    return data;
  }

  static Future<Map<String, dynamic>> atualizarUsuario({
    String? nome,
    String? email,
    String? telefone,
    String? cargo,
  }) async {
    _requireOnline();
    final id = userId;

    if (id == null || id.isEmpty) {
      throw Exception('Usuário não identificado.');
    }

    final body = <String, dynamic>{};

    if (nome != null && nome.trim().isNotEmpty) {
      body['name'] = nome.trim();
    }

    if (email != null && email.trim().isNotEmpty) {
      body['email'] = email.trim();
    }
    if (telefone != null) body['telefone'] = telefone.trim();
    if (cargo != null) body['cargo'] = cargo.trim();

    if (body.isEmpty) {
      return usuario ?? {};
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/user/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );

    final data = _map(_json(response));

    usuario = {...?usuario, ...data};

    if (nome != null && nome.trim().isNotEmpty) {
      usuario!['name'] = nome.trim();
    }

    if (email != null && email.trim().isNotEmpty) {
      usuario!['email'] = email.trim();
    }
    if (telefone != null) usuario!['telefone'] = telefone.trim();
    if (cargo != null) usuario!['cargo'] = cargo.trim();

    return usuario ?? data;
  }

  static Future<Map<String, dynamic>> getEmpresa(String id) async {
    if (modoDemo) {
      return {
        '_id': companyId,
        'id': companyId,
        'name': 'Empresa de demonstração',
        'categoria': 'Varejo',
        'cnpj': '00.000.000/0000-00',
      };
    }
    final response = await http.get(
      Uri.parse('$baseUrl/company/$id'),
      headers: _headers,
    );

    return _map(_json(response));
  }

  static Future<Map<String, dynamic>> atualizarEmpresa({
    String? nome,
    String? cnpj,
    String? categoria,
  }) async {
    _requireOnline();
    final id = companyId;

    if (id == null || id.isEmpty) {
      throw Exception('Empresa não identificada.');
    }

    final body = <String, dynamic>{};

    if (nome != null && nome.trim().isNotEmpty) {
      body['name'] = nome.trim();
    }
    if (cnpj != null) body['cnpj'] = cnpj.trim();
    if (categoria != null) body['categoria'] = categoria.trim();

    if (body.isEmpty) {
      return getEmpresa(id);
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/company/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );

    final data = _map(_json(response));

    return data;
  }

  static void logout() {
    modoDemo = false;
    token = null;
    userId = null;
    companyId = null;
    usuario = null;
  }

  static String _requireCompany() {
    final id = companyId;

    if (id == null || id.isEmpty) {
      throw Exception('Sua conta ainda não possui uma empresa vinculada.');
    }

    return id;
  }

  static Future<List<Map<String, dynamic>>> produtos() async {
    if (modoDemo) return _demoProdutos;
    final id = _requireCompany();

    final response = await http.get(
      Uri.parse('$baseUrl/produtos/company/$id'),
      headers: _headers,
    );

    return _list(_json(response));
  }

  static Future<Map<String, dynamic>> criarProduto({
    required String nome,
    required String categoria,
    required double preco,
    required int quantidade,
  }) async {
    _requireOnline();
    final response = await http.post(
      Uri.parse('$baseUrl/produtos'),
      headers: _headers,
      body: jsonEncode({
        'name': nome,
        'categoria': categoria,
        'companyId': _requireCompany(),
        'quantidade': quantidade,
        'preco': preco,
      }),
    );

    return _map(_json(response));
  }

  static Future<Map<String, dynamic>> atualizarProduto(
    String id, {
    String? nome,
    String? categoria,
    double? preco,
    int? quantidade,
  }) async {
    _requireOnline();
    final body = <String, dynamic>{
      if (nome != null) 'name': nome,
      if (categoria != null) 'categoria': categoria,
      if (preco != null) 'preco': preco,
      if (quantidade != null) 'quantidade': quantidade,
      'companyId': _requireCompany(),
    };

    final response = await http.patch(
      Uri.parse('$baseUrl/produtos/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );

    return _map(_json(response));
  }

  static Future<void> excluirProduto(String id) async {
    _requireOnline();
    final response = await http.delete(
      Uri.parse('$baseUrl/produtos/$id'),
      headers: _headers,
    );

    _json(response);
  }

  static Future<List<Map<String, dynamic>>> vendas() async {
    if (modoDemo) return _demoVendas;
    final id = _requireCompany();

    final response = await http.get(
      Uri.parse('$baseUrl/clientes/company/$id'),
      headers: _headers,
    );

    return _list(_json(response));
  }

  static Future<Map<String, dynamic>> criarVenda({
    required String cliente,
    required String pedido,
    required String produtoId,
    required double valor,
    required int itens,
    required String status,
    String? funcionarioId,
  }) async {
    _requireOnline();
    final response = await http.post(
      Uri.parse('$baseUrl/clientes'),
      headers: _headers,
      body: jsonEncode({
        'name': cliente,
        'Numero': pedido,
        'IdProduto': produtoId,
        'idcompany': _requireCompany(),
        'Preco_gasto': valor,
        'Quantidade': itens,
        'status': status,
        if (funcionarioId != null && funcionarioId.isNotEmpty)
          'funcionarioId': funcionarioId,
      }),
    );

    return _map(_json(response));
  }

  static Future<Map<String, dynamic>> atualizarVenda(
    String id,
    String status,
  ) async {
    _requireOnline();
    final response = await http.patch(
      Uri.parse('$baseUrl/clientes/$id'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );

    final data = _map(_json(response));
    final confirmacao = await http.get(
      Uri.parse('$baseUrl/clientes/$id'),
      headers: _headers,
    );
    final vendaPersistida = _map(_json(confirmacao));

    if (_normalizarStatusVenda(vendaPersistida['status']) !=
        _normalizarStatusVenda(status)) {
      throw Exception(
        'O servidor não confirmou a alteração do status. A rota de atualização da API não documenta o campo "status"; o backend precisa aceitá-lo para salvar a mudança.',
      );
    }

    return {...data, ...vendaPersistida};
  }

  static String _normalizarStatusVenda(dynamic status) {
    return status
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[áàãâ]'), 'a')
        .replaceAll(RegExp(r'[éê]'), 'e')
        .replaceAll(RegExp(r'[í]'), 'i')
        .replaceAll(RegExp(r'[óôõ]'), 'o')
        .replaceAll(RegExp(r'[ú]'), 'u');
  }

  static Future<void> excluirVenda(String id) async {
    _requireOnline();
    final response = await http.delete(
      Uri.parse('$baseUrl/clientes/$id'),
      headers: _headers,
    );

    _json(response);
  }

  static Future<List<Map<String, dynamic>>> funcionarios() async {
    if (modoDemo) return _demoFuncionarios;
    final id = _requireCompany();

    final response = await http.get(
      Uri.parse('$baseUrl/company/employees/by-company/$id'),
      headers: _headers,
    );

    return _list(_json(response));
  }

  static Future<Map<String, dynamic>> criarFuncionario({
    required String nome,
    required String cpf,
    required String funcao,
    required String status,
  }) async {
    _requireOnline();
    final response = await http.post(
      Uri.parse('$baseUrl/company/employees'),
      headers: _headers,
      body: jsonEncode({
        'name': nome,
        'cpf': _somenteNumeros(cpf),
        'companyId': _requireCompany(),
        'funcao': funcao,
        'status': status,
      }),
    );

    return _map(_json(response));
  }

  static Future<Map<String, dynamic>> atualizarFuncionario(
    String id, {
    String? nome,
    String? cpf,
    String? funcao,
    String? status,
  }) async {
    _requireOnline();
    final body = <String, dynamic>{
      if (nome != null) 'name': nome,
      if (cpf != null) 'cpf': _somenteNumeros(cpf),
      if (funcao != null) 'funcao': funcao,
      if (status != null) 'status': status,
    };

    final response = await http.patch(
      Uri.parse('$baseUrl/company/employees/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );

    return _map(_json(response));
  }

  static Future<void> excluirFuncionario(String id) async {
    _requireOnline();
    final response = await http.delete(
      Uri.parse('$baseUrl/company/employees/$id'),
      headers: _headers,
    );

    _json(response);
  }
}
