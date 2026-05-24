import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TaskSuggestionPage extends StatefulWidget {
  const TaskSuggestionPage({super.key});

  @override
  State<TaskSuggestionPage> createState() =>
      _TaskSuggestionPageState();
}

class _TaskSuggestionPageState extends State<TaskSuggestionPage> {
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("tasks");

    if (data != null) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("タスク選択")),

      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];

          return ListTile(
            title: Text(task["name"]),
            onTap: () {
              Navigator.pop(context, task["name"]);
            },
          );
        },
      ),
    );
  }
}