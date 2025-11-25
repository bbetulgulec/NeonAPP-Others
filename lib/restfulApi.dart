import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RestfulApiDemo extends StatefulWidget {
  const RestfulApiDemo({super.key});

  @override
  State<RestfulApiDemo> createState() => _RestfulApiDemoState();
}

class _RestfulApiDemoState extends State<RestfulApiDemo> {
  late Future<List<Users>> futureUsers;
  final APIService apiService = APIService();
  int selectedIndex = 0;
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureUsers = apiService.getUsers();
  }

  void refreshUsers() {
    setState(() {
      futureUsers = apiService.getUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final toggleLabels = ["GET", "POST", "PUT", "DELETE"];

    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text("RESTful API CRUD Örneği")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: List.generate(
                toggleLabels.length,
                (i) => i == selectedIndex,
              ),
              onPressed: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(10),
              selectedColor: Colors.white,
              fillColor: Colors.blue,
              color: Colors.black,
              children: toggleLabels
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(e),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Builder(
                builder: (context) {
                  switch (selectedIndex) {
                    //  GET
                    case 0:
                      return FutureBuilder<List<Users>>(
                        future: futureUsers,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text("Hata: ${snapshot.error}"),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(child: Text("Veri yok."));
                          }

                          final users = snapshot.data!;
                          return RefreshIndicator(
                            onRefresh: () async => refreshUsers(),
                            child: ListView.builder(
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("ID: ${user.id}"),
                                        Text("Name: ${user.name}"),
                                        Text("Username: ${user.username}"),
                                        Text("Email: ${user.email}"),
                                        Text("Street: ${user.address?.street}"),
                                        Text("Suite: ${user.address?.suite}"),
                                        Text("City: ${user.address?.city}"),
                                        Text(
                                          "Zipcode: ${user.address?.zipcode}",
                                        ),
                                        Text(
                                          "Latitude: ${user.address?.geo?.lat}",
                                        ),
                                        Text(
                                          "Longitude: ${user.address?.geo?.lng}",
                                        ),
                                        Text(
                                          "Full Address: ${user.address?.street}, ${user.address?.city}",
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );

                    //  POST
                    case 1:
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: "Ad",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: "E-posta",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () async {
                                final data = {
                                  "name": nameController.text,
                                  "email": emailController.text,
                                };
                                await apiService.createUser(data);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Kullanıcı eklendi "),
                                  ),
                                );
                                refreshUsers();
                              },
                              child: const Text("Kullanıcı Ekle"),
                            ),
                          ],
                        ),
                      );

                    //  PUT
                    case 2:
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: "Yeni Ad",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () async {
                                final data = {"name": nameController.text};
                                await apiService.updateUser(1, data);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "1 numaralı kullanıcı güncellendi ✅",
                                    ),
                                  ),
                                );
                                refreshUsers();
                              },
                              child: const Text("1. Kullanıcıyı Güncelle"),
                            ),
                          ],
                        ),
                      );

                    //  DELETE
                    case 3:
                      return Center(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await apiService.deleteUser(1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("1 numaralı kullanıcı silindi "),
                              ),
                            );
                            refreshUsers();
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text("1 numaralı kullanıcıyı sil"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      );

                    default:
                      return const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//  MODEL SINIFLARI
class Users {
  int? id;
  String? name;
  String? username;
  String? email;
  Address? address;

  Users({this.id, this.name, this.username, this.email, this.address});

  Users.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    address = json['address'] != null
        ? Address.fromJson(json['address'])
        : null;
  }
}

class Address {
  String? street;
  String? suite;
  String? city;
  String? zipcode;
  Geo? geo;

  Address({this.street, this.suite, this.city, this.zipcode, this.geo});

  Address.fromJson(Map<String, dynamic> json) {
    street = json['street'];
    suite = json['suite'];
    city = json['city'];
    zipcode = json['zipcode'];
    geo = json['geo'] != null ? Geo.fromJson(json['geo']) : null;
  }
}

class Geo {
  String? lat;
  String? lng;

  Geo({this.lat, this.lng});

  Geo.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }
}

//API SERVİS SINIFI
class APIService {
  String url = "https://jsonplaceholder.typicode.com/users";

  // GET
  Future<List<Users>> getUsers() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> list = jsonDecode(response.body);
      return list.map((e) => Users.fromJson(e)).toList();
    } else {
      throw Exception("GET hatası: ${response.statusCode}");
    }
  }

  // POST
  Future<void> createUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(userData),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 201) {
      throw Exception("POST hatası: ${response.statusCode}");
    }
  }

  // PUT
  Future<void> updateUser(int id, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse("$url/$id"),
      body: jsonEncode(userData),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode != 200) {
      throw Exception("PUT hatası: ${response.statusCode}");
    }
  }

  // DELETE
  Future<void> deleteUser(int id) async {
    final response = await http.delete(Uri.parse("$url/$id"));
    if (response.statusCode != 200) {
      throw Exception("DELETE hatası: ${response.statusCode}");
    }
  }
}
