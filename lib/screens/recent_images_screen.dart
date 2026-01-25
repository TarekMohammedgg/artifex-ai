import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class RecentImagesScreen extends StatefulWidget {
  const RecentImagesScreen({super.key});

  @override
  State<RecentImagesScreen> createState() => _RecentImagesScreenState();
}

class _RecentImagesScreenState extends State<RecentImagesScreen> {
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
    // TODO: implement initState
    super.initState();
    fetchAssets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: images.length,
        itemBuilder: (_, indx) {
          return FutureBuilder<Uint8List>(
            future: images[indx].thumbnailData.then((value) {
              return value!;
            }),
            builder: (_, snapshot) {
              final bytes = snapshot.data;
              if (bytes == null) {
                return CircularProgressIndicator();
              }
              return Image.memory(bytes, fit: BoxFit.cover);
            },
          );
        },
      ),
    );
  }
}
