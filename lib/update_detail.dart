import 'package:ejavapedia/app_colors.dart';
import 'package:ejavapedia/data_view.dart';
import 'package:ejavapedia/detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateDetailPage extends StatefulWidget {
  final String category_name;
  final String itemName;
  final int itemID;

  const UpdateDetailPage({
    Key? key,
    required this.category_name,
    required this.itemName,
    required this.itemID,
  }) : super(key: key);

  @override
  _UpdateDetailPage createState() => _UpdateDetailPage();
}

class _UpdateDetailPage extends State<UpdateDetailPage> {
  late TextEditingController _itemIDController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _oviewController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();
  final TextEditingController _funfactController = TextEditingController();
  final TextEditingController _vidurlController = TextEditingController();
  bool _isFormValid = false;

  Future<Map<String, dynamic>> fetchItemDetails() async {
    final response = await http.get(Uri.parse(
      'http://192.168.100.203:8888/eJavaPedia/Get?type=${widget.category_name}&ID=${widget.itemID}',
    ));

    if (response.body.contains('data')) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final Map<String, dynamic> data = body['data'];
      return {
        'id': data['ID'],
        'name': data['nama'],
        'origin': data['asal'],
        'overview': data['overview'],
        'info': data['more_info'],
        'funfact': data['fun_fact'],
        'imageUrl': data['pic'],
        'vidUrl': data['vid'],
      };
    } else {
      throw Exception('Failed to load item details: ${response.statusCode}');
    }
  }

  Future<void> _updateDetailData() async {
    final url = Uri.parse(
        'http://192.168.100.203:8888/eJavaPedia/UpdateDetail?type=${widget.category_name}');

    final data = <String, dynamic>{
      'ID': widget.itemID,
      'nama': widget.itemName,
      'asal': _originController.text,
      'overview': _oviewController.text,
      'more_info': _infoController.text,
      'fun_fact': _funfactController.text,
      'vid': _vidurlController.text
    };

    final response = await http.post(url, body: jsonEncode(data));

    if (response.statusCode == 200) {
      print('Data updated successfully');
      print(response.body);
    } else {
      print('Error updating data. Status code: ${response.statusCode}');
      print('Error message: ${response.body}');
      throw Exception(
          'Terjadi error saat melakukan perbaruan. Status code: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    _itemIDController = TextEditingController(text: widget.itemID.toString());
    _showDetailsAsDefaultTF();
  }

  Future<void> _showDetailsAsDefaultTF() async {
    try {
      final itemDetails = await fetchItemDetails();
      setState(() {
        _originController.text = itemDetails['origin'];
        _oviewController.text = itemDetails['overview'];
        _infoController.text = itemDetails['info'];
        _funfactController.text = itemDetails['funfact'];
        _vidurlController.text = itemDetails['vidUrl'];
      });
    } catch (e) {
      print('Error fetching item details: $e');
    }
  }

  @override
  void dispose() {
    _itemIDController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 10,
        title: const Text(
          'eJavaPedia Admin',
          style: TextStyle(
            color: AppColors.primary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdminDataPage()));
              },
              child: const Text(
                'Data Item',
                style: TextStyle(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      backgroundColor: AppColors.primary,
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              width: 600,
              height: 600,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'Perbarui Detail Item',
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    enabled: false,
                    initialValue: widget.itemName,
                    decoration: const InputDecoration(
                        labelText: 'Nama', border: InputBorder.none),
                  ),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        TextFormField(
                          controller: _originController,
                          decoration: const InputDecoration(labelText: 'Asal'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Asal tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _oviewController,
                          decoration:
                              const InputDecoration(labelText: 'Ringkasan'),
                          maxLines: null,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ringkasan tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _infoController,
                          decoration:
                              const InputDecoration(labelText: 'Rincian'),
                          maxLines: null,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Rincian tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _funfactController,
                          decoration:
                              const InputDecoration(labelText: 'Fakta Menarik'),
                          maxLines: null,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Fakta menarik tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _vidurlController,
                          decoration:
                              const InputDecoration(labelText: 'URL Video'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'URL Video tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: AppColors.primary,
                        elevation: 5,
                      ),
                      onPressed: () {
                        _validateForm();
                        if (_isFormValid) {
                          _updateDetailData();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Berhasil perbaruan detail"),
                            behavior: SnackBarBehavior.floating,
                          ));
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdminDetailPage(
                                        id: widget.itemID,
                                        category_name: widget.category_name,
                                      )));
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Gagal perbaruan detail"),
                            behavior: SnackBarBehavior.floating,
                          ));
                        }
                      },
                      child: const Text(
                        'Perbarui',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
