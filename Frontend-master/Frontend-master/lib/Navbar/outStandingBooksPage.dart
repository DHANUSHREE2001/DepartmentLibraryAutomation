import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:library_management/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Network.dart';

class OutStandingRequests extends StatefulWidget {
  const OutStandingRequests({Key? key}) : super(key: key);

  @override
  State<OutStandingRequests> createState() => _OutStandingRequestsState();
}

class _OutStandingRequestsState extends State<OutStandingRequests> {
  late String id;
  Future<String> GetState() async {
    final prefs = await SharedPreferences.getInstance();
    id = prefs.getString("Id")!;
    if(id!=null){
      loaded=true;
      setState(() {});
    }
    print(loaded);
    return id;
  }

  Future<List<BookIssue>> fetch() async {
    await GetState();
    final channel = WebSocketChannel.connect(webSocket());
    List<BookIssue> data = [];
    channel.sink.add(parser(
        packet(id, Handler.Handler1, Fetch.DueUsers, range: [-1, 0])));
    channel.stream.listen((event) {
      event = event.split(Header.Split)[1];
      for (dynamic i in jsonDecode(event)["Data"]) {
        BookIssue temp = BookIssue(i["IssueID"], i["ISBN"],i["IssuedTo"], i["dateIssued"], i["BookName"]);
        data.add(temp);
      }
      channel.sink.close();
      setState(() {

      });
    });
    return data;
  }

  @override
  void initState() {
    // GetState();
    data=[];
    fetch();
    super.initState();
  }
  // void update(String id,String Status)async{
  //   final channel = WebSocketChannel.connect(webSocket());
  //   channel.sink.add(parser(
  //       packet(id, Handler.Handler1, Update.BookRequest,misc: id,status: Status.toString())));
  // }


  late List<OutstandingListData> data ;
  bool loaded=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Outstanding requests'),
      ),
      body:  Container(
          child: ListView.builder(
              itemCount: data.length,
              itemBuilder: ((context, index) {
                DateTime tempDate = DateFormat("dd/MM/yy").parse(data[index].DueDate);
                bool isDue = DateTime.now().isAfter(tempDate);
                return ListTile(
                  title: Text(data[index].ISBN),
                  leading: Text(data[index].BorrowID),
                  subtitle: Text(data[index].UserName),
                  trailing: Card(child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Text(data[index].DueDate,style: TextStyle(
                      color: Colors.white,
                    ),),
                  ),
                    color: isDue?Colors.red:Colors.green,
                  ),
                  onTap: () {
                    List<String> items = [
                      'NotReturned',
                      'Returned',
                    ];
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String dropdownvalue = items[0];
                          return StatefulBuilder(
                            builder: (BuildContext context,
                                void Function(void Function())
                                setState) {
                              return AlertDialog(
                                scrollable: true,
                                title: Text(
                                    'Request ID : ${data[index].BorrowID}'),
                                content: Column(
                                  children: [
                                    Padding(
                                      padding:
                                      const EdgeInsets.all(
                                          8.0),
                                      child: DropdownButton(
                                        onChanged: (value) {
                                          setState(() {
                                            dropdownvalue =
                                                value.toString();
                                          });
                                        },
                                        items: items
                                            .map((String items) {
                                          return DropdownMenuItem(
                                            value: items,
                                            child: Text(items),
                                          );
                                        }).toList(),
                                        value: dropdownvalue,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(
                                            context),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                      child: const Text(
                                          "Update Status"),
                                      onPressed: () {
                                          //add comments text field here
                                          // String DueDate = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
                                          // dropdownvalue == items[0] ? data[index].ReturnDate = DueDate:data[index].ReturnDate='';
                                          //
                                          // update(data[index].BorrowID, data[index].ReturnDate);
                                          // Navigator.pop(
                                          //     context);

                                      })
                                ],
                              );
                            },
                          );
                        });
                  },
                );
              }))),
    );
  }
}
