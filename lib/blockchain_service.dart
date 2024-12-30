import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class BlockchainService extends ChangeNotifier {
  bool isLoading = true;
  late Web3Client _client;
  late String _rpcUrl;
  late String _wsUrl;
  late EthereumAddress _contractAddress;
  late DeployedContract _contract;
  late ContractFunction _addRecordFunction;
  late ContractFunction _getRecordFunction;
  late ContractFunction _updateRecordFunction;
  late ContractFunction _getIdsFunction;
  late String _abiCode;

  final String privateKey = '0x99a15e28611243a8b6f7578498ecc96c03a513f3ebca33cbdd1575975c73e193'; // Replace with your private key

  BlockchainService() {
    initialize();
  }

  Future<void> initialize() async {
    await initialSetup();
    isLoading = false;
    notifyListeners();
  }

  // Function to establish Web3Client connection
  Future<void> initialSetup() async {
    _rpcUrl = 'http://10.0.2.2:7545'; // Ganache RPC URL
    _wsUrl = 'ws://10.0.2.2:7545';   // WebSocket URL
    _contractAddress = EthereumAddress.fromHex('0x41873eaEdED7383Da39218B9c97088E9a011f2c6'); // Replace with your contract address

    _client = Web3Client(_rpcUrl, http.Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });

    await getAbi();
    await getCredentials();
  }

  // Function to load the ABI from the asset and initialize the contract
  Future<void> getAbi() async {
    String abiString = await rootBundle.loadString('assets/CivilRegistry.json');
    var jsonAbi = jsonDecode(abiString);

    _abiCode = jsonEncode(jsonAbi["abi"]);
    print("Contract ABI: $_abiCode");

    // Initialize the deployed contract
    _contract = DeployedContract(
      ContractAbi.fromJson(_abiCode, 'CivilRegistry'),
      _contractAddress,
    );

    // Set the functions of the contract
    _addRecordFunction = _contract.function('addRecord');
    _getRecordFunction = _contract.function('getRecord');
    _updateRecordFunction = _contract.function('updateRecord');
    _getIdsFunction = _contract.function('getIds');
  }

  // Function to get the Ethereum credentials from the private key
  Future<Credentials> getCredentials() async {
    // Load credentials from private key
    return _client.credentialsFromPrivateKey(privateKey);
  }

  // Function to add a record to the blockchain
  Future<String> addRecord(String name, String birthDate) async {
    final credentials = await getCredentials();  // Use the credentials from private key
    
    final result = await _client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _contract,
        function: _addRecordFunction,
        parameters: [name, birthDate],
      ),
      chainId: 1337, // Ganache chain ID
    );
    return result;
  }

  // Function to get a record by Ethereum address
  Future<List<dynamic>> getRecord(EthereumAddress address) async {
    final result = await _client.call(
      contract: _contract,
      function: _getRecordFunction,
      params: [address],
    );
    return result;
  }

  // Function to update a record on the blockchain
  Future<String> updateRecord(EthereumAddress address, String recordType, String date) async {
    final credentials = await getCredentials();  // Use the credentials from private key
    final result = await _client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: _contract,
        function: _updateRecordFunction,
        parameters: [address, recordType, date],
      ),
      chainId: 1337, // Ganache chain ID
    );
    return result;
  }

  // Function to get all record IDs
  Future<List<dynamic>> getIds() async {
    final result = await _client.call(
      contract: _contract,
      function: _getIdsFunction,
      params: [],
    );
    return result;
  }
  
}
