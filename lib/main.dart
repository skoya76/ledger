import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Org. 分散システム研究室'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _investmentPool = 0;
  int _inputValue = 0;

  void _addToPool() {
    setState(() {
      _investmentPool += _inputValue;
    });
  }

  void _consumeFromPool() {
    setState(() {
      if (_investmentPool - _inputValue >= 0) {
        _investmentPool -= _inputValue;
      } else {
        _investmentPool = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // TODO: Open menu
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Investment Pool: $_investmentPool円',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _inputValue = int.tryParse(value) ?? 0;
              },
              decoration: InputDecoration(
                labelText: 'Enter amount',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addToPool,
              child: const Text('プール金追加'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _consumeFromPool,
              child: const Text('プール金消費'),
            ),
          ],
        ),
      ),
    );
  }
}
