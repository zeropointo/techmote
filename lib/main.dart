import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';
import 'package:techmote/sony_tv_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Techmote: Sony Bravia'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _jsonString = '{ "default": 1 }';
  String _soapString = 'default';
  Map<String, dynamic>? _jsonMap;
  bool powerIsOn = false;

  @override
  void initState() {
    _setJsonString(_jsonString);
    super.initState();
  }

  void _setJsonString(String jsonString) {
    setState(() {
      _jsonString = jsonString;
      _jsonMap = json.decode(jsonString);
    });
  }

  void _setSoapString(String soapString) {
    setState(() {
      _soapString = soapString;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: ListView(children: [
          JsonViewer(_jsonMap),
          Text(_soapString),
          TextButton(
              onPressed: () async {
                powerIsOn = !powerIsOn;
                final response = await getRemoteControllerInfo();
                _setJsonString(response.body);
              },
              child: const Text('GET REMOTE INFO')),
          const Divider(),
          for (var k in remoteButtons.keys)
            TextButton(
                onPressed: () async {
                  powerIsOn = !powerIsOn;
                  final code = remoteButtons[k];
                  final response = await sendRemoteCode(code!);
                  _setSoapString(response.body.toString());
                },
                child: Text(k)),
        ]),
      ),
    );
  }
}
