import 'package:flutter/material.dart';
import 'package:flutter_bandnames_app/services/socket_service.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Server status: ${socketService.serverStatus}')]),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        onPressed: () {
          socketService.emit('emit-message', {'nombre': 'Flutter'});
        },
        child: const Icon(Icons.message),
      ),
    );
  }
}
