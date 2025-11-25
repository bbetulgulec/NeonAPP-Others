import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// DIO
class DioState extends StatefulWidget {
  const DioState({super.key});

  @override
  State<DioState> createState() => _DioStateState();
}

class _DioStateState extends State<DioState> {
  final service = Service();
  late Future<List<PostModel>> futurePosts;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futurePosts = service.getPosts();
  }

  void refreshPosts() {
    setState(() {
      futurePosts = service.getPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MelodyMaker Dio CRUD")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Başlık",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(
                labelText: "İçerik",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await service.createPost({
                      "title": titleController.text,
                      "body": bodyController.text,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("POST yapıldı")),
                    );
                    titleController.clear();
                    bodyController.clear();
                    refreshPosts();
                  },
                  child: const Text("POST"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    await service.updatePost(1, {
                      "title": titleController.text,
                      "body": bodyController.text,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("PUT yapıldı")),
                    );
                    refreshPosts();
                  },
                  child: const Text("PUT 1"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    await service.deletePost(1);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text("DELETE 1")));
                    refreshPosts();
                  },
                  child: const Text("DELETE 1"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<PostModel>>(
                future: futurePosts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Hata: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Veri yok"));
                  }

                  final posts = snapshot.data!;
                  return RefreshIndicator(
                    onRefresh: () async => refreshPosts(),
                    child: ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          elevation: 3,
                          child: ListTile(
                            title: Text(post.title ?? "Başlık yok"),
                            subtitle: Text(post.body ?? "İçerik yok"),
                          ),
                        );
                      },
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

// SERVICE CLASS
class Service {
  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {"Authorization": "Bearer demoToken123"},
    ),
  );

  final String url = "https://jsonplaceholder.typicode.com/posts";

  Service() {
    // Interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print("REQUEST => ${options.method} ${options.path}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print("RESPONSE => ${response.statusCode}");
          return handler.next(response);
        },
        onError: (e, handler) {
          print("ERROR => ${e.message}");
          return handler.next(e);
        },
      ),
    );
  }

  // GET
  Future<List<PostModel>> getPosts() async {
    List<PostModel> posts = [];
    try {
      final response = await dio.get(url);
      if (response.statusCode == HttpStatus.ok) {
        final List<dynamic> list = response.data;
        posts = list.map((e) => PostModel.fromJson(e)).toList();
      }
    } catch (e) {
      rethrow;
    }
    return posts;
  }

  // POST
  Future<void> createPost(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(url, data: data);
      if (response.statusCode != 201) {
        throw Exception("POST hatası: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }

  // PUT
  Future<void> updatePost(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.put("$url/$id", data: data);
      if (response.statusCode != 200) {
        throw Exception("PUT hatası: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }

  // DELETE
  Future<void> deletePost(int id) async {
    try {
      final response = await dio.delete("$url/$id");
      if (response.statusCode != 200) {
        throw Exception("DELETE hatası: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }
}

//POST MODEL
class PostModel {
  int? id;
  String? title;
  String? body;

  PostModel({this.id, this.title, this.body});

  PostModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'body': body};
  }
}
