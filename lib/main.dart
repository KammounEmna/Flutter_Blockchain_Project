import 'package:flutter/material.dart';
import 'blockchain_service.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Blockchain',
      home: BlockchainPage(),
    );
  }
}

class BlockchainPage extends StatefulWidget {
  @override
  _BlockchainPageState createState() => _BlockchainPageState();
}

class _BlockchainPageState extends State<BlockchainPage> {
  final BlockchainService _blockchainService = BlockchainService();

  @override
  void initState() {
    super.initState();
    _blockchainService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blockchain Integration'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                String result = await _blockchainService.addRecord("John Doe", "01-01-1990");
                print(result);
              },
              child: Text('Add Record'),
            ),
            ElevatedButton(
              onPressed: () async {
                List<dynamic> record = await _blockchainService.getRecord(EthereumAddress.fromHex('0xd6B668148041818C790106bdf68C2172BfAD0886'));
                print(record);
              },
              child: Text('Get Record'),
            ),
          ],
        ),
      ),
    );
  }
}
