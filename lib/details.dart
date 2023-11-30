import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetailsPage extends StatefulWidget {
  final Map<String, dynamic> pengaduanDetails;

  DetailsPage({required this.pengaduanDetails});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late List<Map<String, dynamic>> tanggapanList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://192.168.100.20:8000/api/tanggapan/${widget.pengaduanDetails['id_pengaduan']}'));
    
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      tanggapanList = responseData.cast<Map<String, dynamic>>();
      setState(() {});
    } else {
      throw Exception('Failed to load tanggapan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category: ${widget.pengaduanDetails['kategori']}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Isi Laporan: ${widget.pengaduanDetails['isi_laporan']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Status: ${widget.pengaduanDetails['status']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Tanggapan:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: tanggapanList.isNotEmpty
                  ? ListView.builder(
                      itemCount: tanggapanList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tgl Tanggapan: ${tanggapanList[index]['tgl_tanggapan']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tanggapan: ${tanggapanList[index]['isi_tanggapan']}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'ID Petugas: ${tanggapanList[index]['id_petugas']}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Role: ${tanggapanList[index]['role']}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text('No tanggapan available.'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
