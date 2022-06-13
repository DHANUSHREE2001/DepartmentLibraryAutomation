import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:library_management/Constants.dart';
import 'package:library_management/Network.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class newsWindow extends StatefulWidget {
  String id;
  String category;
  newsWindow({required this.id,required this.category});

  @override
  _newsWindowState createState() => _newsWindowState();
}

class _newsWindowState extends State<newsWindow> {
  bool done = false;
  var jsonData;
  int fetchCount = 0;
  var i = 0;
  void fetch() async {
    final channel = WebSocketChannel.connect(webSocket());
    channel.sink.add(parser(packet(widget.id,Handler.Handler1, Fetch.News,category: widget.category)));
    channel.stream.listen((event) {
      event = event.split(Header.Split)[1];
      event = json.decode(event);
      var data = event["Data"];
      var News = data["News"];
      jsonData = jsonDecode(News);
      done = true;
      fetchCount = jsonData["articles"].length;
      setState(() {});
      channel.sink.close();
    });
  }

  Widget news(int index) {
    String imageUrl = jsonData["articles"][index]["urlToImage"] ?? "";
    String url = jsonData["articles"][index]["url"] ?? "";
    String title = jsonData["articles"][index]["title"] ?? "";
    String description = jsonData["articles"][index]["content"] ?? "";
    description = description.replaceAll(RegExp("\\[.*?\\]"), "");
    String time = jsonData["articles"][index]["publishedAt"] ?? "";

    var image = Image.network(
      imageUrl,
      fit: BoxFit.fitWidth,
      errorBuilder:
          (BuildContext context, Object exception, StackTrace? stackTrace) {
        return Container();
      },
    );

    Widget widget = GestureDetector(
      onTap: () {
        html.window.open(url, "_blank");
      },
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: image,
              ),
              Text(description),
              SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                    child: Text(
                      time.substring(0, 10),
                      textAlign: TextAlign.right,
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    if (!done) {
      fetch();
    }
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("lib/Login/bg.jpg"), fit: BoxFit.fill)),
      height: double.infinity,
      child: MasonryGridView.count(
          crossAxisCount: 5,
          itemCount: fetchCount,
          itemBuilder: (BuildContext context, int index) {
            if (done) {
              return news(index);
            } else {
              return Container();
            }
          },
      ),
    );
  }
}
