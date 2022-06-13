import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Constants.dart';
import '../Network.dart';

class adminPendingRequestsPageBooks extends StatefulWidget {
  @override
  State<adminPendingRequestsPageBooks> createState() =>
      _adminPendingRequestsPageBooksState();
}

class _adminPendingRequestsPageBooksState
    extends State<adminPendingRequestsPageBooks> {
  @override
  late List<BookRequestData> data;
  bool loaded = false;
  String id = '';
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

  Future<List<BookRequestData>> fetch() async {
    String id;
    id = await GetState();
    final channel = WebSocketChannel.connect(webSocket());
    channel.sink.add(parser(
        packet(id, Handler.Handler1, Fetch.BookRequest, range: [-1, 0])));
    channel.stream.listen((event) {
      event = event.split(Header.Split)[1];
      for (dynamic i in jsonDecode(event)["Data"]) {
        i = jsonDecode(i);
        BookRequestData temp = BookRequestData(
            i["RequestID"].toString(),
            i["BookName"],
            i["Author"],
            i["RequestBy"],
            i["Status"],
            i['Reason']);
        data.add(temp);
      }
      // setState(() {
      // });
      channel.sink.close();
      setState(() {});
    });

    print(data);
    return data;
  }

  @override
  void initState() {
    GetState();
    data = [];
    fetch();
    super.initState();
  }

  TextEditingController comments = TextEditingController();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Pending Book Requests'),
          automaticallyImplyLeading: false),
      body: !loaded || data == []
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : Container(
              child: Container(
                  child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: ((context, index) {
                        List<String> items = [
                          'Processing',
                          'Approved',
                          'Declined'
                        ];
                        String dropdownvalue = items[0];
                        if (int.parse(data[index].Status) &
                                RequestStatus.processing ==
                            RequestStatus.processing) {
                          dropdownvalue = items[0];
                        } else if (int.parse(data[index].Status) &
                                RequestStatus.approved ==
                            RequestStatus.approved) {
                          dropdownvalue = items[1];
                        } else if (int.parse(data[index].Status) &
                                RequestStatus.declined ==
                            RequestStatus.declined) {
                          dropdownvalue = items[2];
                        } else {
                          dropdownvalue = items[0];
                        }
                        return ListTile(
                          title: Text(data[index].BookName),
                          leading: Text(data[index].Request),
                          subtitle: Text(data[index].Author),
                          trailing: Text(data[index].RequestedBy),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return StatefulBuilder(
                                    builder: (BuildContext context,
                                        void Function(void Function())
                                            setState) {
                                      comments.text = data[index].Reason;
                                      return AlertDialog(
                                        scrollable: true,
                                        title: Text(
                                            'Request ID : ${data[index].Request}'),
                                        content: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: DropdownButton(
                                                onChanged: (value) {
                                                  setState(() {
                                                    dropdownvalue =
                                                        value.toString();
                                                  });
                                                },
                                                items:
                                                    items.map((String items) {
                                                  return DropdownMenuItem(
                                                    value: items,
                                                    child: Text(items),
                                                  );
                                                }).toList(),
                                                value: dropdownvalue,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                controller: comments,
                                                decoration:
                                                    const InputDecoration(
                                                  labelText: 'Comments',
                                                  icon: Icon(Icons.comment),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                              child:
                                                  const Text("Update Status"),
                                              onPressed: () async {
                                                if (comments.text.isEmpty) {
                                                  showSnackbar(context,
                                                      "Comments cannot be left empty!");
                                                } else {
                                                  //add comments text field here
                                                  int toRet;
                                                  dropdownvalue == items[0]
                                                      ? toRet = RequestStatus
                                                          .processing
                                                      : dropdownvalue ==
                                                              items[1]
                                                          ? toRet =
                                                              RequestStatus
                                                                  .approved
                                                          : toRet =
                                                              RequestStatus
                                                                  .declined;

                                                  final channel =
                                                      WebSocketChannel.connect(
                                                          webSocket());
                                                  channel.sink.add(parser(
                                                      packet(
                                                          id,
                                                          Handler.Handler1,
                                                          Update.BookRequest,
                                                          status:
                                                              toRet.toString(),
                                                          reasons:
                                                              comments.text,
                                                          misc: data[index]
                                                              .Request)));
                                                  channel.stream
                                                      .listen((event) {
                                                    event = event
                                                        .split(Header.Split)[1];

                                                    channel.sink.close();
                                                    setState(() {});
                                                    Navigator.pop(context);
                                                  });
                                                }
                                              })
                                        ],
                                      );
                                    },
                                  );
                                });
                          },
                        );
                      }))),
            ),
    );
  }
}
