import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';

class Hives extends StatefulWidget {
  const Hives({super.key});

  @override
  State<Hives> createState() => _HivesState();
}

class _HivesState extends State<Hives> {
  List<String> toggleMenu = ["Kayıt Et", "Görüntüle"];
  List<bool> isSelected = List.generate(2, (_) => false);
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptonController = TextEditingController();

  Widget getSelectedContent() {
    int selectedIndex = isSelected.indexWhere((element) => element);

    switch (selectedIndex) {
      case 0:
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "Kayıt Etme Ekranı",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: titleController,

                decoration: InputDecoration(
                  labelText: "Notun adı ",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: descriptonController,
                decoration: InputDecoration(
                  labelText: "Notun açıklaması ",
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  var box = await Hive.openBox('ayarlar');

                  List notes = box.get('notes', defaultValue: []);

                  Map<String, String> newNote = {
                    'title': titleController.text,
                    'description': descriptonController.text,
                  };
                  notes.add(newNote);

                  await box.put('notes', notes);

                  print("Kayıt başarıyla eklendi!");
                },
                child: Text("Kaydet"),
              ),
            ],
          ),
        );
      case 1:
        return FutureBuilder(
          future: Hive.openBox('ayarlar'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              var box = Hive.box('ayarlar');
              List notes = box.get('notes', defaultValue: []);

              return ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  var note = notes[index];
                  return Card(
                    child: ListTile(
                      title: Text(note['title']),
                      subtitle: Text(note['description']),
                    ),
                  );
                },
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        );

      default:
        return Container(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              "Lütfen bir seçenek seçin",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        );
    }
  }

  @override
  void initState() {
    super.initState();

    openBox();
  }

  void openBox() async {
    await Hive.openBox('ayarlar');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text("NotMaster"))),
      body: Column(
        children: [
          ToggleButtons(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(toggleMenu[0]),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(toggleMenu[1]),
              ),
            ],
            isSelected: isSelected,
            onPressed: (int index) {
              setState(() {
                for (int i = 0; i < isSelected.length; i++) {
                  isSelected[i] = i == index;
                }
              });
            },
            color: Colors.grey,
            selectedColor: Colors.blue,
            fillColor: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            constraints: BoxConstraints(minHeight: 40, minWidth: 100),
          ),
          SizedBox(height: 20),

          Expanded(child: getSelectedContent()),
        ],
      ),
    );
  }
}
