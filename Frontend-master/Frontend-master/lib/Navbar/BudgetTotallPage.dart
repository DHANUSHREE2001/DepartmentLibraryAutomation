import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Constants.dart';
import '../Network.dart';

class BudgetTotalPage extends StatefulWidget {
  const BudgetTotalPage({Key? key}) : super(key: key);

  @override
  State<BudgetTotalPage> createState() => _BudgetTotalPageState();
}

class _BudgetTotalPageState extends State<BudgetTotalPage> {
  List<TotalBudget> data = [];
  bool loaded=false;

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

  Future<List<TotalBudget>> fetch() async {
    await GetState();
    final channel = WebSocketChannel.connect(webSocket());
    channel.sink.add(parser(
        packet(id, Handler.Handler1, Fetch.TotalBudget, range: [-1, 0])));
    channel.stream.listen((event) {
      event = event.split(Header.Split)[1];
      for (dynamic i in jsonDecode(event)["Data"]) {
        TotalBudget temp =  TotalBudget(i["BudgetID"], i["Src"], i["Amount"], i["UsedAmt"], i["Type"]);
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
    // TODO: implement initState
    fetch();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Total Budget'),
        ),
        body: ListView.builder(
          itemCount: data.length,
          itemBuilder: ((context, index) {
            return ListTile(
              leading: Text(data[index].BudgetID),
              title: Text(data[index].Src),
              subtitle: Text(data[index].type),
              trailing: Text(
                  'Amount - ${data[index].Amount} ,Used Amount - ${data[index].UsedAmt}'),
            );
          }),
        ));
  }
}


