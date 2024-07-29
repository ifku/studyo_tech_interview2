import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studyo Tech interview 2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      home: const Homepage(),
    );
  }
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  var deviceInfoChannel = const MethodChannel("get-device-info");
  var videoInfoChannel = const MethodChannel("get-video-info");
  Map<String, dynamic> _deviceInfo = {};
  Map<String, dynamic> _videoInfo = {};

  Future<void> _getDeviceInfo() async {
    try {
      final result = await deviceInfoChannel.invokeMethod('getDeviceInfo');
      setState(() {
        _deviceInfo = Map<String, dynamic>.from(result);
      });
    } on PlatformException catch (e) {
      print("Failed to get device info: '${e.message}'.");
    }
  }

  Future<void> _getVideoInfo() async {
    try {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.video, allowMultiple: false);

      if (result != null) {
        String filePath = result.files.single.path!;
        final videoInfo = await videoInfoChannel
            .invokeMethod('getVideoInfo', {'videoPath': filePath});
        setState(() {
          _videoInfo = Map<String, dynamic>.from(videoInfo);
        });
      }
    } on PlatformException catch (e) {
      print("Failed to get video info: '${e.message}'.");
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _getDeviceInfo,
              child: const Text("Get Device Info"),
            ),
            ElevatedButton(
              onPressed: _getVideoInfo,
              child: const Text("Get Video Info"),
            ),
            if (_deviceInfo.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text("Device Info:"),
              for (var entry in _deviceInfo.entries)
                Text("${entry.key}: ${entry.value}"),
            ],
            if (_videoInfo.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text("Video Info:"),
              for (var entry in _videoInfo.entries)
                Text("${entry.key}: ${entry.value}"),
            ],
          ],
        ),
      ),
    );
  }
}
