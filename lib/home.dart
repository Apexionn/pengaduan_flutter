import 'package:flutter/material.dart';
import 'package:pengaduan_flutter/login.dart';
import 'package:pengaduan_flutter/form_pengaduan.dart';
import 'package:pengaduan_flutter/profile.dart'; // Import the profile page

class Home extends StatelessWidget {
  final Map<String, dynamic> user;

  Home({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, ${user['nama']}!', style: TextStyle(color: Colors.black, fontSize: 20),),
        backgroundColor: Color.fromARGB(255, 3, 252, 177),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'MY PROFILE') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage(user: user)),
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
              child: const CircleAvatar(
                radius: 15,
                backgroundImage: AssetImage('images/Arlecchino.jpeg'),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to the form_pengaduan.dart page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FormPengaduanPage(user: user)),
                );
              },
              child: Text('Buat Pengaduan'),
            ),
          ],
        ),
      ),
    );
  }
}
