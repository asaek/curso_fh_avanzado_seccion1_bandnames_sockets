import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

enum ServerStatus {
  Online,
  Offline,
  Connecting,
}

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket? _socket;

  ServerStatus get serverStatus => this._serverStatus;

  IO.Socket? get socket => this._socket;

  SocketService() {
    _initConfig();
  }
  void _initConfig() {
    this._socket = IO.io("http://localhost:3000", {
      'transports': ['websocket'],
      'autoConnect': true
    });
    // Otra manera de hacerlo yeah !!
    // _socket = IO.io(
    //     "http://localhost:3000",
    //     OptionBuilder()
    //         .setTransports(['websocket'])
    //         .enableAutoConnect()
    //         .build());

    this._socket!.onConnect((_) {
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
      _socket!.emit(
        'mensajeID',
        {'nombre': 'We estoy conectado desde la app de flutter increible'},
      );
    });
    this._socket!.on('event', (data) => print(data));
    this._socket!.onDisconnect((_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });
    this._socket!.on('mensaje-appflutter', (payload) {
      print('nuevo-mensaje: $payload');
      print('Nombre: ${payload['nombre']}');
      print('Mensaje: ${payload['mensaje']}');
      print(payload.containsKey('mensaje2')
          ? payload['mensaje2']
          : 'No hay mensaje2');
    });
  }
}
