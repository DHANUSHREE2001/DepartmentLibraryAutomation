import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../Constants.dart';
import '../../Network.dart';

class MagazineRequestStatus extends StatefulWidget {
  const MagazineRequestStatus({Key? key}) : super(key: key);

  @override
  State<MagazineRequestStatus> createState() => _MagazineRequestStatusState();
}

class _MagazineRequestStatusState extends State<MagazineRequestStatus> {
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
      id,
      Handler.Handler1,
      Fetch.MyMagazineRequest,
      range: [-1, 0],
      username: username,
    )));
    channel.stream.listen((event) {
      event = event.split(Header.Split)[1];
      for (dynamic i in jsonDecode(event)["Data"]) {
        BookRequestData temp = BookRequestData("",
            i["JournalName"], "", i["UserName"], i["Status"].toString(),"");
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
        title: const Text('Magazine Requests'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: ListView.builder(
          itemCount: data.length,
          itemBuilder: ((context, index) {
            List<String> items = ['Processing', 'Approved', 'Declined'];
            String dropdownvalue = items[0];
            if (int.parse(data[index].Status) & RequestStatus.processing ==
                RequestStatus.processing) {
              dropdownvalue = items[0];
            } else if (int.parse(data[index].Status) & RequestStatus.approved ==
                RequestStatus.approved) {
              dropdownvalue = items[1];
            } else if (int.parse(data[index].Status) & RequestStatus.declined ==
                RequestStatus.declined) {
              dropdownvalue = items[2];
            } else {
              dropdownvalue = items[0];
            }
            return ListTile(
              title: Text(data[index].BookName),
              subtitle: Text(data[index].Author),
              trailing: Text(dropdownvalue),
              onTap: () {},
            );
          })),
    );
  }
}
