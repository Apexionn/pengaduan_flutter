import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'home.dart';

class FormPengaduanPage extends StatefulWidget {
  final Map<String, dynamic> user;

  FormPengaduanPage({required this.user});

  @override
  _FormPengaduanPageState createState() => _FormPengaduanPageState();
}

class _FormPengaduanPageState extends State<FormPengaduanPage> {
  TextEditingController pengaduanController = TextEditingController();
  String selectedCategory = 'sosial';
  PlatformFile? pickedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        pickedFile = result.files.first;
      });
    }
  }

  Future<void> _submitPengaduan() async {
    try {
      String apiUrl = "http://192.168.100.20:8000/api/add-pengaduan";

      Map<String, dynamic> pengaduanData = {
        'nik': widget.user['nik'],
        'isi_laporan': pengaduanController.text,
        'kategori': selectedCategory,
      };

      Map<String, String> pengaduanDataString = pengaduanData.map(
        (key, value) => MapEntry(key, value.toString()),
      );

     if (pickedFile != null) {
        http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(apiUrl))
          ..fields.addAll(pengaduanDataString)
          ..files.add(
            http.MultipartFile.fromBytes(
              'foto',
              pickedFile!.bytes!,
              filename: pickedFile!.name,
              contentType: MediaType('application', 'octet-stream'),
            ),
          );

        var response = await request.send();

if (response.statusCode >= 200 && response.statusCode < 300) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80.0,
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Text(
                  'Pengaduan Submitted!',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Home(user: widget.user),
                    ),
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to submit pengaduan. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please choose a photo."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error submitting pengaduan: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Pengaduan', style: TextStyle(color: Colors.black)),
        // backgroundColor: Color.fromARGB(255, 3, 252, 177),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'Buat Pengaduan:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: pengaduanController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Tuliskan pengaduan Anda...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Kategori:'),
                  SizedBox(width: 10),
                  DropdownButton<String>(
                    value: selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                    items: ['sosial', 'infrastruktur'].map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Upload Foto:'),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      _pickFile();
                    },
                    child: Text('Choose Photo'),
                  ),
                ],
              ),
              // Display the picked file if available
              if (pickedFile != null)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  height: 100,
                  child: Text(
                    'File: ${pickedFile!.name}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _submitPengaduan();
                },
                child: Text('Submit Pengaduan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
