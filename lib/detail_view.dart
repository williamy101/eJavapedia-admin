import 'dart:convert';
import 'package:ejavapedia/update_detail.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:ejavapedia/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminDetailPage extends StatefulWidget {
  final String category_name;
  final int id;

  const AdminDetailPage(
      {Key? key, required this.category_name, required this.id})
      : super(key: key);

  @override
  State<AdminDetailPage> createState() => _AdminDetailPageState();
}

class _AdminDetailPageState extends State<AdminDetailPage> {
  late Future<Map<String, dynamic>> _itemFuture;
  YoutubePlayerController? _youtubePlayerController;
  bool _isVideoLoaded = false;

  Future<Map<String, dynamic>> fetchItemDetails() async {
    final response = await http.get(Uri.parse(
      'http://192.168.100.203:8888/eJavaPedia/Get?type=${widget.category_name}&ID=${widget.id}',
    ));

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final Map<String, dynamic> data = body['data'];

      final String? videoUrl = data['vid'];
      // ignore: avoid_print
      print('Video URL: $videoUrl');

      return {
        'item_id': data['ID'],
        'item_name': data['nama'],
        'item_origin': data['asal'],
        'item_overview': data['overview'],
        'item_info': data['more_info'],
        'item_funfact': data['fun_fact'],
        'item_imageUrl': data['pic'],
        'item_vidUrl': videoUrl,
      };
    } else {
      throw Exception('Failed to load item details: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    _itemFuture = fetchItemDetails();
  }

  @override
  void dispose() {
    _youtubePlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.primary),
        backgroundColor: Colors.white,
        elevation: 10,
        title: const Text(
          'Detail',
          style: TextStyle(
            color: AppColors.primary,
          ),
        ),
      ),
      backgroundColor: AppColors.primary,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _itemFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final item = snapshot.data!;

            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 500.0),
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(width: 16),
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    item['item_imageUrl'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${item['item_name']}',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UpdateDetailPage(
                                                category_name:
                                                    widget.category_name,
                                                itemName: item['item_name'],
                                                itemID: widget.id,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Perbarui',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: AppColors.primary,
                                          ),
                                        )),
                                  )
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Asal: ${item['item_origin']}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Ringkasan: ${item['item_overview']}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Rincian: ${item['item_info']}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Fakta Menarik: ${item['item_funfact']}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 16),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Video',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              YoutubePlayer(
                                controller: YoutubePlayerController(
                                  initialVideoId: YoutubePlayer.convertUrlToId(
                                          item['item_vidUrl']) ??
                                      '',
                                  flags: const YoutubePlayerFlags(
                                    autoPlay: false,
                                    mute: false,
                                  ),
                                ),
                                showVideoProgressIndicator: true,
                                progressIndicatorColor: Colors.blueAccent,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      if (item['item_vidUrl'] == null &&
                          item['item_vidUrl'].isEmpty)
                        const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Center(
              child: Text('No data available'),
            );
          }
        },
      ),
    );
  }
}
