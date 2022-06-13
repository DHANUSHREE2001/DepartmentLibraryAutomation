import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:library_management/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Network.dart';

class UserBorrowedBooks extends StatefulWidget {
  const UserBorrowedBooks({Key? key}) : super(key: key);

  @override
  State<UserBorrowedBooks> createState() => _UserBorrowedBooksState();
}

class _UserBorrowedBooksState extends State<UserBorrowedBooks> {
  late String id;
  List<BookTaken> data = [];
  bool loaded = false;
  Future<String> GetState() async {
    final prefs = await SharedPreferences.getInstance();
    id = prefs.getString("Id")!;
    if (id != null) {
      loaded = true;
      setState(() {});
    }
    print(loaded);
    return id;
  }

  Future<List<BookTaken>> fetch() async {
    id = await GetState();
    final channel = WebSocketChannel.connect(webSocket());
    channel.sink.add(parser(
        packet(id, Handler.Handler1, Fetch.UserIssuedBook, range: [-1, 0])));
    channel.stream.listen((event) {
      event = event.split(Header.Split)[1];
      for (dynamic i in jsonDecode(event)["Data"]) {
        i = jsonDecode(i);
        BookTaken temp = BookTaken(i["ISBN"], i["dateIssued"], i["BookName"]);
        data.add(temp);
      }
      channel.sink.close();
      setState(() {});
    });
    return [];
  }

  @override
  void initState() {
    // GetState();
    fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Borrowed Books')),
      body: Container(
          child: ListView.builder(
              itemCount: data.length,
              itemBuilder: ((context, index) {
                DateTime tempDate =
                    DateFormat("dd/MM/yy").parse(data[index].DateIssued);
                bool isDue = DateTime.now().isAfter(tempDate);
                return ListTile(
                  title: Text(data[index].BookName),
                  subtitle: Text(data[index].ISBN),
                  trailing: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        data[index].DateIssued,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    color: isDue ? Colors.red : Colors.green,
                  ),
                  onTap: () {
                    if (isDue) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (BuildContext context,
                                  void Function(void Function()) setState) {
                                return AlertDialog(
                                  scrollable: true,
                                  title: const Text('Request'),
                                  content: Column(
                                    children: [
                                      ElevatedButton(
                                          onPressed: () {},
                                          child: const Text('Pay Fine')),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                        child: const Text("Update Status"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        })
                                  ],
                                );
                              },
                            );
                          });
                    }
                  },
                );
              }))),
    );
  }
}
