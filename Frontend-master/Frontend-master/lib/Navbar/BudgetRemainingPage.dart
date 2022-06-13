import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Constants.dart';
import '../Network.dart';

class BudgetRemainingPage extends StatefulWidget {
  const BudgetRemainingPage({Key? key}) : super(key: key);

  @override
  State<BudgetRemainingPage> createState() => _BudgetRemainingPageState();
}

class _BudgetRemainingPageState extends State<BudgetRemainingPage> {

  List<remainingBudget> data=[];
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

  Future<List<remainingBudget>> fetch() async {
    await GetState();
    final channel = WebSocketChannel.connect(webSocket());
    channel.sink.add(parser(
        packet(id, Handler.Handler1, Fetch.RemainingBudget, range: [-1, 0])));
    channel.stream.listen((event) {
      event = event.split(Header.Split)[1];
      for (dynamic i in jsonDecode(event)["Data"]) {
        remainingBudget temp =  remainingBudget(i["Type"], i["RemainingAmt"]);
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

  // add to data in fetch
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remaining Budget'),
      ),
      body: ListView.builder(
      itemCount: data.length,
      itemBuilder: ((context, index) {return ListTile(
        title: Text(data[index].type),
        trailing: Text(data[index].sum),
    ); }),
    ));
  }
}

