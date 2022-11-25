import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bandnames_app/models/band_model.dart';
import 'package:flutter_bandnames_app/services/socket_service.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BandModel> _bands = [];

  @override
  void initState() {
    final SocketService socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('current-bands', _handleCurrentBands);

    super.initState();
  }

  void _handleCurrentBands(dynamic data) {
    _bands = (data as List).map((band) => BandModel.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final SocketService socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('current-bands');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SocketService socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: Icon(
              Icons.check_circle,
              color: socketService.serverStatus == ServerStatus.online ? Colors.blue[300] : Colors.red,
            ),
          )
        ],
        elevation: 1,
        title: const Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _pieChart(),
          Expanded(child: ListView.builder(itemCount: _bands.length, itemBuilder: (BuildContext context, int i) => _BandTile(band: _bands[i]))),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewBand,
        elevation: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _pieChart() {
    Map<String, double> dataMap = {};
    for (var band in _bands) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    }

    final List<Color> colorList = [
      Colors.blue[50]!,
      Colors.blue[200]!,
      Colors.yellow[50]!,
      Colors.yellow[200]!,
      Colors.pink[50]!,
      Colors.pink[200]!,
    ];

    return SizedBox(
        width: double.infinity,
        height: 200,
        child: dataMap.isEmpty
            ? Container()
            : PieChart(
                dataMap: dataMap,
                animationDuration: const Duration(milliseconds: 800),
                chartLegendSpacing: 32,
                chartRadius: MediaQuery.of(context).size.width / 3.2,
                colorList: colorList,
                initialAngleInDegree: 0,
                chartType: ChartType.ring,
                ringStrokeWidth: 32,
                centerText: "Votes  ",
                legendOptions: const LegendOptions(
                  showLegendsInRow: false,
                  legendPosition: LegendPosition.right,
                  showLegends: true,
                  legendShape: BoxShape.circle,
                  legendTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ));
  }

  void _addNewBand() {
    final TextEditingController textController = TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: const Text('New Band Name'),
                content: TextField(
                  controller: textController,
                ),
                actions: [
                  MaterialButton(
                    onPressed: () => _addBandToList(textController.text),
                    elevation: 5,
                    textColor: Colors.blue,
                    child: const Text('Add'),
                  )
                ],
              ));
    } else {
      showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
                title: const Text('New Band Name'),
                content: TextField(
                  controller: textController,
                ),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => _addBandToList(textController.text),
                    isDefaultAction: true,
                    child: const Text('Add'),
                  ),
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    onPressed: () => Navigator.pop(context),
                    isDefaultAction: true,
                    child: const Text('Dismiss'),
                  )
                ],
              ));
    }
  }

  void _addBandToList(String bandName) {
    if (bandName.length > 1) {
      final SocketService socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit('add-band', {'name': bandName});
      setState(() {});
    }

    Navigator.pop(context);
  }
}

class _BandTile extends StatelessWidget {
  const _BandTile({Key? key, required this.band}) : super(key: key);

  final BandModel band;

  @override
  Widget build(BuildContext context) {
    final SocketService socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => socketService.emit('delete-band', {'id': band.id}),
      background: Container(
        alignment: Alignment.centerLeft,
        color: Colors.red,
        padding: const EdgeInsets.only(left: 25.0),
        child: const Text(
          'Delete band',
          style: TextStyle(color: Colors.white),
        ),
      ),
      child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: Text(band.name.substring(0, 2)),
          ),
          title: Text(band.name),
          trailing: Text(
            '${band.votes}',
            style: const TextStyle(fontSize: 20),
          ),
          onTap: () => socketService.emit('vote-band', {'id': band.id})),
    );
  }
}
