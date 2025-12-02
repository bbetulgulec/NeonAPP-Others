import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//Model
class Message {
  final String sender;
  final String content;

  Message({required this.sender, required this.content});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(sender: json['sender'], content: json['content']);
  }

  Map<String, dynamic> toJson() {
    return {'sender': sender, 'content': content};
  }
}

// API servisi
class ApiService {
  final String url = "https://jsonplaceholder.typicode.com/posts";

  // GET
  Future<List<Message>> getMessages() async {
    final response = await http.get(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body);
      return list
          .map((e) => Message(sender: "Barbie", content: e['title']))
          .toList();
    } else {
      throw Exception("GET hatası: ${response.statusCode}");
    }
  }

  // POST
  Future<void> sendMessage(Message msg) async {
    final response = await http.post(
      Uri.parse(url),
      body: jsonEncode(msg.toJson()),
      headers: {"Content-Type": "application/json"},
    );

    print("POST status code: ${response.statusCode}");

    if (response.statusCode != 201) {
      throw Exception("POST hatası: ${response.statusCode}");
    }
  }
}

class httpRequests extends StatefulWidget {
  const httpRequests({super.key});

  @override
  State<httpRequests> createState() => _httpRequestsState();
}

class _httpRequestsState extends State<httpRequests> {
  final ApiService apiService = ApiService();
  late Future<List<Message>> futureMessages;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureMessages = apiService.getMessages();
  }

  void refresh() {
    setState(() {
      futureMessages = apiService.getMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Barbie & Ken Chat")),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Message>>(
                future: futureMessages,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text(" ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Mesaj yok."));
                  }

                  final messages = snapshot.data!;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return ListTile(
                        title: Text(msg.sender),
                        subtitle: Text(msg.content),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: "Mesaj yaz...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      if (controller.text.isEmpty) return;
                      final msg = Message(
                        sender: "Ken",
                        content: controller.text,
                      );
                      await apiService.sendMessage(msg);
                      controller.clear();
                      refresh();
                    },
                    child: const Text("Gönder"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
