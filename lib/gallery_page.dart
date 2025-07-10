import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
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
    bool granted = await requestStoragePermission();
    if (!granted) return;

    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
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
      List<AssetEntity> assets = await album.getAssetListPaged(page: 0, size: 100);

      for (var asset in assets) {
        String path = album.name.toLowerCase();
        if (path.contains('camera')) {
          sectionMap['Camera']!.add(asset);
        } else if (path.contains('whatsapp')) {
          sectionMap['WhatsApp']!.add(asset);
        } else if (path.contains('pinterest')) {
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
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                    ),
                    itemCount: entry.value.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<Widget>(
                        future: entry.value[index].thumbnailWidget(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done &&
                              snapshot.hasData) {
                            return snapshot.data!;
                          } else {
                            return Container(color: Colors.grey[300]);
                          }
                        },
                      );
                    },
                  );
                }).toList(),
              ),
      ),
    );
  }
}