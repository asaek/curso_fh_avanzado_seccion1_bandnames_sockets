import 'dart:io';

import 'package:bands_names/models/models.dart';
import 'package:bands_names/providers/socket_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    // Band(id: '1', name: 'Kyary Pamyu Pamyu', votes: 5),
    // Band(id: '2', name: 'Perfume', votes: 1),
    // Band(id: '3', name: 'Armin', votes: 4),
    // Band(id: '4', name: 'PvD', votes: 6),
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket!.on('active-bands', _handleActiveBandsMetodo);

    // socketService.socket!.on('active-bands', (data) {
    //   this.bands =
    //       (data as List).map((unaBand) => Band.fromMap(unaBand)).toList();
    //   setState(() {});
    //   print(data);
    // });
    super.initState();
  }

  _handleActiveBandsMetodo(dynamic payload) {
    this.bands =
        (payload as List).map((unaBand) => Band.fromMap(unaBand)).toList();
    setState(() {});
    print(payload);
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket!.off('active-bands');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BandNames',
          style: TextStyle(
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online)
                ? Icon(Icons.check_circle, color: Colors.greenAccent)
                : Icon(Icons.offline_bolt, color: Colors.red),
          ),
        ],
      ),
      body: Column(
        children: [
          if (bands.isNotEmpty) _showGrapics(),
          Expanded(
            child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (BuildContext context, int index) =>
                    _bandTile(bands[index])),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewband,
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id!),
      direction: DismissDirection.startToEnd,
      onDismissed: (DismissDirection direction) =>
          socketService.socket!.emit('DeleteBand', {'id': band.id}),
      background: Container(
        padding: EdgeInsets.all(5),
        color: Colors.red[300],
        alignment: Alignment.centerLeft,
        child: const Text(
          'Borrar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            band.name!.substring(0, 3),
          ),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name!),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () => socketService.socket!
            .emit('Voto-banda', {'id': band.id, 'nombre': band.name}),
      ),
    );
  }

  addNewband() {
    final textController = TextEditingController();
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Dodonpa'),
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
                child: Text('Ajales'),
                elevation: 30,
                textColor: Colors.blue,
                onPressed: () => addBandToListIphone(textController.text))
          ],
        ),
      );
    }
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('New Band Name:'),
        content: CupertinoTextField(
          controller: textController,
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction:
                true, // Dispara la accion al presionar enter en el teclado del iphone
            child: Text('Add'),
            onPressed: () => addBandToListIphone(textController.text),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void addBandToListIphone(String name) {
    if (name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);

      // bands.add(new Band(
      //   id: DateTime.now().toString(),
      //   name: name,
      //   votes: 0,
      // ));
      socketService.socket!.emit('NuevaBanda', {'nombre': name});

      // setState(() {});
    }

    Navigator.pop(context);
  }

  Widget _showGrapics() {
    Map<String, double> dataMap = {};

    bands.forEach((band) {
      dataMap[band.name!] = band.votes!.toDouble();
    });
    final List<Color> colorList = [
      Colors.blue[50]!,
      Colors.blue[100]!,
      Colors.blue[200]!,
      Colors.blue[300]!,
      Colors.blue[400]!,
      Colors.blue[500]!,
      Colors.blue[600]!,
      Colors.blue[700]!,
      Colors.blue[800]!,
      Colors.blue[900]!,
    ];
    return Container(
        width: double.infinity,
        height: 300,
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 32,
          chartRadius: MediaQuery.of(context).size.width / 2.2,
          colorList: colorList,
          initialAngleInDegree: 100,
          chartType: ChartType.disc,
          ringStrokeWidth: 32,
          centerText: "Artistas",
          legendOptions: const LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendShape: BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: const ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: true, //para porcentajes
            showChartValuesOutside: false,
            decimalPlaces: 1,
          ),
          // gradientList: ---To add gradient colors---
          // emptyColorGradient: ---Empty Color gradient---
        ));
  }
}
