import 'dart:developer';
import 'dart:typed_data';

import 'package:artifex_ai/consts.dart';
import 'package:artifex_ai/screens/image_studio_screen.dart';
import 'package:artifex_ai/screens/image_to_text_chat_screen.dart';
import 'package:artifex_ai/screens/recent_images_screen.dart';
import 'package:artifex_ai/screens/settings_screen.dart';
import 'package:artifex_ai/screens/text_to_image_screen.dart';
import 'package:artifex_ai/screens/text_to_text_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AssetEntity> images = [];
  bool getImages = false;

  Future<void> fetchAssets() async {
    images = await PhotoManager.getAssetListRange(
      start: 0,
      end: 20,
      type: RequestType.image,
    );
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAssets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,

      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // CustomContainer(icon: Icons.edit),
                  CustomContainer(
                    icon: Icons.settings,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomItem(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ImageStudioScreen(source: ImageSource.camera),
                        ),
                      );
                    },
                    title: "Camera",
                    icon: Icons.camera_alt_outlined,
                  ),
                  CustomItem(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ImageStudioScreen(source: ImageSource.gallery),
                        ),
                      );
                    },
                    title: "Gallery",
                    icon: Icons.photo_library_outlined,
                  ),
                ],
              ),
              SizedBox(
                height: 50,
                width: 50,
                child: Divider(color: Theme.of(context).colorScheme.primary),
              ),

              Container(
                height: 200,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        "assets/ai_image.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    Opacity(
                      opacity: 0.4,
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),

                          gradient: artifexGradient,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      top: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Create with ",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.inversePrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "generative AI",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.inversePrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Try out the latest innovations.",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.inversePrimary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomPositionedButton(
                      icon: Icons.chat_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TextToTextScreen(),
                          ),
                        );
                      },
                      title: "Chat",
                      left: 10,
                      top: 120,
                    ),
                    CustomPositionedButton(
                      icon: Icons.text_fields_sharp,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageToTextScreen(),
                          ),
                        );
                      },
                      title: "describe",
                      right: 120,
                      top: 120,
                    ),
                    CustomPositionedButton(
                      icon: Icons.stars,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TextToImageScreen(),
                          ),
                        );
                      },
                      title: "Imagine",
                      right: 10,
                      top: 120,
                    ),
                  ],
                ),
              ),

              // bodyContainer(context),
              // aicontainer(context),
            ],
          ),
        ),
      ),
    );
  }

  allow_permission(BuildContext context) {
    PhotoManager.clearFileCache();
    PhotoManager.requestPermissionExtend().then((PermissionState state) async {
      log("the state is: ${state.isAuth}");
      if (state.isAuth) {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => RecentImagesScreen()),
        // );

        images = await PhotoManager.getAssetListRange(
          start: 0,
          end: 20,
          type: RequestType.image,
        );
        setState(() {});
      } else {
        PhotoManager.openSetting();
      }
    });
  }

  Container bodyContainer(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
      decoration: BoxDecoration(
        color: Color(0xff321f1a),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(15),
                child: Image.asset("assets/start_image.png"),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "EDIT YOUR PHOTOS",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Use tools like crop,rotate ",

                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        "resize, emojis, paint, filters,",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text("etc.", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 30,
            width: MediaQuery.sizeOf(context).width * 0.85,
            child: Divider(color: Color(0xff412e29), thickness: 2),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Open image from ",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  custom_button("Gallery", Icons.photo_outlined, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ImageStudioScreen(source: ImageSource.gallery);
                        },
                      ),
                    );
                  }),
                  SizedBox(width: 10),
                  custom_button("Camera", Icons.camera_alt_outlined, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ImageStudioScreen(source: ImageSource.camera),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container aicontainer(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
      decoration: BoxDecoration(
        color: Color(0xff321f1a),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(15),
                  child: Image.asset(
                    "assets/ai_image.png",
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "USE AI ",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Chat with Ai,",

                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        "Generate images ",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text("etc.", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(
            height: 30,
            width: MediaQuery.sizeOf(context).width * 0.85,
            child: Divider(color: Color(0xff412e29), thickness: 2),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Start ",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  custom_button("Chat", Icons.chat_bubble_outline_outlined, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return TextToTextScreen();
                        },
                      ),
                    );
                  }),
                  SizedBox(width: 10),
                  custom_button("Generate", Icons.generating_tokens_sharp, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TextToImageScreen(),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  GestureDetector custom_button(
    String title,
    IconData icon,
    Function()? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: Color.fromARGB(255, 81, 57, 52),
            width: 1.4,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 5),
            Text(title, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class CustomPositionedButton extends StatelessWidget {
  const CustomPositionedButton({
    super.key,
    this.left,
    this.top,
    this.right,
    this.bottom,
    required this.title,
    required this.onTap,
    required this.icon,
  });
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final String title;
  final Function()? onTap;
  final icon;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: right,
      bottom: bottom,
      left: left,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.white38,
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.deepPurpleAccent),
              SizedBox(width: 2),

              Text(
                title,
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomItem extends StatelessWidget {
  const CustomItem({
    super.key,
    required this.onTap,
    required this.title,
    required this.icon,
  });
  final Function()? onTap;
  final String title;
  final icon;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,

              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomContainer extends StatelessWidget {
  const CustomContainer({super.key, required this.icon, this.onTap});
  final icon;
  final onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.inversePrimary),
      ),
    );
  }
}
