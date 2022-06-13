import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Constants.dart';
import '../Network.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<BookData> data = [];
  bool loaded = false;

  late String id;
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

  Future<List<BookData>> fetch() async {
    await GetState();
    final channel = WebSocketChannel.connect(webSocket());
    channel.sink.add(parser(
        packet(id, Handler.Handler1, Fetch.DeleteHistory, range: [-1, 0])));
    channel.stream.listen((event) {
      event = event.split(Header.Split)[1];
      for (dynamic i in jsonDecode(event)["Data"]) {
        BookData temp = BookData(i["ISBN"], i["BookName"], i["Author"],
            i["Availability"], i["Type"], i["Thumbnail"]);
        data.add(temp);
      }
      channel.sink.close();
      setState(() {});
    });
    return data;
  }

  @override
  void initState() {
    fetch();
    super.initState();
  }

  // add to data in fetch
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('History'),
        ),
        body: ListView.builder(
          itemCount: data.length,
          itemBuilder: ((context, index) {
            return BookListTile(
                ontap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (BuildContext context,
                              void Function(void Function()) setState) {
                            return AlertDialog(
                              scrollable: true,
                              title: Text('Permanent delete'),
                              content: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Form(
                                  child: Column(
                                    children: const <Widget>[
                                      Text(
                                          'Are you Sure you want to delete the Book??')
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('No'),
                                ),
                                TextButton(
                                    child: Text("Yes"),
                                    onPressed: () async{
                                      final channel = WebSocketChannel.connect(webSocket());
                                      channel.sink.add(parser(
                                          packet(id, Handler.Handler1, Remove.DeleteHistory, isbn: data[index].ISBN)));
                                      channel.stream.listen((event) {
                                        channel.sink.close();
                                        setState(() {});
                                      });
                                      Navigator.pop(context);
                                    })
                              ],
                            );
                          },
                        );
                      });
                },
                curBook: data[index]);
          }),
        ));
  }
}

class BookListTile extends StatefulWidget {
  Function ontap;
  BookData curBook;
  BookListTile({required this.ontap, required this.curBook});

  @override
  _BookListTileState createState() => _BookListTileState();
}

class _BookListTileState extends State<BookListTile> {
  @override
  Widget build(BuildContext context) {
    if (widget.curBook.Type & Avail.Online != 0 &&
        widget.curBook.Type & Avail.Offline != 0) {
      return ListTile(
          leading: const Card(
            color: Colors.deepPurpleAccent,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(' Both '),
            ),
          ),
          title: Row(
            children: [
              Text(widget.curBook.BookName),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: ClipOval(
                  child: Container(
                    color: Colors.red,
                    width: 20,
                    height: 20,
                    child: Center(
                      child: Text(
                        widget.curBook.Availability.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          trailing: Text(widget.curBook.Author),
          onTap: () {
            widget.ontap();
          });
    } else if (widget.curBook.Type & Avail.Online == 0) {
      return ListTile(
          leading: const Card(
            color: Colors.blue,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Offline'),
            ),
          ),
          title: Row(
            children: [
              Text(widget.curBook.BookName),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: ClipOval(
                  child: Container(
                    color: Colors.red,
                    width: 20,
                    height: 20,
                    child: Center(
                      child: Text(
                        widget.curBook.Availability.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          trailing: Text(widget.curBook.Author),
          onTap: () {
            widget.ontap();
          });
    } else {
      return ListTile(
          leading: const Card(
              color: Colors.green,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Online'),
              )),
          title: Text(widget.curBook.BookName),
          trailing: Text(widget.curBook.Author),
          onTap: () {
            widget.ontap();
          });
    }
  }
}
