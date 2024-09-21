import 'package:ejavapedia/app_colors.dart';
import 'package:ejavapedia/data_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateDataPage extends StatefulWidget {
  final String category_name;
  final String itemName;
  final String itemPic;

  const UpdateDataPage({
    Key? key,
    required this.category_name,
    required this.itemName,
    required this.itemPic,
  }) : super(key: key);

  @override
  _UpdateDataPageState createState() => _UpdateDataPageState();
}

class _UpdateDataPageState extends State<UpdateDataPage> {
  late TextEditingController _itemPicController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedImagePath;
  String? _imageFileName;
  final TextEditingController _imageNameController = TextEditingController();
  late String _base64Image;
  bool _isFormValid = false;

  Future<void> _updateData() async {
    final url = Uri.parse('http://192.168.100.203:8888/eJavaPedia/UpdateData');

    final data = <String, String>{
      'kategori': widget.category_name,
      'nama': widget.itemName,
      'pic': 'data:image/png;base64,$_base64Image',
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

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      final platformFile = result.files.first;
      if (platformFile.bytes != null) {
        setState(() {
          _selectedImagePath = null;
          _imageFileName = platformFile.name;
          _base64Image = base64Encode(platformFile.bytes!);
        });
      } else if (platformFile.path != null) {
        final fileBytes = await HttpRequest.getString(platformFile.path!);
        final byteData = Uint8List.fromList(fileBytes.codeUnits);
        setState(() {
          _selectedImagePath = platformFile.path!;
          _imageFileName = platformFile.name;
          _base64Image = base64Encode(byteData);
        });
      }
      _itemPicController.text = _imageFileName ?? '';
      _validateForm();
    }
  }

  String getSelectedImageName() {
    if (_selectedImagePath != null) {
      final imagePathParts = _selectedImagePath!.split('/');
      return imagePathParts.last;
    }
    return 'Upload Image';
  }

  @override
  void initState() {
    super.initState();
    _itemPicController = TextEditingController(text: widget.itemPic);
  }

  @override
  void dispose() {
    _itemPicController.dispose();
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
          child: Container(
            width: 400,
            height: 450,
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
                    'Perbarui Data Item',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  enabled: false,
                  initialValue: widget.category_name,
                  decoration: const InputDecoration(
                      labelText: 'Kategori', border: InputBorder.none),
                ),
                TextFormField(
                  enabled: false,
                  initialValue: widget.itemName,
                  decoration: const InputDecoration(
                      labelText: 'Nama', border: InputBorder.none),
                ),
                _selectedImagePath != null
                    ? Image.network(
                        _selectedImagePath!,
                        height: 100,
                        width: 100,
                      )
                    : TextFormField(
                        readOnly: true,
                        controller: _itemPicController,
                        onTap: () async {
                          await _pickImage();
                          _validateForm();
                        },
                        decoration: const InputDecoration(
                          labelText: 'Gambar (hanya .png)',
                          suffixIcon: Icon(
                            Icons.upload,
                            color: Colors.grey,
                          ),
                          enabledBorder: InputBorder.none,
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
                      if (_isFormValid) {
                        _updateData();
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Berhasil perbaruan data"),
                          behavior: SnackBarBehavior.floating,
                        ));
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminDataPage()));
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Gagal perbaruan data"),
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
    );
  }
}
