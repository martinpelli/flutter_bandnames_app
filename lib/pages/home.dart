import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bandnames_app/models/band_model.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BandModel> _bands = [
    BandModel(id: "1", name: "Metallica", votes: 5),
    BandModel(id: "2", name: "Bon Jovi", votes: 9),
    BandModel(id: "3", name: "Pantera", votes: 2),
    BandModel(id: "4", name: "Kiss", votes: 15),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(itemCount: _bands.length, itemBuilder: (BuildContext context, int i) => _BandTile(band: _bands[i])),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewBand,
        child: Icon(Icons.add),
        elevation: 1,
      ),
    );
  }

  void _addNewBand() {
    final TextEditingController textController = TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
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
      _bands.add(BandModel(id: DateTime.now().toString(), name: bandName, votes: 0));
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
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {},
      background: Container(
        alignment: Alignment.centerLeft,
        color: Colors.red,
        padding: EdgeInsets.only(left: 25.0),
        child: Text(
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
      ),
    );
  }
}
