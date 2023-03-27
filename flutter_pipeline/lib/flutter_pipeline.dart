library flutter_pipeline;

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart';

/// {@template flutter_error_pipeline}
/// A utility wrapper for handling all the system errors.
/// {@endtemplate}
class FlutterPipeline {
  /// {@macro flutter_error_pipeline}
  FlutterPipeline._() {
    FlutterError.onError = (details) {
      for (var callbacks in onErrorCallbacks) {
        callbacks(details);
      }
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      for (var callback in onPlatformErrorCallbacks) {
        callback(error, stack);
      }
      return true;
    };
  }

  dynamic code;
  String? host;
  bool serverRunning = false, recordCrashes = true, writeLog = false;
  int port = 9843;

  static FlutterPipeline? _instance;

  /// get an instance of this Pipeline
  static FlutterPipeline get i {
    _instance ??= FlutterPipeline._();
    return _instance!;
  }

  /// add listeners for `FlutterError.onError`
  final onErrorCallbacks = <void Function(FlutterErrorDetails)>[];

  /// add listeners for `PlatformDispatcher.instance.onError`
  final onPlatformErrorCallbacks = <void Function(Object, StackTrace)>[];

  /// add listeners for errors triggers by the active zone.
  final onZoneErrorCallbacks = <void Function(Object, StackTrace)>[];

  Future<void> record(
    String message, {
    StackTrace? stackTrace,
  }) async {
    if (!(recordCrashes && host != null && code != null)) return;

    final HttpClient client = HttpClient();
    try {
      HttpClientRequest request = await client.post(
        host!,
        port,
        "/record/$code",
      );
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        "application/json; charset=UTF-8",
      );
      request.write(json.encode({
        "message": message,
        "stack_trace": stackTrace.toString(),
      }));
      final response = await request.close();
      if (writeLog) {
        if (response.statusCode == 200) {
          // ignore: avoid_print
          print("Crash Reported Successfully");
        } else {
          final data = await response.transform(utf8.decoder).join();
          // ignore: avoid_print
          print("Something went wrong: $data");
        }
      }
    } finally {
      client.close();
    }
  }

  /// Enable FCR logging
  /// Flutter Crash Reporter (FCR) can record crash even in release mode
  void enableFCRLogging({
    required String host,
    required dynamic code,
    int port = 9843,
    bool recordCrashes = true,
    bool logInRelease = false,
  }) {
    this.host = host;
    this.code = code;
    this.port = port;
    this.recordCrashes = recordCrashes;
    writeLog = logInRelease;

    onErrorCallbacks.add(
      (details) {
        record(details.exceptionAsString(), stackTrace: details.stack);
      },
    );
    onPlatformErrorCallbacks.add(
      (error, stackTrace) {
        record(error.toString(), stackTrace: stackTrace);
      },
    );
    onZoneErrorCallbacks.add(
      (error, stackTrace) {
        record(error.toString(), stackTrace: stackTrace);
      },
    );
  }

  /// enable logging for errors
  void enableBasicLogging() {
    onErrorCallbacks.add(
      (details) {
        log(details.exceptionAsString(), stackTrace: details.stack);
      },
    );
    onPlatformErrorCallbacks.add(
      (error, stackTrace) {
        log(
          error.toString(),
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
    onZoneErrorCallbacks.add(
      (error, stackTrace) {
        log(
          error.toString(),
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  /// Runs [body] in its own error zone combined with
  /// the flutter error pipeline.
  R? run<R>(
    R Function() body, {
    Map<Object?, Object?>? zoneValues,
    ZoneSpecification? zoneSpecification,
  }) {
    final defaultSpec = ZoneSpecification(print: (self, parent, zone, line) {
      parent.print(zone, "App: $line");
    });
    return runZonedGuarded<R>(
      body,
      _onZoneError,
      zoneValues: zoneValues,
      zoneSpecification: zoneSpecification ?? defaultSpec,
    );
  }

  void _onZoneError(error, stackTrace) {
    for (var callback in onZoneErrorCallbacks) {
      callback(
        error,
        stackTrace,
      );
    }
  }
}
