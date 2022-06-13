import 'package:flutter/material.dart';
import 'newswindow.dart';

class news extends StatefulWidget {
  String id;
  news({required this.id});

  @override
  _newsState createState() => _newsState();
}

class _newsState extends State<news> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
          appBar: const TabBar(tabs: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
              child: Text("General"),
            ),
            Text("Business"),
            Text("Entertainment"),
            Text("Health"),
            Text("Science"),
            Text("Sports"),
            Text("Technology")
          ],labelColor: Color.fromARGB(255, 0, 0, 0)),
          body: TabBarView(children: [
            newsWindow(id: widget.id, category: "general"),
            newsWindow(id: widget.id, category: "business"),
            newsWindow(id: widget.id, category: "entertainment"),
            newsWindow(id: widget.id, category: "health"),
            newsWindow(id: widget.id, category: "science"),
            newsWindow(id: widget.id, category: "sports"),
            newsWindow(id: widget.id, category: "technology"),
          ])),
    );
  }
}
