import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../Constants.dart';
import '../../Network.dart';

class MyMagazine extends StatefulWidget {
  const MyMagazine({Key? key}) : super(key: key);

  @override
  State<MyMagazine> createState() => _MyMagazineState();
}

class _MyMagazineState extends State<MyMagazine> {
  List<BookRequestData> data = [];
  String id = "";
  String username = "";
  int status = 0;


  Future set() async {
    final prefs = await SharedPreferences.getInstance();
    id = prefs.getString("Id")!;
    username = prefs.getString("Name")!;
    status = prefs.getInt("Status")!;
  }

  Future<List<BookRequestData>> requests() async {
    final channel = WebSocketChannel.connect(webSocket());
    await set();
    channel.sink.add(parser(packet(
      id, Handler.Handler1, Fetch.MySubscription,
      range: [-1, 0], username: username, status: RequestStatus.approved.toString(),)));
    channel.stream.listen((event) {
      event = event.split(Header.Split)[1];
      print(event);
      for (dynamic i in jsonDecode(event)["Data"]) {
        i = jsonDecode(i);
        BookRequestData temp = BookRequestData(i["RequestID"].toString(),
            i["BookName"], i["Author"], i["RequestBy"], i["Status"].toString(),i["Reason"]);
        data.add(temp);
      }
      channel.sink.close();
      setState(() {});
    });
    return data;
  }

  @override
  void initState() {
    set();
    requests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Magazines'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: ListView.builder(
          itemCount: data.length,
          itemBuilder: ((context, index) {
            List<String> items = ['Processing', 'Approved', 'Declined'];
            return ListTile(
              title: Text(data[index].BookName),
              subtitle: Text(data[index].Author),
              onTap: () async {

              },
            );
          })),
    );
  }
}
