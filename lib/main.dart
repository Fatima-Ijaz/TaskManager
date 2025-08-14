import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cute Task Manager',
      theme: ThemeData(
        fontFamily: 'ComicSans',
        scaffoldBackgroundColor: const Color(0xFFFFF5F8),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

//  Bow widget for background
class BowWidget extends StatelessWidget {
  final double size;
  final double y;
  final double x;
  final double opacity;

  const BowWidget({
    super.key,
    required this.size,
    required this.y,
    required this.x,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: y,
      left: x,
      child: Opacity(
        opacity: opacity,
        child: Icon(
          Icons.favorite,
          size: size,
          color: const Color.fromARGB(255, 194, 90, 124).withOpacity(opacity),
        ),
      ),
    );
  }
}

//  Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Map<String, double>> bows = [];

  @override
  void initState() {
    super.initState();
    final random = Random();
    bows = List.generate(10, (index) {
      return {
        "x": random.nextDouble() * 300,
        "y": random.nextDouble() * 600,
        "size": 30 + random.nextDouble() * 20,
        "opacity": 0.4 + random.nextDouble() * 0.6
      };
    });

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..repeat();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TaskHomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFCCE5),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              ...bows.map((bow) {
                double newY = (bow["y"]! +
                        (_controller.value * 100) %
                            MediaQuery.of(context).size.height) %
                    MediaQuery.of(context).size.height;
                return BowWidget(
                  size: bow["size"]!,
                  x: bow["x"]!,
                  y: newY,
                  opacity: bow["opacity"]!,
                );
              }).toList(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.favorite, color: Colors.white, size: 100),
                    SizedBox(height: 20),
                    Text(
                      "My Sweet Tasks",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Organize your life with style 💖",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Task Screen
class TaskHomeScreen extends StatefulWidget {
  const TaskHomeScreen({super.key});
  @override
  State<TaskHomeScreen> createState() => _TaskHomeScreenState();
}

class _TaskHomeScreenState extends State<TaskHomeScreen> {
  List<Map<String, dynamic>> tasks = [];
  TextEditingController taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('tasks');
    if (savedData != null && savedData.isNotEmpty) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(jsonDecode(savedData));
      });
    }
  }

  Future<void> saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('tasks', jsonEncode(tasks));
  }

  void addTask(String title) {
    if (title.trim().isEmpty) return;
    setState(() {
      tasks.add({"title": title, "completed": false});
    });
    saveTasks();
    taskController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("🎀 Task Added!"),
        backgroundColor: Colors.pinkAccent,
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  void toggleTask(int index) {
    setState(() {
      tasks[index]['completed'] = !tasks[index]['completed'];
    });
    saveTasks();
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    saveTasks();
  }

  void showAddTaskDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => Center(
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              ...List.generate(6, (i) {
                final random = Random();
                return Positioned(
                  left: random.nextDouble() * 250,
                  top: random.nextDouble() * 250,
                  child: Icon(Icons.favorite,
                      color: Colors.pinkAccent.withOpacity(0.15),
                      size: 24 + random.nextDouble() * 12),
                );
              }),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("🎀 Add New Task",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.pink)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: taskController,
                      decoration: InputDecoration(
                        hintText: "Enter your cute task...",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) {
                        addTask(taskController.text);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        addTask(taskController.text);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("Add",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      transitionBuilder: (_, anim, __, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB6C1),
        title: const Text(
          "💖 My Sweet Tasks",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: showAddTaskDialog,
            icon: const Icon(Icons.add_task, size: 28, color: Colors.white),
          )
        ],
      ),
      body: Row(
        children: [
       if (isDesktop)
  Container(
    width: 500, 
    height: double.infinity, 
    color: Colors.white,
    child: Image.network(
      "https://media.istockphoto.com/id/1374485813/vector/3d-white-clipboard-task-management-todo-check-list-with-pencil-efficient-work-on-project.jpg?s=612x612&w=0&k=20&c=oHKBMqTKxzZEkm6k-8I7MGfhpft5DVSeT8qzXZNFoPM=",
      fit: BoxFit.cover,
      height: double.infinity,
    ),
  ),

          Expanded(
            child: Stack(
              children: [
                ...List.generate(6, (i) {
                  final random = Random();
                  return AnimatedPositioned(
                    duration: Duration(seconds: 5 + i),
                    left: random.nextDouble() *
                        MediaQuery.of(context).size.width,
                    top: random.nextDouble() *
                        MediaQuery.of(context).size.height,
                    child: Icon(Icons.favorite,
                        color: Colors.pinkAccent.withOpacity(0.2), size: 30),
                  );
                }),
                tasks.isEmpty
                    ? const Center(
                        child: Text(
                          "No tasks yet! Tap + to add one 🌸",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return Card(
                              color: Colors.white,
                              elevation: 3,
                              shadowColor:
                                  Colors.pinkAccent.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                leading: IconButton(
                                  icon: Icon(
                                    task['completed']
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    size: 28,
                                    color: task['completed']
                                        ? Colors.green
                                        : Colors.pinkAccent,
                                  ),
                                  onPressed: () => toggleTask(index),
                                ),
                                title: Text(
                                  task['title'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    decoration: task['completed']
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: task['completed']
                                        ? Colors.grey
                                        : Colors.black87,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent, size: 26),
                                  onPressed: () => deleteTask(index),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: showAddTaskDialog,
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}
