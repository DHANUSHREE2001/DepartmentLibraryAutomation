

import 'package:flutter/material.dart';
import 'package:library_management/HomePage/GlobalSearchBar.dart';
import 'package:library_management/opac/pop_up_filter.dart';


class opacHome extends StatefulWidget {
  String id;
  String title;
  opacHome({required this.id , required this.title});

  @override
  _opacHomeState createState() => _opacHomeState();
}

class _opacHomeState extends State<opacHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: SearchBar(widget.id),
      ),
    );
  }
}