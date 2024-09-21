import 'dart:convert';

import 'package:ejavapedia/app_colors.dart';
import 'package:ejavapedia/data_view.dart';
import 'package:ejavapedia/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateDetailPage extends StatefulWidget {
  final String itemName;

  const CreateDetailPage({Key? key, required this.itemName}) : super(key: key);
  @override
  State<CreateDetailPage> createState() => _CreateDetailPageState();
}

class _CreateDetailPageState extends State<CreateDetailPage> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _oviewController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();
  final TextEditingController _funfactController = TextEditingController();
  final TextEditingController _vidurlController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Future<List<Map<String, dynamic>>>? _dataFuture;

  bool _isFormValid = false;

  Future<void> _uploadDetailData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final itemData = sharedPreferences.getString('itemData');
    final jsonData = jsonDecode(itemData!);
    final itemId = jsonData['data']['ID'];
    final itemName = jsonData['data']['nama'];
    final itemCategory = jsonData['data']['kategori'];

    final url = Uri.parse(
        'http://192.168.100.203:8888/eJavaPedia/CreateDetail?type=$itemCategory');

    final data = <String, dynamic>{
      'ID': itemId,
      'nama': itemName,
      'asal': _originController.text,
      'overview': _oviewController.text,
      'more_info': _infoController.text,
      'fun_fact': _funfactController.text,
      'vid': _vidurlController.text,
    };

    final response = await http.post(url, body: jsonEncode(data));

    if (response.statusCode == 200) {
      print('Data uploaded successfully');
      print(response.body);
    } else {
      print('Error uploading data. Status code: ${response.statusCode}');
      print('Error message: ${response.body}');
      throw Exception(
          'Terjadi error saat melakukan pengunggahan. Status code: ${response.statusCode}');
    }
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
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: AppColors.primary),
        backgroundColor: Colors.white,
        elevation: 10,
        title: const Text(
          'eJavaPedia Admin',
          style: TextStyle(
            color: AppColors.primary,
          ),
        ),
      ),
      backgroundColor: AppColors.primary,
      body: Center(
          child: Form(
        key: _formKey,
        child: Container(
          width: 600,
          height: 550,
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
                  'Unggah Detail Item',
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
                      decoration: const InputDecoration(labelText: 'Ringkasan'),
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
                      decoration: const InputDecoration(labelText: 'Rincian'),
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
                      decoration: const InputDecoration(labelText: 'URL Video'),
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
                      _uploadDetailData();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Berhasil unggah detail"),
                        behavior: SnackBarBehavior.floating,
                      ));
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateDataPage()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Gagal unggah detail"),
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  },
                  child: const Text(
                    'Unggah',
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
      )),
    );
  }
}
