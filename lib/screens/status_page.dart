import 'package:bands_names/providers/socket_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      body: Center(
        child: Text('ServerStatus: ${socketService.serverStatus}'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.message),
        onPressed: () {
          socketService.socket!.emit(
              'emitir-mensajee', {'nombre': 'Te envio Algo Desde el boton'});
        },
      ),
    );
  }
}
