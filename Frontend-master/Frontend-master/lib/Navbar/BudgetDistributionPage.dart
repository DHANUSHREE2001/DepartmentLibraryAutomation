import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Constants.dart';
import '../Network.dart';

class BudgetDistributionPage extends StatefulWidget {
  const BudgetDistributionPage({Key? key}) : super(key: key);

  @override
  State<BudgetDistributionPage> createState() => _BudgetDistributionPageState();
}

class _BudgetDistributionPageState extends State<BudgetDistributionPage> {

  List<BudgetDistribution> data=[];

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

  Future<List<BudgetDistribution>> fetch() async {
    await GetState();
    final channel = WebSocketChannel.connect(webSocket());
    channel.sink.add(parser(
        packet(id, Handler.Handler1, Fetch.BudgetDistribution, range: [-1, 0])));
    channel.stream.listen((event) {
      event = event.split(Header.Split)[1];
      for (dynamic i in jsonDecode(event)["Data"]) {
        BudgetDistribution temp =  BudgetDistribution(i["InvestedOn"],i["Amount"]);
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
    fetch();
    super.initState();
  }

  // add to data in fetch
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Budget Distribution'),
        ),
        body: ListView.builder(
          itemCount: data.length,
          itemBuilder: ((context, index) {return ListTile(
            title: Text(data[index].InvestedOn),
            trailing: Text(data[index].Amount),
          ); }),
        ));
  }
}



// Card c = Card(
//   color: Colors.white,
//   elevation: 3,
//   shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(10)
//   ),
//   child: Padding(
//     padding: const EdgeInsets.all(8.0),
//     child: SfCartesianChart(
//         primaryXAxis: CategoryAxis(),
//         // Chart title
//         // Enable legend
//         legend: Legend(isVisible: true),
//         // Enable tooltip
//         tooltipBehavior: TooltipBehavior(enable: true),
//         series: <
//             ChartSeries<_YearlyCustomerData, String>>[
//           LineSeries<_YearlyCustomerData, String>(
//               color: canvasColor,
//               dataSource: yearlydata,
//               xValueMapper:
//                   (_YearlyCustomerData data, _) =>
//               data.year,
//               yValueMapper:
//                   (_YearlyCustomerData data, _) =>
//               data.count,
//               name: 'Count',
//               // Enable data label
//               dataLabelSettings:
//               DataLabelSettings(isVisible: true))
//         ]),
//   ),
// ),