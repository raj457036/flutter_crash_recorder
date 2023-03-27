# Flutter Pipeline

A crash recorder plugin compatible with FCR and all real time crash reporting tool too.

## Features

- Can Record Exceptions from every possible source in your app
- Compatible with All real time crash reporting Tools
- Compatible with [FCR](https://pub.dev/packages/fcr_server)
- Will make your life much easy when working with **Flutter Grey Screen** in release mode.

## Getting started

1. Install [FCR server](https://pub.dev/packages/fcr_server)

```
flutter pub global activate fcr_server
```

2. Running the Server in **Root** of your project

```
fcr
```

This will start the crash recorder server at **root** of your project

**Output:**

```
Server listening on port 9843

In you flutter app use the below config

Host: 192.168.0.113
Port: 9843
Code: 901805 // a secret code for secure communication
Crash Reports will be saved at ./crashes
```

2. Setup Flutter Pipeline in your app

- Add `flutter_pipeline` in `pubspec.yaml`

```yaml

dependencies:
  flutter:
    sdk: flutter
  ...
  flutter_pipeline: <latest_version>
```

- Configure Your runApp

```dart

// main.dart

import 'package:flutter_pipeline/flutter_pipeline.dart';

void main() {
    ...

    final pipeline = FlutterPipeline.i;
    pipeline.enableFCRLogging(
        host: "192.168.0.113", // from above step
        port: 9843, // from above step
        code: 901805, // from above step
        recordCrashes: kReleaseMode, // to only record crash in release mode
    );
    pipeline.run(() => runApp(MyApp()));
}

```

## How to setup Firebase Crashlytics, Sentry, DataDog, etc.

### To add handler for Flutter Error

```dart

// Firebase Crashlytics Example
pipeline.onErrorCallbacks.add(
    FirebaseCrashlytics.instance.recordFlutterFatalError
)
```

### To add handler for Platform Exceptions

```dart

// Firebase Crashlytics Example
pipeline.onPlatformErrorCallbacks.add(
    (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack, fatal: true)
)
```

### To add handler for Zone Errors

```dart

// Sentry Example
pipeline.onZoneErrorCallbacks.add(
    (exception, stackTrace) async {
        await Sentry.captureException(exception, stackTrace: stackTrace);
    }
)


```

## Additional information

Have anything to discuss? please create an issue/start a discussion in github
