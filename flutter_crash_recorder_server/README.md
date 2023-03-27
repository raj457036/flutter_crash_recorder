A crash local recorder server for flutter pipeline plugin

# Configure Your App

Visit [Flutter Pipeline](https://pub.dev/packages/flutter_pipeline)

# Installation

```
flutter pub global activate fcr_server
```

# Running the server

```
fcr
```

This will start the crash recorder server at **root** of your project

**OUTPUT**

```
Server listening on port 9843

In you flutter app use the below config

Host: 192.168.0.113
Port: 9843
Code: 901805 // a secret code for secure communication
Crash Reports will be saved at ./crashes
```

### Where can i see crash logs?

By default fcr will write log files at **./crashes** wherever you run the fcr.

### Have Questions?

Lets discuss in github
