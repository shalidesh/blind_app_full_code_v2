import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dashboard.dart';
import 'home.dart';

class SuperMarket extends StatefulWidget {
  @override
  _SuperMarketState createState() => _SuperMarketState();
}

class _SuperMarketState extends State<SuperMarket> {
  List<dynamic>? _recognitions;

  late CameraController controller;
  late FlutterVision vision;
  late List<Map<String, dynamic>> yoloResults;
  CameraImage? cameraImage;
  bool isLoaded = false;
  bool isDetecting = false;
  int _taps = 0;
  FlutterTts ftts = FlutterTts();
  late Map<String, dynamic> label;

  @override
  void initState() {
    super.initState();
    initCamera();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ftts.setSpeechRate(0.5);
      var result1 = await ftts.speak(
          "please,left to right drag on the screen for start detection and down to up drag on the screen for stop.");
      if (result1 == 1) {
        // Speaking
      } else {
        // Not speaking
      }
    });
  }

  Future<void> loadYoloModel() async {
    await vision.loadYoloModel(
        labels: 'assets/supermarket/supermarket_2.txt',
        modelPath: 'assets/supermarket/supermarket_2.tflite',
        modelVersion: "yolov5",
        numThreads: 2,
        useGpu: false);
    setState(() {
      isLoaded = true;
    });
  }

  initCamera() async {
    final cameras = await availableCameras();
    vision = FlutterVision();
    controller = CameraController(cameras[0], ResolutionPreset.low);
    controller.initialize().then((value) {
      loadYoloModel().then((value) {
        setState(() {
          isLoaded = true;
          isDetecting = false;
          yoloResults = [];
        });
      });
    });
  }

  Future<void> yoloOnFrame(CameraImage cameraImage) async {
    final result = await vision.yoloOnFrame(
        bytesList: cameraImage.planes.map((plane) => plane.bytes).toList(),
        imageHeight: cameraImage.height,
        imageWidth: cameraImage.width,
        iouThreshold: 0.4,
        confThreshold: 0.4,
        classThreshold: 0.5);
    if (result.isNotEmpty) {
      setState(() {
        yoloResults = result;
      });

      for (var object in yoloResults) {
        if (object['box'][4] * 100 > 20) {
          var result1 = await ftts.speak(object['tag']);
          if (result1 == 1) {
            // Speaking
          } else {
            // Not speaking
          }
        }
      }
    }
  }

  Future<void> startDetection() async {
    setState(() {
      isDetecting = true;
    });
    if (controller.value.isStreamingImages) {
      return;
    }
    await controller.startImageStream((image) async {
      if (isDetecting) {
        cameraImage = image;
        yoloOnFrame(image);
      }
    });
  }

  Future<void> stopDetection() async {
    setState(() {
      isDetecting = false;
      yoloResults.clear();
    });
  }

  List<Widget> displayBoxesAroundRecognizedObjects(Size screen) {
    if (yoloResults.isEmpty) return [];
    double factorX = screen.width / (cameraImage?.height ?? 1);
    double factorY = screen.height / (cameraImage?.width ?? 1);
    Color colorPick = const Color.fromARGB(255, 50, 233, 30);

    return yoloResults.map((result) {
      if (result['box'][4] * 100 > 20) {
        return Positioned(
          left: result["box"][0] * factorX,
          top: result["box"][1] * factorY,
          width: (result["box"][2] - result["box"][0]) * factorX,
          height: (result["box"][3] - result["box"][1]) * factorY,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              border: Border.all(color: Colors.pink, width: 2.0),
            ),
            child: Text(
              "${result['tag']} ${result['box'][4] * 100}",
              style: TextStyle(
                background: Paint()..color = colorPick,
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
          ),
        );
      } else {
        // Return an empty container for other tags
        return Container();
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    if (!isLoaded) {
      return const Scaffold(
        body: Center(
          child: Text("Model not loaded, waiting for it"),
        ),
      );
    }
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) async {
          if ((details.primaryVelocity ?? 0) > 0) {
            // User completed a left-to-right drag gesture
            // Start your process
            var result1 = await ftts.speak("started");
            if (result1 == 1) {
              // Speaking
            } else {
              // Not speaking
            }
            await startDetection();
          }
        },
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx < 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
          }
        },
        onVerticalDragEnd: (details) async {
          if ((details.primaryVelocity ?? 0) < 0) {
            // User completed a down-to-up drag gesture
            // Start your process here
            var result1 = await ftts.speak("stoped");
            if (result1 == 1) {
              // Speaking
            } else {
              // Not speaking
            }
            stopDetection();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: CameraPreview(
                controller,
              ),
            ),
            ...displayBoxesAroundRecognizedObjects(size),
            Positioned(
              bottom: 75,
              width: MediaQuery.of(context).size.width,
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      width: 5, color: Colors.white, style: BorderStyle.solid),
                ),
                child: isDetecting
                    ? IconButton(
                        onPressed: () async {
                          stopDetection();
                        },
                        icon: const Icon(
                          Icons.stop,
                          color: Colors.red,
                        ),
                        iconSize: 50,
                      )
                    : IconButton(
                        onPressed: () async {
                          await startDetection();
                        },
                        icon: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ),
                        iconSize: 50,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    controller.dispose();
    await vision.closeYoloModel();
  }
}
