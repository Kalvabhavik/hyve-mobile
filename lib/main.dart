import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import "package:google_fonts/google_fonts.dart";

import 'features/onboarding/view/onboarding_page.dart';


void main() {
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DirectAssetPlayer()));
}

class DirectAssetPlayer extends StatefulWidget {
  const DirectAssetPlayer({super.key});

  @override
  State<DirectAssetPlayer> createState() => _DirectAssetPlayerState();
}

class _DirectAssetPlayerState extends State<DirectAssetPlayer> {
  late VideoPlayerController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse("https://github.com/Kalvabhavik/video/raw/refs/heads/main/mp_%20(online-video-cutter.com).mp4"),
    )..initialize().then((_) {
      _controller.play();
      _controller.setLooping(false);
      setState(() {});
    }).catchError((_) => setState(() => _hasError = true));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 3),
                  ),
                  child: ClipOval(
                    child: _hasError
                        ? const Center(child: Icon(Icons.error, color: Colors.white))
                        : _controller.value.isInitialized
                        ? FittedBox(
                      fit: BoxFit.cover,
                      child: Container(
                          height: _controller.value.size.height,
                          width: _controller.value.size.width,
                          child: VideoPlayer(_controller)),

                    )
                        : const Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Text(
                        "Connect     Organize     Thrive  ",
                        textAlign: TextAlign.center,

                        style: GoogleFonts.aboreto(

                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 60,
                  width: 80,
                  child: GestureDetector(
                    onTap: (){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext)=>OnBoardingScreen()));
                    },
                    child: Card(

                      child: Icon(Icons.arrow_circle_right,size: 50,),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}