import 'package:flutter/material.dart';
import 'package:flutter_bandnames_app/pages/home.dart';
import 'package:flutter_bandnames_app/pages/status.dart';
import 'package:flutter_bandnames_app/services/socket_service.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SocketService())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        initialRoute: 'home',
        routes: {'home': (context) => HomePage(), 'status': (context) => StatusPage()},
      ),
    );
  }
}
