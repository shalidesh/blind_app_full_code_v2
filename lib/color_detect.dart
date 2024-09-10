import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'home.dart';

class ColorDetect extends StatefulWidget {
  @override
  _ColorDetectState createState() => _ColorDetectState();
}

class _ColorDetectState extends State<ColorDetect> {
  late CameraController _controller;
  List<CameraDescription> cameras = [];
  int _taps = 0;
  FlutterTts ftts = FlutterTts();
  late String successValue;
  late String recommendation;

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras.length > 0) {
        setState(() {
          _controller = CameraController(cameras[0], ResolutionPreset.high);
          _controller.initialize().then((_) {
            if (!mounted) {
              return;
            }
            setState(() {});
          });
        });
      } else {
        print("No camera available");
      }
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ftts.setSpeechRate(0.5);
      var result1 = await ftts.speak(
          "please,double tap the screen to capture image.drag screen from right to left for main menu ");
      if (result1 == 1) {
        // Speaking
      } else {
        // Not speaking
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void onCameraViewTapped() async {
    setState(() {
      _taps++;
    });
    if (_taps == 2) {
      _taps = 0;
      XFile file = await _controller.takePicture();
      String base64Image = base64Encode(await file.readAsBytes());
      var response = await http.post(
        Uri.parse('http://192.168.43.4/api/save'),
        body: {'image': base64Image},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        print(responseBody);
        if (responseBody.containsKey('sucess') &&
            responseBody['sucess'] != null) {
          successValue = responseBody['sucess'];
          recommendation = responseBody['reccomend'];
          // ...
        } else {
          successValue = "";
          recommendation = "backend is not working";

          // Handle the case where the success key does not exist or its value is null
        }

        // Play text-to-speech with response body
        var result = await ftts.speak(recommendation);
        if (result == 1) {
          // Speaking
        } else {
          // Not speaking
        }

        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Response"),
              content: Text(successValue),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller.value.isInitialized) {
      return Container();
    }

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx < 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        }
      },
      onTap: onCameraViewTapped,
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: CameraPreview(_controller),
      ),
    );
  }
}
