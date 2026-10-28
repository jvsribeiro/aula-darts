import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabuada',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const TabuadaPage(),
    );
  }
}

class TabuadaPage extends StatefulWidget {
  const TabuadaPage({super.key});

  @override
  State<TabuadaPage> createState() => _TabuadaPageState();
}

class _TabuadaPageState extends State<TabuadaPage> {
  static const totalOperacoes = 10;

  final _controller = TextEditingController();
  final _foco = FocusNode();
  int _fator = 1;
  int _multiplicador = 1;
  bool _aguardando = false;

  @override
  void dispose() {
    _controller.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _mostrarMensagem(String texto, Color cor) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto), backgroundColor: cor));
  }

  void _mudarFator() {
    setState(() {
      _fator = _fator % 10 + 1;
      _multiplicador = 1;
      _controller.clear();
    });
  }

  void _verificar() {
    if (_aguardando) return;
    final resposta = int.tryParse(_controller.text.trim());

    if (resposta == _fator * _multiplicador) {
      if (_multiplicador == totalOperacoes) {
        _mostrarMensagem(
          'Acertou todas do $_fator! Mudando de fator.',
          Colors.green,
        );
        _mudarFator();
      } else {
        _mostrarMensagem('Acertou!', Colors.green);
        setState(() {
          _multiplicador++;
          _controller.clear();
        });
      }
    } else {
      _errou();
    }
    _foco.requestFocus();
  }

  void _errou() {
    setState(() => _aguardando = true);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final snackBar = messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 1),
        content: GestureDetector(
          onTap: () => messenger.hideCurrentSnackBar(
            reason: SnackBarClosedReason.action,
          ),
          child: const Text('Errou, clique aqui para continuar.'),
        ),
        action: SnackBarAction(
          label: 'CONTINUAR',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );

    snackBar.closed.then((motivo) {
      if (!mounted) return;
      setState(() => _aguardando = false);
      if (motivo == SnackBarClosedReason.action) {
        setState(() => _controller.clear());
      } else {
        _mostrarMensagem('Mudando de fator.', Colors.orange);
        _mudarFator();
      }
      _foco.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Aula 12 - Tabuada')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Fator $_fator', style: tema.textTheme.titleLarge),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_multiplicador - 1) / totalOperacoes,
                ),
                Text('Operação $_multiplicador de $totalOperacoes'),
                const SizedBox(height: 24),
                Text(
                  '$_fator x $_multiplicador = ?',
                  key: const Key('operacao'),
                  style: tema.textTheme.displayMedium,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _controller,
                  focusNode: _foco,
                  autofocus: true,
                  enabled: !_aguardando,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'Resultado',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _verificar(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _aguardando ? null : _verificar,
                    child: const Text('Verificar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
