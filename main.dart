import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TelaAtividades(),
  ));
}

const String baseUrl = 'http://10.0.2.2/Projeto';

class _MascaraDataFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitos = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limite = digitos.length > 8 ? digitos.substring(0, 8) : digitos;

    final buffer = StringBuffer();
    for (int i = 0; i < limite.length; i++) {
      if (i == 2 || i == 4) {
        buffer.write('/');
      }
      buffer.write(limite[i]);
    }

    final textoFormatado = buffer.toString();
    return TextEditingValue(
      text: textoFormatado,
      selection: TextSelection.collapsed(offset: textoFormatado.length),
    );
  }
}

class TelaAtividades extends StatefulWidget {
  const TelaAtividades({super.key});

  @override
  State<TelaAtividades> createState() => _TelaAtividadesState();
}

class _TelaAtividadesState extends State<TelaAtividades> {
  static const List<String> _nomesMeses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  final TextEditingController _diaController = TextEditingController();
  final TextEditingController _atividadeController = TextEditingController();

  late int _mesSelecionado;
  late int _anoSelecionado;
  String _status = '';
  List<dynamic> _atividades = [];

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _mesSelecionado = agora.month;
    _anoSelecionado = agora.year;
    _carregarAtividades();
  }

  @override
  void dispose() {
    _diaController.dispose();
    _atividadeController.dispose();
    super.dispose();
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  DateTime _dataInicialPicker() {
    final partes = _diaController.text.trim().split('/');
    if (partes.length == 3) {
      final d = int.tryParse(partes[0]);
      final m = int.tryParse(partes[1]);
      final a = int.tryParse(partes[2]);
      if (d != null && m != null && a != null && a >= 2000 && a <= 2100 && m >= 1 && m <= 12 && d >= 1 && d <= 31) {
        final candidata = DateTime(a, m, d);
        if (candidata.year == a && candidata.month == m && candidata.day == d) {
          return candidata;
        }
      }
    }
    return DateTime.now();
  }

  Future<void> _selecionarData() async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _dataInicialPicker(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Selecione a data',
      cancelText: 'Cancelar',
      confirmText: 'OK',
      fieldLabelText: 'Data',
      fieldHintText: 'dd/mm/aaaa',
    );
    if (escolhida != null) {
      setState(() {
        _diaController.text = _formatarData(escolhida);
      });
    }
  }

  String _chaveMes(int ano, int mes) {
    return '$ano-${mes.toString().padLeft(2, '0')}';
  }

  String _labelMes(int ano, int mes) {
    return '${_nomesMeses[mes - 1]}/$ano';
  }

  List<Map<String, int>> _opcoesMeses() {
    final agora = DateTime.now();
    final chaves = <String>{};
    final lista = <Map<String, int>>[];

    void adicionar(int ano, int mes) {
      if (chaves.add(_chaveMes(ano, mes))) {
        lista.add({'ano': ano, 'mes': mes});
      }
    }

    for (int i = 0; i < 12; i++) {
      final data = DateTime(agora.year, agora.month - i, 1);
      adicionar(data.year, data.month);
    }

    adicionar(_anoSelecionado, _mesSelecionado);

    lista.sort((a, b) {
      final cmp = b['ano']!.compareTo(a['ano']!);
      return cmp != 0 ? cmp : b['mes']!.compareTo(a['mes']!);
    });

    return lista;
  }

  Future<void> _carregarAtividades() async {
    try {
      final url = Uri.parse(
        '$baseUrl/mostrar_atividade.php?mes=$_mesSelecionado&ano=$_anoSelecionado',
      );
      final resposta = await http.get(url);
      final dados = jsonDecode(utf8.decode(resposta.bodyBytes));
      if (!mounted) return;
      setState(() {
        _atividades = dados['atividades'] as List<dynamic>;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = 'Erro ao conectar no servidor!';
      });
    }
  }

  Future<void> _cadastrarAtividade() async {
    try {
      final url = Uri.parse('$baseUrl/cadastrar_atividade.php');
      final resposta = await http.post(url, body: {
        'dia': _diaController.text.trim(),
        'atividade': _atividadeController.text.trim(),
        'mes': '$_mesSelecionado',
        'ano': '$_anoSelecionado',
      });
      final dados = jsonDecode(utf8.decode(resposta.bodyBytes));
      if (!mounted) return;
      if (dados['erro'] != null) {
        setState(() {
          _status = dados['erro'].toString();
        });
      } else {
        _diaController.clear();
        _atividadeController.clear();
        setState(() {
          _mesSelecionado = int.parse(dados['mes'].toString());
          _anoSelecionado = int.parse(dados['ano'].toString());
          _status = 'Atividade cadastrada com sucesso!';
        });
        await _carregarAtividades();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = 'Erro ao conectar no servidor!';
      });
    }
  }

  void _mudarMes(int delta) {
    final novaData = DateTime(_anoSelecionado, _mesSelecionado + delta, 1);
    setState(() {
      _anoSelecionado = novaData.year;
      _mesSelecionado = novaData.month;
      _status = '';
    });
    _carregarAtividades();
  }

  @override
  Widget build(BuildContext context) {
    final opcoes = _opcoesMeses();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atividades do Dia'),
        actions: [
          IconButton(
            onPressed: _carregarAtividades,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _diaController,
              keyboardType: TextInputType.number,
              inputFormatters: [_MascaraDataFormatter()],
              decoration: InputDecoration(
                labelText: 'Data (dd/mm/aaaa)',
                hintText: 'dd/mm/aaaa',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: _selecionarData,
                  icon: const Icon(Icons.calendar_today),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _atividadeController,
              decoration: const InputDecoration(
                labelText: 'Atividade',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _cadastrarAtividade,
              child: const Text('Salvar Atividade'),
            ),
            if (_status.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_status, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 20),
            const Text(
              'Atividades do mês',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () => _mudarMes(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _chaveMes(_anoSelecionado, _mesSelecionado),
                    decoration: const InputDecoration(
                      labelText: 'Mês',
                      border: OutlineInputBorder(),
                    ),
                    items: opcoes
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: _chaveMes(item['ano']!, item['mes']!),
                            child: Text(_labelMes(item['ano']!, item['mes']!)),
                          ),
                        )
                        .toList(),
                    onChanged: (valor) {
                      if (valor == null) return;
                      final partes = valor.split('-');
                      setState(() {
                        _anoSelecionado = int.parse(partes[0]);
                        _mesSelecionado = int.parse(partes[1]);
                        _status = '';
                      });
                      _carregarAtividades();
                    },
                  ),
                ),
                IconButton(
                  onPressed: () => _mudarMes(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_atividades.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Nenhuma atividade em ${_labelMes(_anoSelecionado, _mesSelecionado)}.',
                  ),
                ),
              )
            else
              ..._atividades.map(
                (a) => Card(
                  child: ListTile(
                    title: Text(a['atividade'].toString()),
                    subtitle: Text('Dia: ${a['dia']}'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
