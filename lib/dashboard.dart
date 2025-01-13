import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:video_player/video_player.dart';
import 'home.dart';
import 'profile.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedDevice = "Device 01";
  String batteryLevel = "Loading...";
  String remainingTime = "Loading...";
  String latitude = "Loading...";
  String longitude = "Loading...";
  String distance = "Loading...";
  String detection = "Loading...";

  List<FlSpot> distanceData = [];

  // VideoPlayerController? _videoController;
  // Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    // _videoController = VideoPlayerController.networkUrl(Uri.parse('http://192.168.1.9/stream'));
    //
    // _initializeVideoPlayerFuture = _videoController!.initialize();
    // _videoController!.setLooping(true);
    _getBatteryLevel();
    _getDeviceData();

  }

  // @override
  // void dispose() {
  //   _videoController?.dispose();
  //   super.dispose();
  // }

  void _getBatteryLevel() async {
    try {
      DatabaseReference batteryRef = FirebaseDatabase.instance.ref('sensor_data/1/battery');
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
    } catch (e) {
      setState(() {
        batteryLevel = "Error fetching data";
        remainingTime = "Error";
      });
      print("Error fetching battery level: $e");
    }
  }

  void _getDeviceData() async {
    try {
      DatabaseReference latitudeRef = FirebaseDatabase.instance.ref('sensor_data/1/latitude');
      DatabaseReference longitudeRef = FirebaseDatabase.instance.ref('sensor_data/1/longitude');
      DatabaseReference distanceRef = FirebaseDatabase.instance.ref('sensor_data/1/distance');
      DatabaseReference detectionRef = FirebaseDatabase.instance.ref('detection/result');

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

      distanceRef.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        if (data != null) {
          setState(() {
            distance = data.toString();
            distanceData.add(FlSpot(distanceData.length.toDouble(), double.parse(distance)));

          });
        } else {
          setState(() {
            distance = "No data";
          });
        }
      });

      detectionRef.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        if (data != null) {
          setState(() {
            detection = data.toString();
          });
        } else {
          setState(() {
            detection = "No data";
          });
        }
      });
    } catch (e) {
      setState(() {
        latitude = "Error fetching data";
        longitude = "Error fetching data";
        distance = "Error fetching data";
        detection = "Error fetching data";
      });
      print("Error fetching location data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 20,
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // decoration: BoxDecoration(
          //   color: Color(0xFFE8F2FF),
          //   borderRadius: BorderRadius.circular(12),
          //   // boxShadow: [
          //   //   BoxShadow(
          //   //     color: Colors.grey.withOpacity(0.2),
          //   //     blurRadius: 15,
          //   //     spreadRadius: 2,
          //   //   ),
          //   // ],
          // ),
          // child: DropdownButton<String>(
          //   value: selectedDevice,
          //   icon: Icon(Icons.arrow_drop_down, color: Colors.black),
          //   underline: SizedBox(), // Remove underline
          //   isExpanded: true,
          //   items: [
          //     DropdownMenuItem(value: 'Device 01', child: Text('Device 01')),
          //     DropdownMenuItem(value: 'Device 02', child: Text('Device 02')),
          //     DropdownMenuItem(value: 'Device 03', child: Text('Device 03')),
          //   ],
          //   onChanged: (value) {
          //     setState(() {
          //       selectedDevice = value!;
          //     });
          //   },
          //   style: TextStyle(fontSize: 16, color: Colors.black),
          //   dropdownColor: Color(0xFFE8F2FF),
          //   borderRadius: BorderRadius.circular(12),
          // ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chart Jarak',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Container(
                height: 150,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage('assets/chart.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        spots: distanceData.isNotEmpty ? distanceData : [FlSpot(0, 0)],
                        color: Color(0xFF1976D2),
                        barWidth: 3,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              Text(
                'Data Perangkat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.all(8),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.battery_4_bar_rounded, color: Color(0xFF0070F0)),
                                  SizedBox(height: 8),
                                  Text(
                                    'Baterai',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    '$batteryLevel%',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF0070F0)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.all(8),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.timer, color: Color(0xFF0070F0)),
                                  SizedBox(height: 8),
                                  Text(
                                    'Sisa Waktu',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    remainingTime,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF0070F0)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.all(8),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_on, color: Color(0xFF0070F0)),
                                  SizedBox(height: 8),
                                  Text(
                                    'Latitude',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    latitude,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF0070F0)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.all(8),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_on_outlined, color: Color(0xFF0070F0)),
                                  SizedBox(height: 8),
                                  Text(
                                    'Longitude',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    longitude,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF0070F0)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.all(8),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_on, color: Color(0xFF0070F0)),
                                  SizedBox(height: 8),
                                  Text(
                                    'Hasil Deteksi',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    detection,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF0070F0)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Longitude Card
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.all(8),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_on_outlined, color: Color(0xFF0070F0)),
                                  SizedBox(height: 8),
                                  Text(
                                    'Jarak Sekitar',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    '$distance cm',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF0070F0)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Text(
              //   'Real-Time Video',
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // ),
              // SizedBox(height: 16),
              // Container(
              //   height: 200,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(12),
              //     border: Border.all(color: Colors.black12),
              //   ),
              //   child: ClipRRect(
              //     borderRadius: BorderRadius.circular(12),
              //     child: FutureBuilder(
              //       future: _initializeVideoPlayerFuture,
              //       builder: (context, snapshot) {
              //         if (snapshot.connectionState == ConnectionState.done) {
              //           return GestureDetector(
              //             onTap: () {
              //               setState(() {
              //                 if (_videoController!.value.isPlaying) {
              //                   _videoController!.pause();
              //                 } else {
              //                   _videoController!.play();
              //                 }
              //               });
              //             },
              //             child: AspectRatio(
              //               aspectRatio: _videoController!.value.aspectRatio,
              //               child: VideoPlayer(_videoController!),
              //             ),
              //           );
              //         } else {
              //           return Center(
              //             child: CircularProgressIndicator(),
              //           );
              //         }
              //       },
              //     ),
              //   ),
              // ),
              // SizedBox(height: 24),
            ],
          ),
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
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: 1,
          onTap: (index) {
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
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
                  Icon(Icons.home, color: Colors.black, size: 28),
                  Text(
                    "Beranda",
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ],
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Column(
                children: [
                  Icon(Icons.dashboard, color: Colors.blue, size: 28),
                  Text(
                    "Perangkat",
                    style: TextStyle(color: Colors.blue, fontSize: 12),
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
}
