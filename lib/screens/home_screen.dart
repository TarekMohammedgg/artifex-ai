import 'package:artifex_ai/consts.dart';
import 'package:artifex_ai/screens/image_studio_screen.dart';
import 'package:artifex_ai/screens/image_to_text_chat_screen.dart';
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
    super.initState();
    fetchAssets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

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

            ],
          ),
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
  final VoidCallback? onTap;
  final IconData icon;
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
  final VoidCallback? onTap;
  final String title;
  final IconData icon;
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
  final IconData icon;
  final VoidCallback? onTap;
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
