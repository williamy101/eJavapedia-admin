import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:ejavapedia/data_view.dart';
import 'package:ejavapedia/detail.dart';
import 'package:http/http.dart' as http;
import 'package:ejavapedia/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const CreateDataPage(),
      theme: ThemeData(
        textTheme: GoogleFonts.dmSansTextTheme(),
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CreateDataPage extends StatefulWidget {
  const CreateDataPage({Key? key}) : super(key: key);

  @override
  _CreateDataPageState createState() => _CreateDataPageState();
}

class _CreateDataPageState extends State<CreateDataPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _imageNameController = TextEditingController();
  String _selectedCategory = 'Makanan';
  String? _selectedImagePath;
  String? _imageFileName;
  late String _base64Image;
  bool _isFormValid = false;

  Future<void> _uploadData() async {
    final url = Uri.parse('http://192.168.100.203:8888/eJavaPedia/CreateData');

    final data = <String, String>{
      'kategori': _selectedCategory,
      'nama': _nameController.text,
      'pic': 'data:image/png;base64,$_base64Image',
    };

    final response = await http.post(url, body: jsonEncode(data));

    if (response.statusCode == 200) {
      print('Data uploaded successfully');
      print(response.body);
      final sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('itemData', response.body);
    } else {
      print('Error uploading data. Status code: ${response.statusCode}');
      print('Error message: ${response.body}');
      throw Exception(
          'Terjadi error saat melakukan pengunggahan. Status code: ${response.statusCode}');
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
      } else if (platformFile.readStream != null) {
        final byteData = await platformFile.readStream!.first;

        setState(() {
          _selectedImagePath = null;
          _imageFileName = platformFile.name;
          _base64Image = base64Encode(byteData);
        });
      }

      _imageNameController.text = _imageFileName ?? '';
    }
  }

  String getSelectedImageName() {
    if (_selectedImagePath != null) {
      final imagePathParts = _selectedImagePath!.split('/');
      return imagePathParts.last;
    }
    return 'Upload Image';
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
                    'Unggah Data Item',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                const SizedBox(height: 40),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Makanan',
                      child: Text('Makanan'),
                    ),
                    DropdownMenuItem(
                      value: 'Tarian',
                      child: Text('Tarian'),
                    ),
                    DropdownMenuItem(
                      value: 'Wisata',
                      child: Text('Wisata'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                    _validateForm();
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                _selectedImagePath != null
                    ? Image.network(_selectedImagePath!,
                        height: 100, width: 100)
                    : TextFormField(
                        readOnly: true,
                        controller: _imageNameController,
                        onTap: () async {
                          await _pickImage();
                          _validateForm();
                        },
                        decoration: const InputDecoration(
                          hintText: 'Unggah gambar (hanya .png)',
                          suffixIcon: Icon(
                            Icons.upload,
                            color: Colors.grey,
                          ),
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
                        _uploadData();
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Berhasil unggah data"),
                          behavior: SnackBarBehavior.floating,
                        ));
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateDetailPage(
                                      itemName: _nameController.text,
                                    )));
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Gagal unggah data"),
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
        ),
      ),
    );
  }
}
