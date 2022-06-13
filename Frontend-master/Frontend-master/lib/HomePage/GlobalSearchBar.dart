import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:library_management/Constants.dart';
import 'package:library_management/HomePage/pdfViewer.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:library_management/Network.dart';

class SearchBar extends StatefulWidget {
  String id;

  SearchBar(this.id);
  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  List<dynamic> ret1 = [];

  bool bookNameCheckbox = true;
  bool bookAuthorCheckbox = false;
  bool bookISBNCheckbox = false;
  bool magAuthorCheckbox = false;
  bool magNameCheckbox = false;
  String dropdownvalue = 'Books';
  String dropdownvaluefilter = 'ASC';
  var items = [
    'Books',
    'Magazines',
  ];
  var filteritems = ['ASC', 'DESC'];

  Future<List<dynamic>> fetch(String name) async {
    final channel = WebSocketChannel.connect(webSocket());
    List<String> Params = [];
    String ISBN = "";
    String Author = "";

    if (dropdownvalue == "Books") {
      if (bookAuthorCheckbox) {
        Params.add(BookParams.Author);
        Author = name;
      }
      if (bookISBNCheckbox) {
        Params.add(BookParams.ISBN);
        ISBN = name;
      }
      if (bookNameCheckbox) {
        Params.add(BookParams.Name);
      }
      channel.sink.add(parser(packet(widget.id, Handler.Handler1, Search.Books,
          bookName: name,
          isbn: ISBN,
          author: [Author],
          searchFilter: Params,
          count: 10,
          sort: dropdownvaluefilter)));

      var Str = channel.stream.listen((event) {
        ret1 = [];
        event = event.split(Header.Split)[1];
        for (dynamic i in jsonDecode(event)["Data"]) {
          BookData tmp = BookData(i["ISBN"], i["BookName"], i["Author"],
              i["Availability"], i["Type"], i["Thumbnail"]);
          ret1.add(tmp);
        }
        channel.sink.close();
      });
      await Str.asFuture();
    } else {
      if (bookAuthorCheckbox) {
        Params.add(MagazineParams.Author);
        Author = name;
      }
      if (bookNameCheckbox) {
        Params.add(MagazineParams.Name);
      }
      channel.sink.add(parser(packet(
          widget.id, Handler.Handler1, Search.Magazines,
          bookName: name,
          searchFilter: Params,
          author: [Author],
          count: 10,
          sort: dropdownvaluefilter)));
      print(channel.stream.toString());
      var Str = channel.stream.listen((event) {
        ret1 = [];
        event = event.split(Header.Split)[1];
        for (dynamic i in jsonDecode(event)["Data"]) {
          MagazineData tmp = MagazineData(i["Name"], i["Volume"], i["Issue"],
              i["ReleaseDate"], i["Location"]);
          ret1.add(tmp);
        }
        channel.sink.close();
      });
      await Str.asFuture();
    }
    return ret1;
  }

  Widget Popup() {
    return PopupMenuButton<int>(
        child: const Padding(
          padding: EdgeInsets.only(right: 4),
          child: Icon(
            Icons.filter_alt,
          ),
        ),
        itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: StatefulBuilder(
                  builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.library_books,
                            color: Colors.blue,
                          ),
                          title: const Text('Type'),
                          trailing: DropdownButton(
                            // Initial Value
                            value: dropdownvalue,

                            // Down Arrow Icon
                            icon: const Icon(Icons.keyboard_arrow_down),

                            // Array list of items
                            items: items.map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: Text(items),
                              );
                            }).toList(),
                            // After selecting the desired option,it will
                            // change button value to selected value
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownvalue = newValue!;
                              });
                            },
                          ),
                        ),
                        ListTile(
                            leading: const Icon(
                              Icons.article_outlined,
                              color: Colors.blue,
                            ),
                            title: const Text('Order'),
                            trailing: DropdownButton(
                              // Initial Value
                              value: dropdownvaluefilter,

                              // Down Arrow Icon
                              icon: const Icon(Icons.keyboard_arrow_down),

                              // Array list of items
                              items: filteritems.map((String items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items),
                                );
                              }).toList(),
                              // After selecting the desired option,it will
                              // change button value to selected value
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownvaluefilter = newValue!;
                                });
                              },
                            )),
                        dropdownvalue == 'Books'
                            ? Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text('Author'),
                                  const SizedBox(
                                    width: 75,
                                  ),
                                  Checkbox(
                                    value: bookAuthorCheckbox,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        bookAuthorCheckbox = value!;
                                      });
                                    },
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text('Author'),
                                  const SizedBox(
                                    width: 75,
                                  ),
                                  Checkbox(
                                    value: magAuthorCheckbox,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        magAuthorCheckbox = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                        dropdownvalue == 'Books'
                            ? Row(
                                children: [
                                  const Icon(
                                    Icons.assignment_outlined,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text('Title'),
                                  const SizedBox(
                                    width: 89,
                                  ),
                                  Checkbox(
                                    value: bookNameCheckbox,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        bookNameCheckbox = value!;
                                      });
                                    },
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  const Icon(
                                    Icons.assignment_outlined,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text('Title'),
                                  const SizedBox(
                                    width: 89,
                                  ),
                                  Checkbox(
                                    value: magNameCheckbox,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        magNameCheckbox = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                        dropdownvalue == 'Books'
                            ? Row(
                                children: [
                                  const Icon(
                                    Icons.article_outlined,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text('ISBN'),
                                  const SizedBox(
                                    width: 85,
                                  ),
                                  Checkbox(
                                    value: bookISBNCheckbox,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        const Icon(
                                          Icons.assignment_outlined,
                                          color: Colors.blue,
                                        );
                                        bookISBNCheckbox = value!;
                                      });
                                    },
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ],
                    );
                  },
                ),
                value: 1,
              ),
            ]);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 10.0,
          ),
          TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              decoration: InputDecoration(
                  focusColor: Colors.white70,
                  fillColor: Colors.white70,
                  filled: true,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Popup(),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                  hintText: 'Search.....'),
            ),
            suggestionsCallback: (pattern) async {
              var data = await fetch(pattern);
              return data;
            },
            itemBuilder: (context, dynamic suggestion) {
              return dropdownvalue == items[0] ? BookListTile(
                  ontap: () async {
                    final channel = WebSocketChannel.connect(webSocket());
                    channel.sink.add(parser(packet(
                        widget.id, Handler.Handler1, Fetch.DigitalBooks,
                        isbn: suggestion.ISBN)));
                    channel.stream.listen((event) async {
                      event = event.split(Header.Split)[1];
                      var link = jsonDecode(event)["Data"];
                      print(link);
                      js.context.callMethod('open', ['$link']);
                      // var file = await DefaultCacheManager().downloadFile(link);
                      // print(file.file.uri);
                      // final blob = html.Blob([file.file.path], 'application/pdf');
                      // var bytestream = await file.file.readAsBytes();
                      // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PdfViewer(name: suggestion.BookName, link: link)));
                      // html.window.open(url, '_blank');
                      // PdftronFlutter.openDocument(link);
                      channel.sink.close();
                    });
                  },
                  curBook: suggestion):MagListTile(ontap: (){
                js.context.callMethod('open', ['${suggestion.Location}']);
              }, curBook: suggestion);
            },
            onSuggestionSelected: (dynamic suggestion) {
              print(suggestion);
            },
          ),
        ],
      ),
    );
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


class MagListTile extends StatefulWidget {
  Function ontap;
  MagazineData curBook;
  MagListTile({required this.ontap, required this.curBook});

  @override
  _MagListTileState createState() => _MagListTileState();
}

class _MagListTileState extends State<MagListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: const Card(
          color: Colors.green,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Online'),
          ),
        ),
        title: Row(
          children: [
            Text(widget.curBook.Name),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: ClipOval(
                child: Container(
                  color: Colors.red,
                  width: 20,
                  height: 20,
                  child: Center(
                    child: Text(
                      widget.curBook.Volume.toString(),
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
        subtitle: Text('Release date - ${widget.curBook.ReleaseDate}'),
        trailing: Text(widget.curBook.Issue),
        onTap: () {
          widget.ontap();
        });
  }
}