import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dashboard.dart';
import 'profile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "Loading...";
  String batteryLevel = "Loading...";
  String remainingTime = "Loading...";
  String latitude = "Loading...";
  String longitude = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchUserName();
    _getDeviceData();
    _fetchNews();
  }
  List<dynamic> news = [];

  Future<void> _fetchNews() async {
    const String apiUrl = "http://naviclean.sirem.web.id/med/get_news.php";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          news = json.decode(response.body);
        });
      } else {
        print("Failed to load news: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching news: $e");
    }
  }

  Future<void> fetchUserName() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;

        DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$uid');

        final snapshot = await userRef.get();
        if (snapshot.exists) {
          setState(() {
            userName = snapshot.child('username').value.toString();
          });
        } else {
          print("Data pengguna tidak ditemukan.");
        }
      } else {
        print("Pengguna belum login.");
      }
    } catch (e) {
      print("Terjadi kesalahan: $e");
    }
  }

  void _getDeviceData() async {
    try {
      DatabaseReference batteryRef = FirebaseDatabase.instance.ref('sensor_data/1/battery');
      DatabaseReference latitudeRef = FirebaseDatabase.instance.ref('sensor_data/1/latitude');
      DatabaseReference longitudeRef = FirebaseDatabase.instance.ref('sensor_data/1/longitude');

      batteryRef.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;

        if (data != null) {
          setState(() {
            batteryLevel = data.toString();

            const totalCapacity = 1500.0;
            const powerConsumption = 1000.0;
            final batteryPercentage = double.tryParse(batteryLevel) ?? 0.0;
            final remainingCapacity = (totalCapacity * batteryPercentage) / 100;
            final remainingTimeInHours = remainingCapacity / powerConsumption;
            final hours = remainingTimeInHours.floor();
            final minutes = ((remainingTimeInHours - hours) * 60).floor();

            remainingTime = batteryPercentage > 0
                ? "$hours jam $minutes menit"
                : "Tidak tersedia";
          });
        } else {
          setState(() {
            batteryLevel = "No data";
            remainingTime = "Tidak tersedia";
          });
        }
      });

      latitudeRef.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        if (data != null) {
          setState(() {
            latitude = data.toString();
          });
        } else {
          setState(() {
            latitude = "No data";
          });
        }
      });

      longitudeRef.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        if (data != null) {
          setState(() {
            longitude = data.toString();
          });
        } else {
          setState(() {
            longitude = "No data";
          });
        }
      });
    } catch (e) {
      setState(() {
        batteryLevel = "Error fetching data";
        remainingTime = "Error";
        latitude = "Error fetching data";
        longitude = "Error fetching data";
      });
      print("Error fetching location data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 120,
        title: Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Text.rich(
            TextSpan(
              text: "Selamat Datang,\n",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w300,
                fontSize: 24,
              ),
              children: [
                TextSpan(
                  text: userName,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
              borderRadius: BorderRadius.circular(28),
              child: CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage('assets/profile.png'),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Informasi Perangkat",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage('assets/bg-home.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Device 01",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "$latitude"" | ""$longitude",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 35),
                      Text(
                        "$batteryLevel%"" | ""$remainingTime",
                        style: TextStyle(
                          color: Color(0xFFE8F2FF),
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Berita Terkini",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: news.isEmpty
                  ? const Center(child: Text("No news found"))
                  : ListView.builder(
                itemCount: news.length,
                itemBuilder: (context, index) {
                  final article = news[index];

                  final date = article['created_at'] != null
                      ? DateTime.parse(article['created_at']).toLocal()
                      : DateTime.now();
                  final formattedDate =
                      "${date.year}-${date.month}-${date.day}";

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: article['photo'] != null
                          ? NetworkImage(article['photo'])
                          : const AssetImage(
                          'assets/news_placeholder.png')
                      as ImageProvider,
                    ),
                    title: Text(
                      article['title'] ?? 'Untitled',
                      style: const TextStyle(
                          fontWeight: FontWeight
                              .bold),
                    ),
                    subtitle:
                    Text(formattedDate),
                    onTap: () {
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(

        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 3,
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: 0,
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage()),
              );
            }
            if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  Icon(Icons.home, color: Colors.blue, size: 28),
                  Text(
                    "Beranda",
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ],
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  Icon(Icons.dashboard, color: Colors.black, size: 28),
                  Text(
                    "Perangkat",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ],
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  Icon(Icons.account_circle_rounded, color: Colors.black, size: 28),
                  Text(
                    "Profil",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ],
              ),
              label: '',
            ),
          ],
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }

  Widget sampahItem(String title, String time, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage(imagePath),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.black,
            size: 20,
          ),
        ],
      ),
    );
  }
}
