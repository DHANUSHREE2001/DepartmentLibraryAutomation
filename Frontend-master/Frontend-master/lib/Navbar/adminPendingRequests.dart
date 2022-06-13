import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Constants.dart';
import '../Network.dart';

class adminPendingRequestsPage extends StatefulWidget {
  String id;
  adminPendingRequestsPage({required this.id});

  @override
  State<adminPendingRequestsPage> createState() =>
      _adminPendingRequestsPageState();
}

class _adminPendingRequestsPageState extends State<adminPendingRequestsPage> {
  late List<BookRequestData> data;
  // void initState(){
  //   fetch();
  //   super.initState();
  // }
  Future<List<BookRequestData>> fetch() async {
    final channel = WebSocketChannel.connect(webSocket());
    channel.sink.add(parser(packet(
        widget.id, Handler.Handler1, Fetch.BookRequest,
        range: [-1, 0])));
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
            i["Reason"]);
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
    data = [];
    fetch();
    super.initState();
  }

  // Future<ListView> pendingBooksList(data) async {
  //   return ListView.builder(
  //       itemCount: data.length,
  //       itemBuilder: ((context, index) {
  //         List<String> items = ['Processing', 'Approved', 'Declined'];
  //         String dropdownvalue = items[0];
  //         if (int.parse(data[index].Status) & RequestStatus.processing ==
  //             RequestStatus.processing) {
  //           dropdownvalue = items[0];
  //         } else if (int.parse(data[index].Status) & RequestStatus.approved ==
  //             RequestStatus.approved) {
  //           dropdownvalue = items[1];
  //         } else if (int.parse(data[index].Status) & RequestStatus.declined ==
  //             RequestStatus.declined) {
  //           dropdownvalue = items[2];
  //         } else {
  //           dropdownvalue = items[0];
  //         }
  //         return ListTile(
  //           title: Text(data[index].BookName),
  //           leading: Text(data[index].Request),
  //           subtitle: Text(data[index].Author),
  //           trailing: Text(data[index].RequestedBy),
  //           onTap: () {
  //             showDialog(
  //                 context: context,
  //                 builder: (BuildContext context) {
  //                   return StatefulBuilder(
  //                     builder: (BuildContext context,
  //                         void Function(void Function()) setState) {
  //                       return AlertDialog(
  //                         scrollable: true,
  //                         title: Text('Request ID : ${data[index].Request}'),
  //                         content: Padding(
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: DropdownButton(
  //                             onChanged: (value) {
  //                               setState(() {
  //                                 dropdownvalue = value.toString();
  //                               });
  //                             },
  //                             items: items.map((String items) {
  //                               return DropdownMenuItem(
  //                                 value: items,
  //                                 child: Text(items),
  //                               );
  //                             }).toList(),
  //                             value: dropdownvalue,
  //                           ),
  //                         ),
  //                         actions: [
  //                           TextButton(
  //                             onPressed: () => Navigator.pop(context),
  //                             child: Text('Cancel'),
  //                           ),
  //                           TextButton(
  //                               child: Text("Update Status"),
  //                               onPressed: () {
  //                                 int toRet;
  //                                 dropdownvalue == items[0]
  //                                     ? toRet = RequestStatus.processing
  //                                     : dropdownvalue == items[1]
  //                                         ? toRet = RequestStatus.approved
  //                                         : toRet = RequestStatus.declined;
  //                                 update(data[index].Request, toRet);
  //
  //                                 Navigator.pop(context);
  //                               })
  //                         ],
  //                       );
  //                     },
  //                   );
  //                 });
  //           },
  //         );
  //       }));
  // }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Pending Requests'),
            backgroundColor: Colors.blue,
            elevation: 0,
            bottom: TabBar(
                unselectedLabelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.label,
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    color: Colors.lightBlueAccent),
                tabs: [
                  Tab(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                              color: Colors.lightBlueAccent, width: 1)),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text("Books"),
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                              color: Colors.lightBlueAccent, width: 1)),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text("Magazines"),
                      ),
                    ),
                  ),
                ]),
          ),
          body: TabBarView(children: [
            Container(
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
                                      return AlertDialog(
                                        scrollable: true,
                                        title: Text(
                                            'Request ID : ${data[index].Request}'),
                                        content: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: DropdownButton(
                                            onChanged: (value) {
                                              setState(() {
                                                dropdownvalue =
                                                    value.toString();
                                              });
                                            },
                                            items: items.map((String items) {
                                              return DropdownMenuItem(
                                                value: items,
                                                child: Text(items),
                                              );
                                            }).toList(),
                                            value: dropdownvalue,
                                          ),
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
                                              onPressed: () {
                                                int toRet;
                                                dropdownvalue == items[0]
                                                    ? toRet =
                                                        RequestStatus.processing
                                                    : dropdownvalue == items[1]
                                                        ? toRet = RequestStatus
                                                            .approved
                                                        : toRet = RequestStatus
                                                            .declined;

                                                // code here!!
                                                final channel =
                                                    WebSocketChannel.connect(
                                                        webSocket());
                                                channel.sink.add(parser(packet(
                                                    "",
                                                    Handler.Handler1,
                                                    Update.MagazineRequest,
                                                    status: toRet.toString(),
                                                    misc:
                                                        data[index].Request)));
                                                channel.stream.listen((event) {
                                                  event = event
                                                      .split(Header.Split)[1];

                                                  channel.sink.close();
                                                  setState(() {});

                                                  Navigator.pop(context);
                                                });
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
            // Container(
            //     child: FutureBuilder(
            //         // future: fetch(),
            //         builder: (context, AsyncSnapshot snapshot) {
            //           if (!snapshot.hasData) {
            //             return Center(child: CircularProgressIndicator());
            //           } else {
            //             return Container(
            //                 child: ListView.builder(
            //                     itemCount: data.length,
            //                     itemBuilder: ((context, index) {
            //                       List<String> items = [
            //                         'Processing',
            //                         'Approved',
            //                         'Declined'
            //                       ];
            //                       String dropdownvalue = items[0];
            //                       if (int.parse(data[index].Status) &
            //                               RequestStatus.processing ==
            //                           RequestStatus.processing) {
            //                         dropdownvalue = items[0];
            //                       } else if (int.parse(
            //                                   data[index].Status) &
            //                               RequestStatus.approved ==
            //                           RequestStatus.approved) {
            //                         dropdownvalue = items[1];
            //                       } else if (int.parse(
            //                                   data[index].Status) &
            //                               RequestStatus.declined ==
            //                           RequestStatus.declined) {
            //                         dropdownvalue = items[2];
            //                       } else {
            //                         dropdownvalue = items[0];
            //                       }
            //                       return ListTile(
            //                         title: Text(data[index].BookName),
            //                         leading: Text(data[index].Request),
            //                         subtitle: Text(data[index].Author),
            //                         trailing:
            //                             Text(data[index].RequestedBy),
            //                         onTap: () {
            //                           showDialog(
            //                               context: context,
            //                               builder: (BuildContext context) {
            //                                 return StatefulBuilder(
            //                                   builder: (BuildContext context,
            //                                       void Function(void Function())
            //                                           setState) {
            //                                     return AlertDialog(
            //                                       scrollable: true,
            //                                       title: Text(
            //                                           'Request ID : ${data[index].Request}'),
            //                                       content: Padding(
            //                                         padding:
            //                                             const EdgeInsets.all(
            //                                                 8.0),
            //                                         child: DropdownButton(
            //                                           onChanged: (value) {
            //                                             setState(() {
            //                                               dropdownvalue =
            //                                                   value.toString();
            //                                             });
            //                                           },
            //                                           items: items
            //                                               .map((String items) {
            //                                             return DropdownMenuItem(
            //                                               value: items,
            //                                               child: Text(items),
            //                                             );
            //                                           }).toList(),
            //                                           value: dropdownvalue,
            //                                         ),
            //                                       ),
            //                                       actions: [
            //                                         TextButton(
            //                                           onPressed: () =>
            //                                               Navigator.pop(
            //                                                   context),
            //                                           child: Text('Cancel'),
            //                                         ),
            //                                         TextButton(
            //                                             child: Text(
            //                                                 "Update Status"),
            //                                             onPressed: () {
            //                                               int toRet;
            //                                               dropdownvalue ==
            //                                                       items[0]
            //                                                   ? toRet =
            //                                                       RequestStatus
            //                                                           .processing
            //                                                   : dropdownvalue ==
            //                                                           items[1]
            //                                                       ? toRet =
            //                                                           RequestStatus
            //                                                               .approved
            //                                                       : toRet =
            //                                                           RequestStatus
            //                                                               .declined;
            //
            //                                               // code here!!
            //                                               update(data[index].Request, toRet);
            //                                               Navigator.pop(
            //                                                   context);
            //                                             })
            //                                       ],
            //                                     );
            //                                   },
            //                                 );
            //                               });
            //                         },
            //                       );
            //                     })));
            //           }
            //         })),
            Container(
              child: Text('Magazines'),
            )
          ]),
        ));
  }
}
