import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techmote/sony_tv_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Techmote: Sony Bravia',
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
  String _soapString = 'default';
  String? _ip;
  String? _psk;
  Map<String, dynamic> _jsonMap = remoteButtons;

  TextEditingController ipTextFieldController = TextEditingController()
    ..text = '';
  TextEditingController pskTextFieldController = TextEditingController()
    ..text = '';

  @override
  void initState() {
    getStoredIpPsk().then(
      (value) {
        _ip = value['ip']!;
        _psk = value['psk']!;
        ipTextFieldController.text = value['ip']!;
        pskTextFieldController.text = value['psk']!;
        getRemoteControlButtons(_ip!, _psk!).then((value) {
          if (value.isNotEmpty) {
            setState(() {
              _jsonMap = value;
            });
          }
        });
      },
    );

    super.initState();
  }

  void _setJsonMap(String jsonString) {
    setState(() {
      _jsonMap = json.decode(jsonString);
    });
  }

  void _setSoapString(String soapString) {
    setState(() {
      _soapString = soapString;
    });
  }

  void _setIp(String ip) {
    setStoredIpPsk(ip, _psk!);
    setState(() {
      _ip = ip;
    });
  }

  void _setPsk(String psk) {
    setStoredIpPsk(_ip!, psk);
    setState(() {
      _psk = psk;
    });
  }

  Future<Map<String, String>> getStoredIpPsk() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('IP_KEY');
    final psk = prefs.getString('PSK_KEY');

    return {'ip': ip ?? '0.0.0.0', 'psk': psk ?? 'unknown'};
  }

  Future<void> setStoredIpPsk(String ip, String psk) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('IP_KEY', ip);
    prefs.setString('PSK_KEY', psk);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          final buttonSize = constraints.maxWidth / 3;

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MaterialButton(
                      onPressed: () => pressButton('Power', _ip!, _psk!),
                      shape: const CircleBorder(),
                      color: Colors.deepPurple,
                      child: const Icon(
                        Icons.power_settings_new,
                        color: Colors.white,
                        size: 24,
                      )),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          controller: ipTextFieldController,
                          onSubmitted: (value) {
                            _setIp(value);
                          },
                          decoration: const InputDecoration(
                              fillColor: Colors.deepPurple,
                              filled: true,
                              isDense: true,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 10, 10, 10),
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 5.0),
                              ),
                              labelText: 'IP Address',
                              labelStyle: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          controller: pskTextFieldController,
                          onSubmitted: (value) {
                            _setPsk(value);
                          },
                          decoration: const InputDecoration(
                              fillColor: Colors.deepPurple,
                              filled: true,
                              isDense: true,
                              contentPadding:
                                  EdgeInsets.fromLTRB(10, 10, 10, 10),
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 5.0),
                              ),
                              labelText: 'Pre Shared Key',
                              labelStyle: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ]),
              ),
              Expanded(
                flex: 1,
                child: ListView(
                  children: [
                    for (var k in _jsonMap.keys)
                      TextButton(
                          onPressed: () async {
                            final response = await pressButton(k, _ip!, _psk!);
                            _setSoapString(response.body.toString());
                          },
                          child: Text(k)),
                    JsonViewer(_jsonMap),
                    Text(
                      _soapString,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, mainAxisSpacing: 0),
                  children: [
                    SizedBox(
                      width: buttonSize,
                      height: buttonSize,
                    ),
                    SizedBox(
                        width: buttonSize,
                        height: buttonSize,
                        child: MaterialButton(
                            onPressed: () => pressButton('Up', _ip!, _psk!),
                            shape: const CircleBorder(),
                            color: Colors.deepPurple,
                            child: const Icon(
                              Icons.arrow_upward,
                              color: Colors.white,
                              size: 24,
                            ))),
                    SizedBox(
                      width: buttonSize,
                      height: buttonSize,
                    ),
                    SizedBox(
                        width: buttonSize,
                        height: buttonSize,
                        child: MaterialButton(
                            onPressed: () => pressButton('Left', _ip!, _psk!),
                            shape: const CircleBorder(),
                            color: Colors.deepPurple,
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ))),
                    SizedBox(
                        width: buttonSize,
                        height: buttonSize,
                        child: MaterialButton(
                            onPressed: () =>
                                pressButton('Confirm', _ip!, _psk!),
                            shape: const CircleBorder(),
                            color: Colors.deepPurple,
                            child: const Icon(
                              Icons.circle,
                              color: Colors.white,
                              size: 24,
                            ))),
                    SizedBox(
                        width: buttonSize,
                        height: buttonSize,
                        child: MaterialButton(
                            onPressed: () => pressButton('Right', _ip!, _psk!),
                            shape: const CircleBorder(),
                            color: Colors.deepPurple,
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 24,
                            ))),
                    SizedBox(
                      width: buttonSize,
                      height: buttonSize,
                    ),
                    SizedBox(
                        width: buttonSize,
                        height: buttonSize,
                        child: MaterialButton(
                            onPressed: () => pressButton('Down', _ip!, _psk!),
                            shape: const CircleBorder(),
                            color: Colors.deepPurple,
                            child: const Icon(
                              Icons.arrow_downward,
                              color: Colors.white,
                              size: 24,
                            ))),
                    SizedBox(
                      width: buttonSize,
                      height: buttonSize,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                      onPressed: () => pressButton('VolumeDown', _ip!, _psk!),
                      shape: const CircleBorder(),
                      color: Colors.deepPurple,
                      child: const Icon(
                        Icons.volume_down,
                        color: Colors.white,
                        size: 24,
                      )),
                  MaterialButton(
                      onPressed: () => pressButton('VolumeUp', _ip!, _psk!),
                      shape: const CircleBorder(),
                      color: Colors.deepPurple,
                      child: const Icon(
                        Icons.volume_up,
                        color: Colors.white,
                        size: 24,
                      )),
                  MaterialButton(
                      onPressed: () => pressButton('Home', _ip!, _psk!),
                      shape: const CircleBorder(),
                      color: Colors.deepPurple,
                      child: const Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 24,
                      )),
                  MaterialButton(
                      onPressed: () => pressButton('Back', _ip!, _psk!),
                      shape: const CircleBorder(),
                      color: Colors.deepPurple,
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      )),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
