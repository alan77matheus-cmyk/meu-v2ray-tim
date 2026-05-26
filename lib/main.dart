import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermissions();
  runApp(const MyApp());
}

Future<void> _requestPermissions() async {
  final statuses = await [
    Permission.internet,
    Permission.changeNetworkState,
    Permission.changeWifiState,
  ].request();

  statuses.forEach((permission, status) {
    print('$permission: $status');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MEU V2RAY TIM',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const V2RayPage(),
    );
  }
}

class V2RayPage extends StatefulWidget {
  const V2RayPage({Key? key}) : super(key: key);

  @override
  State<V2RayPage> createState() => _V2RayPageState();
}

class _V2RayPageState extends State<V2RayPage> {
  final FlutterV2ray _flutterV2ray = FlutterV2ray();
  bool _isConnected = false;
  String _connectionStatus = 'Desconectado';
  String _statusColor = 'red';

  final String _v2rayConfig =
      'vless://b9c52619-31eb-486c-ad0a-90a5d6c550e0@ofertas.tim.com.br:443?mode=auto&path=%2F&security=tls&encryption=none&host=recargapro.azion.app&type=xhttp&sni=www.microsoft.com#MEU-SERVIDOR-TIM';

  @override
  void initState() {
    super.initState();
    _checkConnectionStatus();
  }

  Future<void> _checkConnectionStatus() async {
    try {
      final status = await _flutterV2ray.getV2RayStatus();
      setState(() {
        _isConnected = status;
        _connectionStatus = status ? 'Conectado' : 'Desconectado';
        _statusColor = status ? 'green' : 'red';
      });
    } catch (e) {
      print('Erro ao verificar status: $e');
    }
  }

  Future<void> _toggleConnection() async {
    try {
      if (_isConnected) {
        await _flutterV2ray.stopV2Ray();
        setState(() {
          _isConnected = false;
          _connectionStatus = 'Desconectado';
          _statusColor = 'red';
        });
        _showSnackBar('Desconectado com sucesso!');
      } else {
        await _flutterV2ray.startV2Ray(_v2rayConfig);
        setState(() {
          _isConnected = true;
          _connectionStatus = 'Conectado';
          _statusColor = 'green';
        });
        _showSnackBar('Conectado com sucesso!');
      }
    } catch (e) {
      _showSnackBar('Erro: ${e.toString()}');
      print('Erro na conexão: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MEU V2RAY TIM'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Status Indicator
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor == 'green'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    border: Border.all(
                      color: _statusColor == 'green' ? Colors.green : Colors.red,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _statusColor == 'green'
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 60,
                      color: _statusColor == 'green'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Status Text
                Text(
                  _connectionStatus,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _statusColor == 'green' ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _isConnected
                      ? 'V2RAY TIM está ativo'
                      : 'V2RAY TIM está inativo',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                // Configuration Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Configuração',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Servidor: MEU-SERVIDOR-TIM',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Host: recargapro.azion.app',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Protocolo: VLESS',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // Toggle Button
                SizedBox(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _toggleConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isConnected ? Colors.red : Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isConnected ? 'Desconectar' : 'Conectar',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Refresh Button
                TextButton.icon(
                  onPressed: _checkConnectionStatus,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Verificar Status'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
