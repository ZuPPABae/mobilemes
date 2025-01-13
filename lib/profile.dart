import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dashboard.dart';
import 'home.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  String username = "";
  String phone = "";
  String password = "";
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref = FirebaseDatabase.instance.ref('users/${user.uid}');
      ref.once().then((DatabaseEvent event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          setState(() {
            username = data['username'] ?? '';
            phone = data['phone'] ?? '';
            password = data['password'] ?? '';
            usernameController.text = username;
            phoneController.text = phone;
            passwordController.text = password;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }).catchError((error) {
        print('Error fetching user data: $error');
        setState(() {
          isLoading = false;
        });
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updatePassword() async {
    final user = FirebaseAuth.instance.currentUser;
    String newPassword = passwordController.text;

    if (user != null) {
      try {
        await user.updatePassword(newPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password berhasil diperbarui')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui password: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak ada pengguna yang login')),
      );
    }
  }

  void updateUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final ref = FirebaseDatabase.instance.ref('users/${user.uid}');
      try {
        await ref.update({
          'username': usernameController.text,
          'phone': phoneController.text,
        });

        if (passwordController.text.isNotEmpty) {
          await updatePassword();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil berhasil diperbarui')),
        );
        fetchUserData();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error memperbarui profil: $error')),
        );
      }
    }
  }

  void deleteUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Konfirmasi'),
            content: Text('Apakah Anda yakin ingin menghapus akun Anda?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _confirmDeleteUser(user);
                },
                child: Text('Ya'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak ada user yang login')),
      );
    }
  }

  void _confirmDeleteUser(User user) {
    final ref = FirebaseDatabase.instance.ref('users');
    ref.orderByChild('email').equalTo(user.email).once().then((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        data.forEach((key, value) {
          ref.child(key).remove().then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile deleted successfully')),
            );
            FirebaseAuth.instance.signOut();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error deleting profile')),
            );
          });
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No profile found to delete')),
        );
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile data')),
      );
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Keluar'),
          content: Text('Apakah anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              SizedBox(height: 30),
              Text(
                'Edit Profil',
                  style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),

            SizedBox(height: 32),
            Align(
    alignment: Alignment.bottomCenter,
    child: SizedBox(
    width: 150,
    height: 150,
    child: Stack(
    fit: StackFit.expand,
    children: [
    Container(
    decoration: const BoxDecoration(
    color: Colors.white,
    shape: BoxShape.circle,
    image: DecorationImage(
    fit: BoxFit.cover,
    image: AssetImage('assets/profile.png'))),
    ),
    Positioned(
    bottom: 0,
    right: 0,
    child: CircleAvatar(
    radius: 20,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    child: Container(
    margin: const EdgeInsets.all(8.0),
    decoration: const BoxDecoration(
    color: Colors.green, shape: BoxShape.circle),
    ),
    ),
    ),
    ],
    ),
    ),
    ),
    SizedBox(height: 32),

      TextFormField(
    controller: usernameController,
    decoration: InputDecoration(
    labelText: 'Username',
    labelStyle: TextStyle(color: Colors.grey[600]),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(25),
    borderSide: BorderSide(color: Colors.black),
    ),
    filled: true,
    fillColor: Colors.blue[50],
    prefixIcon: Icon(Icons.person),
    ),
    ),
    SizedBox(height: 16),

    TextFormField(
    controller: phoneController,
    decoration: InputDecoration(
    labelText: 'Phone',
    labelStyle: TextStyle(color: Colors.grey[600]),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(25),
    borderSide: BorderSide(color: Colors.black),
    ),
    filled: true,
    fillColor: Colors.blue[50],
    prefixIcon: Icon(Icons.phone),
    ),
    ),
    SizedBox(height: 16),

    TextFormField(
    controller: passwordController,
    obscureText: true,
    decoration: InputDecoration(
    labelText: 'Password',
    labelStyle: TextStyle(color: Colors.grey[600]),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(25),
    borderSide: BorderSide(color: Colors.black),
    ),
    filled: true,
    fillColor: Colors.blue[50],
    prefixIcon: Icon(Icons.lock),
    ),
    ),
              SizedBox(height: 32),

              // Update Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Membuat tombol terletak di kiri dan kanan
                children: [
                  // Simpan Perubahan Button
                  ElevatedButton(
                    onPressed: updateUserProfile,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Simpan edit',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  // Hapus Akun Button
                  ElevatedButton(
                    onPressed: deleteUserProfile, // Memanggil fungsi untuk navigasi
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Hapus Akun',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),

                ],
              ),
              SizedBox(height: 200),


              // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SizedBox(
              width: 380,
              child: ElevatedButton.icon(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8F2FF),
                  foregroundColor: const Color(0xFF0070F0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),

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
    currentIndex: 2,
    onTap: (index) {
    if (index == 0) {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => HomePage()),
    );
    }
    if (index == 1) {
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => DashboardPage()),
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
    Icon(Icons.account_circle_rounded, color: Colors.blue, size: 28),
    Text(
    "Profil",
    style: TextStyle(color: Colors.blue, fontSize: 12),
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
