import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dashboard.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  FlutterTts ftts = FlutterTts();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ftts.setSpeechRate(0.5);
      var result1 = await ftts
          .speak("please, left to right drag on the screen for dashboard.");
      if (result1 == 1) {
        // Speaking
      } else {
        // Not speaking
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) async {
          if ((details.primaryVelocity ?? 0) > 0) {
            // User completed a left-to-right drag gesture
            // Start your process
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
            );
          }
        },
        child: Container(
          width: double.infinity,
          color: Colors.black87,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(image: AssetImage("assets/land.png"), width: 300),
              const SizedBox(height: 30),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 270,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: const Center(
                      child: Text(
                        "Let us give the best Assistant",
                        style: TextStyle(
                          color: Color(0xff01ACC2),
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 270,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: const Center(
                      child: Text(
                        "Get the best assistant for \n            you with us",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const SpinKitThreeInOut(
                        color: Color(0xff01ACC2),
                        size: 90,
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            CupertinoPageRoute(builder: (ctx) => const Dashboard()),
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_circle_right_rounded,
                          color: Color(0xff01ACC2),
                          size: 70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
