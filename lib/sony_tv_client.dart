import 'package:http/http.dart' as http;

const Map<String, String> remoteButtons = {
  'Power': 'AAAAAQAAAAEAAAAVAw==',
  'Input': 'AAAAAQAAAAEAAAAlAw==',
  'SyncMenu': 'AAAAAgAAABoAAABYAw==',
  'Hdmi1': 'AAAAAgAAABoAAABaAw==',
  'Hdmi2': 'AAAAAgAAABoAAABbAw==',
  'Hdmi3': 'AAAAAgAAABoAAABcAw==',
  'Hdmi4': 'AAAAAgAAABoAAABdAw==',
  'Num1': 'AAAAAQAAAAEAAAAAAw==',
  'Num2': 'AAAAAQAAAAEAAAABAw==',
  'Num3': 'AAAAAQAAAAEAAAACAw==',
  'Num4': 'AAAAAQAAAAEAAAADAw==',
  'Num5': 'AAAAAQAAAAEAAAAEAw==',
  'Num6': 'AAAAAQAAAAEAAAAFAw==',
  'Num7': 'AAAAAQAAAAEAAAAGAw==',
  'Num8': 'AAAAAQAAAAEAAAAHAw==',
  'Num9': 'AAAAAQAAAAEAAAAIAw==',
  'Num0': 'AAAAAQAAAAEAAAAJAw==',
  'Dot(.)': 'AAAAAgAAAJcAAAAdAw==',
  'CC': 'AAAAAgAAAJcAAAAoAw==',
  'Red': 'AAAAAgAAAJcAAAAlAw==',
  'Green': 'AAAAAgAAAJcAAAAmAw==',
  'Yellow': 'AAAAAgAAAJcAAAAnAw==',
  'Blue': 'AAAAAgAAAJcAAAAkAw==',
  'Up': 'AAAAAQAAAAEAAAB0Aw==',
  'Down': 'AAAAAQAAAAEAAAB1Aw==',
  'Right': 'AAAAAQAAAAEAAAAzAw==',
  'Left': 'AAAAAQAAAAEAAAA0Aw==',
  'Confirm': 'AAAAAQAAAAEAAABlAw==',
  'Help': 'AAAAAgAAAMQAAABNAw==',
  'Display': 'AAAAAQAAAAEAAAA6Aw==',
  'Options': 'AAAAAgAAAJcAAAA2Aw==',
  'Back': 'AAAAAgAAAJcAAAAjAw==',
  'Home': 'AAAAAQAAAAEAAABgAw==',
  'VolumeUp': 'AAAAAQAAAAEAAAASAw==',
  'VolumeDown': 'AAAAAQAAAAEAAAATAw==',
  'Mute': 'AAAAAQAAAAEAAAAUAw==',
  'Audio': 'AAAAAQAAAAEAAAAXAw==',
  'ChannelUp': 'AAAAAQAAAAEAAAAQAw==',
  'ChannelDown': 'AAAAAQAAAAEAAAARAw==',
  'Play': 'AAAAAgAAAJcAAAAaAw==',
  'Pause': 'AAAAAgAAAJcAAAAZAw==',
  'Stop': 'AAAAAgAAAJcAAAAYAw==',
  'FlashPlus': 'AAAAAgAAAJcAAAB4Aw==',
  'FlashMinus': 'AAAAAgAAAJcAAAB5Aw==',
  'Prev': 'AAAAAgAAAJcAAAA8Aw==',
  'Next': 'AAAAAgAAAJcAAAA9Aw=='
};

Future<http.Response> sendRemoteCode(String code, String ip, String psk) async {
  final uri = 'http://$ip/sony/IRCC';
  String envelope = '''
    <s:Envelope
    xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"
    s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
    <s:Body>
        <u:X_SendIRCC xmlns:u="urn:schemas-sony-com:service:IRCC:1">
            <IRCCCode>$code</IRCCCode>
        </u:X_SendIRCC>
    </s:Body>
    </s:Envelope>
    ''';

  final headers = {
    'HOST': ip,
    'Accept': '*/*',
    'Content-Type': 'text/xml; charset=UTF-8',
    'SOAPACTION': '"urn:schemas-sony-com:service:IRCC:1#X_SendIRCC"',
    'Connection': 'Keep-Alive',
    'X-Auth-PSK': psk
  };

  return await http.post(
    Uri.parse(uri),
    body: envelope,
    headers: headers,
  );
}

Future<http.Response> pressButton(String key, String ip, String psk) async {
  return await sendRemoteCode(remoteButtons[key]!, ip, psk);
}

Future<http.Response> volumeUpDown(bool turnUp, String ip, String psk) async {
  final uri = 'http://$ip/sony/audio';
  String json =
      '{"id": 20, "method": "setAudioVolume", "version": "1.0", "params": [{"target":"speaker","volume":"${turnUp ? '+1' : '-1'}"}]}';

  final headers = {'Content-Type': 'application/json', 'X-Auth-PSK': psk};

  return await http.post(
    Uri.parse(uri),
    body: json,
    headers: headers,
  );
}

Future<http.Response> getMethodTypes(String ip, String psk) async {
  final uri = 'http://$ip/sony/appControl';
  String json =
      '{"id": 20, "method": "getMethodTypes", "version": "1.0", "params": [""]}';

  final headers = {'Content-Type': 'application/json', 'X-Auth-PSK': psk};

  return await http.post(
    Uri.parse(uri),
    body: json,
    headers: headers,
  );
}

Future<http.Response> getRemoteControllerInfo(String ip, String psk) async {
  final uri = 'http://$ip/sony/system';
  String json =
      '{"id": 20, "method": "getRemoteControllerInfo", "version": "1.0", "params": [""]}';

  final headers = {'Content-Type': 'application/json', 'X-Auth-PSK': psk};

  return await http.post(
    Uri.parse(uri),
    body: json,
    headers: headers,
  );
}
