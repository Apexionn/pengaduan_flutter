import 'package:flutter/material.dart';
import 'package:pengaduan_flutter/login.dart';
import 'package:pengaduan_flutter/form_pengaduan.dart';
import 'package:pengaduan_flutter/profile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'details.dart';

class Home extends StatefulWidget {
  final Map<String, dynamic> user;

  Home({required this.user});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<dynamic> pengaduanData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPengaduanData();
  }

  Future<void> fetchPengaduanData() async {
    try {
      print('NIK: ${widget.user['nik']}');
      final response = await http.get(
        Uri.parse('http://172.20.10.10:8000/api/get-pengaduan/${widget.user['nik']}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          pengaduanData = json.decode(response.body)['data'];
          isLoading = false;
        });
      } else {
        print('Failed to load pengaduan data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch pengaduan data. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      print('Error fetching pengaduan data: $error');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch pengaduan data. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  String getStatusLabel(String status) {
    switch (status) {
      case '0':
        return 'Menunggu Permintaan';
      case '1':
        return 'Proses';
      case '2':
        return 'Tanggapan Diberikan';
      default:
        return 'Unknown';
    }
  }

  String getKategoriLabel(String kategori) {
    switch (kategori) {
      case 'infrastruktur':
        return 'INFRASTURKTUR';
      case 'sosial':
        return 'SOSIAL';
      default:
        return 'Unknown';
    }
  }

  Color getColorForStatus(String status) {
    switch (status) {
      case '0':
        return Colors.blue;
      case '1':
        return Colors.yellow;
      case '2':
        return Colors.green;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'MY PROFILE') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage(user: widget.user)),
                  );
                } else if (value == 'LOG OUT') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MyApp()),
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                return ['MY PROFILE', 'LOG OUT'].map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/images/Arlecchino.jpeg'),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FormPengaduanPage(user: widget.user)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue, // Set the background color to blue
                  ),
                  child: Text(
                    'Buat Pengaduan',
                    style: TextStyle(color: Colors.white), // Set text color to white
                  ),
                ),
                  SizedBox(height: 16),
                  Text(
                    'Pengaduan Anda:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: pengaduanData.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: getColorForStatus(pengaduanData[index]['status']),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${getKategoriLabel(pengaduanData[index]['kategori'])}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('${pengaduanData[index]['isi_laporan']}'),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${getStatusLabel(pengaduanData[index]['status'])}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (pengaduanData[index]['status'] == '2') // Show button only for status '2'
                                  ElevatedButton(
                                    onPressed: () {
                                          Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => DetailsPage(pengaduanDetails: pengaduanData[index])),
                                        );
                                    },
                                    child: Text('See Details'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
