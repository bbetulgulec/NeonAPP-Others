import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// ---------------------- MODEL ----------------------

class User {
  int? id;
  String name;
  String surname;
  int age;
  String email;
  String city;

  User({
    this.id,
    required this.name,
    required this.surname,
    required this.age,
    required this.email,
    required this.city,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'age': age,
      'email': email,
      'city': city,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      surname: map['surname'],
      age: map['age'],
      email: map['email'],
      city: map['city'],
    );
  }
}

// ---------------------- DATABASE HELPER ----------------------

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        surname TEXT NOT NULL,
        age INTEGER NOT NULL,
        email TEXT NOT NULL,
        city TEXT
      )
    ''');
  }

  Future<int> insertUser(User user) async {
    final db = await instance.database;
    return db.insert('users', user.toMap());
  }

  Future<List<User>> getUsers() async {
    final db = await instance.database;
    final maps = await db.query('users');
    return maps.map((e) => User.fromMap(e)).toList();
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}

// ---------------------- FORM SAYFASI ----------------------

class SqlliteForm extends StatefulWidget {
  const SqlliteForm({super.key});

  @override
  State<SqlliteForm> createState() => _SqlliteFormState();
}

class _SqlliteFormState extends State<SqlliteForm> {
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();
  final cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kullanıcı Kayıt")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "İsim"),
              ),
              TextField(
                controller: surnameController,
                decoration: const InputDecoration(labelText: "Soyisim"),
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: "Yaş"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "E-posta"),
              ),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: "Şehir"),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  final user = User(
                    name: nameController.text,
                    surname: surnameController.text,
                    age: int.tryParse(ageController.text) ?? 0,
                    email: emailController.text,
                    city: cityController.text,
                  );

                  await DatabaseHelper.instance.insertUser(user);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserListScreen(),
                    ),
                  );
                },
                child: const Text("Kayıt Et ve Listele"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------- LİSTE SAYFASI ----------------------

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> userList = [];

  @override
  void initState() {
    super.initState();
    refreshUsers();
  }

  void refreshUsers() async {
    final users = await DatabaseHelper.instance.getUsers();
    setState(() {
      userList = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kullanıcı Listesi")),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: userList.length,
        itemBuilder: (context, index) {
          final user = userList[index];

          return Dismissible(
            key: Key(user.id.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) async {
              await DatabaseHelper.instance.deleteUser(user.id!);
              refreshUsers();

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Kayıt Silindi")));
            },
            child: Card(
              child: ListTile(
                title: Text("İsim: ${user.name}  Soyisim: ${user.surname}"),
                subtitle: Text(
                  "Yaş: ${user.age}, Email: ${user.email}, Şehir: ${user.city}",
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
