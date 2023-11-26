import 'package:flutter/material.dart';
import 'package:pengaduan_flutter/login.dart';
import 'package:pengaduan_flutter/form_pengaduan.dart';
import 'package:pengaduan_flutter/profile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
      print('NIK: ${widget.user['nik']}'); // Add this line for debugging
      final response = await http.get(
        Uri.parse('http://192.168.100.20:8000/api/get-pengaduan/${widget.user['nik']}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          pengaduanData = json.decode(response.body)['data'];
          isLoading = false; // Set loading to false after successfully fetching data
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
        return 'Submitted';
      case '1':
        return 'Proses';
      case '2':
        return 'Done';
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

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
  leading: Padding(
    padding: const EdgeInsets.only(left: 8.0, bottom: 4.0), // Adjust the padding as needed
    child: CircleAvatar(
      radius: 20, // Adjust the radius as needed
      backgroundColor: Colors.transparent,
      backgroundImage: AssetImage('assets/images/Logo.png'),
    ),
      ),

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
          radius: 20, // Adjust the radius as needed
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
                  child: Text('Buat Pengaduan'),
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
                          color: getColorForStatus(pengaduanData[index]['status']), // Set background color based on status
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${getKategoriLabel(pengaduanData[index]['kategori'])}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${pengaduanData[index]['isi_laporan']}'),
                            Text('${getStatusLabel(pengaduanData[index]['status'])}'),
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

Color getColorForStatus(String status) {

  switch (status) {
    case '0':
      return Colors.blue; // Green for Submitted
    case '1':
      return Colors.yellow; // Yellow for Proses
    case '2':
      return Colors.green; // Blue for Done
    default:
      return Colors.white; // Default color for unknown status
  }

}

}