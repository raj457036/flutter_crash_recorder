import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

final config = <String, dynamic>{};

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..post('/record/<code>', _exceptionRecordHandler);

Response _rootHandler(Request req) {
  return Response.ok('Working...');
}

Future<Response> _exceptionRecordHandler(Request request) async {
  final code = request.params['code'];
  final body = json.decode(await request.readAsString());
  if (config['code'] == code) {
    final basePath = config['path'];
    final dir = Directory(basePath);
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
    final now = DateTime.now();
    final fileName = "${now.millisecondsSinceEpoch}.log";
    final path = p.join(dir.path, fileName);
    final File file = File(path);
    final content =
        "${body['message']}\n\n=============\n\n${body['stack_trace']}";
    await file.writeAsString(content);
  }
  return Response.ok(json.encode({
    "recorded": true,
  }));
}

void main(List<String> args) async {
  final parser = ArgParser();
  final _tCode = Random().nextInt(1000000);
  parser.addOption("code", defaultsTo: "$_tCode");
  parser.addOption("path", defaultsTo: "./crashes");
  parser.addOption("port", defaultsTo: Platform.environment['PORT'] ?? "9843");
  parser.addOption("host", defaultsTo: "0.0.0.0");
  final result = parser.parse(args);

  final code = result["code"];
  final path = result['path'];
  config["code"] = code;
  config["path"] = path;
  final host = result["host"];

  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress(host, type: InternetAddressType.IPv4);
  // Configure a pipeline that logs requests.
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(result["port"]);
  final server = await serve(handler, ip, port);

  final currentNetworks = await NetworkInterface.list();

  print('Server listening on port ${server.port}');

  if (currentNetworks.isNotEmpty) {
    final cn = currentNetworks.first;

    print("\nIn you flutter app use the below config\n");
    print("Host: ${cn.addresses.first.address}");
    print("Port: $port");
    print("Code: $code");
    print("Crash Reports will be saved at $path");
  }
}
