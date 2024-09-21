import 'package:ejavapedia/app_colors.dart';
import 'package:ejavapedia/detail_view.dart';
import 'package:ejavapedia/main.dart';
import 'package:ejavapedia/update.dart';
import 'package:ejavapedia/update_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminDataPage extends StatefulWidget {
  const AdminDataPage({Key? key}) : super(key: key);

  @override
  State<AdminDataPage> createState() => _AdminDataPageState();
}

class _AdminDataPageState extends State<AdminDataPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isFormValid = false;
  late Future<void> _itemFuture;

  void _validateForm() {
    setState(() {
      _isFormValid = _formKey.currentState?.validate() ?? false;
    });
  }

  String _selectedCategory = 'Makanan';
  List<Map<String, dynamic>> _dataList = [];

  Future<void> fetchData(String category_name) async {
    final response = await http.get(Uri.parse(
        'http://192.168.100.203:8888/eJavaPedia/Get?category=$category_name&name='));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(responseData['data']).map((item) {
        return {
          'item_id': item['ID'],
          'item_name': item['Nama'],
          'item_imageUrl': item['Pic'],
        };
      }).toList();

      setState(() {
        _dataList = data;
      });
      print(responseData);
    } else {
      print('API error: ${response.statusCode}');
    }
  }

  Future<void> deleteData(int id, String category_name, String name) async {
    try {
      final url =
          Uri.parse('http://192.168.100.203:8888/eJavaPedia/DeleteData');

      final payload = {
        'kategori': category_name,
        'nama': name,
      };

      final response = await http.delete(
        url,
        body: jsonEncode(payload),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _dataList.removeWhere((item) => item['item_id'] == id);
        });
      } else {
        throw Exception(
            'Delete failed with status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error calling API: $error');
      throw Exception('Error calling API');
    }
  }

  @override
  void initState() {
    _itemFuture = fetchData(_selectedCategory);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.primary),
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
                  MaterialPageRoute(builder: (context) => const MyApp()),
                );
              },
              child: const Text(
                'Unggah Data Item',
                style: TextStyle(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Form(
              key: _formKey,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 300,
                  child: DropdownButtonFormField<String>(
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
                      if (value != null) {
                        fetchData(value);
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: _dataList.length,
                itemBuilder: (context, index) {
                  final item = _dataList[index];
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      color: Colors.white,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdminDetailPage(
                                        category_name: _selectedCategory,
                                        id: item['item_id'],
                                      )));
                        },
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8.0),
                          title: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: FittedBox(
                                          child: Text(
                                            item['item_name']!,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          UpdateDataPage(
                                                            category_name:
                                                                _selectedCategory,
                                                            itemName: item[
                                                                'item_name'],
                                                            itemPic: item[
                                                                'item_imageUrl'],
                                                          )));
                                            },
                                            child: const Text(
                                              'Perbarui',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Konfirmasi'),
                                                    content: const Text(
                                                      'Apakah Anda yakin ingin menghapus item ini?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                          deleteData(
                                                            item['item_id'],
                                                            _selectedCategory,
                                                            item['item_name'],
                                                          );
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  const SnackBar(
                                                            content: Text(
                                                                "Data item berhasil dihapus"),
                                                            behavior:
                                                                SnackBarBehavior
                                                                    .floating,
                                                          ));
                                                        },
                                                        child: const Text(
                                                          'Ya',
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                          'Tidak',
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: const Text(
                                              'Hapus',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 200,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      item['item_imageUrl'],
                                      fit: BoxFit.cover,
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
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
