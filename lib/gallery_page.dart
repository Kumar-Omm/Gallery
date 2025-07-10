import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io';
import 'dart:typed_data';
import 'utils/permissions.dart';

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  Map<String, List<AssetEntity>> albumSections = {
    'Camera': [],
    'WhatsApp': [],
    'Pinterest': [],
    'Others': [],
  };

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadGallery();
  }

  Future<void> loadGallery() async {
    setState(() => loading = true);

    bool granted = await requestStoragePermission();
    if (!granted) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Storage permission is required")),
      );
      return;
    }

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: true,
    );

    Map<String, List<AssetEntity>> sectionMap = {
      'Camera': [],
      'WhatsApp': [],
      'Pinterest': [],
      'Others': [],
    };

    for (var album in albums) {
      final assets = await album.getAssetListPaged(page: 0, size: 100);
      for (var asset in assets) {
        final name = album.name.toLowerCase();
        if (name.contains('camera')) {
          sectionMap['Camera']!.add(asset);
        } else if (name.contains('whatsapp')) {
          sectionMap['WhatsApp']!.add(asset);
        } else if (name.contains('pinterest')) {
          sectionMap['Pinterest']!.add(asset);
        } else {
          sectionMap['Others']!.add(asset);
        }
      }
    }

    setState(() {
      albumSections = sectionMap;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: albumSections.keys.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Gallery"),
          bottom: TabBar(
            isScrollable: true,
            tabs: albumSections.keys.map((e) => Tab(text: e)).toList(),
          ),
        ),
        body: loading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: albumSections.entries.map((entry) {
                  final images = entry.value;
                  if (images.isEmpty) {
                    return Center(child: Text("No images found in ${entry.key}"));
                  }

                  return GridView.builder(
                    padding: EdgeInsets.all(4),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                    ),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final asset = images[index];

                      return FutureBuilder<Uint8List?>(
                        future: asset.thumbnailDataWithSize(
                          ThumbnailSize(200, 200),
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done &&
                              snapshot.hasData) {
                            return GestureDetector(
                              onTap: () async {
                                final file = await asset.file;
                                if (file != null && mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          FullImagePage(imageFile: file),
                                    ),
                                  );
                                }
                              },
                              child: Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              ),
                            );
                          } else {
                            return Container(color: Colors.grey[300]);
                          }
                        },
                      );
                    },
                  );
                }).toList(),
              ),
        floatingActionButton: loading
            ? null
            : FloatingActionButton(
                onPressed: loadGallery,
                child: Icon(Icons.refresh),
                tooltip: "Reload Gallery",
              ),
      ),
    );
  }
}

// Stub for full image viewing (create full_image_page.dart separately)
class FullImagePage extends StatelessWidget {
  final File imageFile;

  const FullImagePage({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Full Image")),
      body: Center(child: Image.file(imageFile)),
    );
  }
}
