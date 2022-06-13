import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'dart:typed_data';
import 'dart:js' as js;
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:library_management/Constants.dart';
import 'package:library_management/Navbar/DeleteHisttory.dart';
import 'package:library_management/Navbar/adminPendingRequests.dart';
import 'package:library_management/Navbar/outStandingBooksPage.dart';
import 'package:library_management/Navbar/userBorrowedBooks.dart';
import 'package:library_management/Network.dart';
import 'package:library_management/opac/opac_main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NavBar extends StatefulWidget {
  String curStatus;
  String username;
  String id;

  NavBar({required this.curStatus, required this.username, required this.id});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late List<BookRequestData> data;

  void fetch() async {
    final channel = WebSocketChannel.connect(webSocket());
    channel.sink.add(parser(packet(
        widget.id, Handler.Handler1, Fetch.BookRequest,
        range: [-1, 0])));
    channel.stream.listen((event) {
      event = event.split(Header.Split)[1];
      for (dynamic i in jsonDecode(event)["Data"]) {
        i = jsonDecode(i);
        BookRequestData temp = BookRequestData(i["RequestID"], i["BookName"],
            i["Author"], i["RequestBy"], i["Status"], i["Reason"]);
        data.add(temp);
      }
      channel.sink.close();
      setState(() {});
    });
  }

  void changePasswordAPI(
      dynamic oldPassController, dynamic newPassController) async {
    final channel = WebSocketChannel.connect(webSocket());

    channel.sink.add(parser(packet(widget.id, Handler.Handler1, Update.Password,
        password: sha512
            .convert(utf8.encode(oldPassController.text.toString().trim()))
            .toString(),
        misc: sha512
            .convert(utf8.encode(newPassController.text.toString().trim()))
            .toString())));
    channel.stream.listen((event) {
      event = event.split(Header.Split)[1];
      event = jsonDecode(event);
      if (event["Header"] == Header.Success) {
        showSnackbar(context, "Password changed");
      } else if (event["Header"] == Header.Failed) {
        if (event["Failure"] == Failure.Credentials) {
          showSnackbar(context, "Invalid credentials");
        } else {
          showSnackbar(context, "Try after sometime");
        }
      }
    });
  }

  void addBookRequest(String UserName, String Author, String BookName) {
    final channel = WebSocketChannel.connect(webSocket());
    channel.sink.add(parser(packet(widget.id, Handler.Handler1, Add.BookRequest,
        bookName: BookName, username: UserName, author: [Author])));
    channel.stream.listen((event) {
      channel.sink.close();
    });
  }

  void addMagazineRequest(String UserName, String Author, String BookName) {
    final channel = WebSocketChannel.connect(
      webSocket(),
    );
    channel.sink.add(parser(packet(
        widget.id, Handler.Handler1, Add.MagazineSubscriptionRequest,
        bookName: BookName, username: UserName, author: [Author])));
    channel.stream.listen((event) {
      channel.sink.close();
    });
  }

  bool online_avail = false;
  bool offline_avail = false;
  String dropdownvalue = 'Offline';
  var items = [
    'Online',
    'Offline',
    'Both',
  ];
  String DueDate = '';
  void selectedItemCirculation(BuildContext context, int item) {
    switch (item) {
      case 1:
        print('View Profile');
        // Navigator.push(context, MaterialPageRoute(builder: (context)=>OutStandingRequests()));
        Navigator.pushNamed(context, '/OutStandingRequests');
        setState(() {});
        break;
      case 0:
        showDialog(
            builder: (BuildContext context) {
              return StatefulBuilder(builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return AlertDialog(
                  title: const Text('New Book Borrowal'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        final channel = WebSocketChannel.connect(
                          webSocket(),
                        );
                        channel.sink.add(parser(packet(
                            widget.id, Handler.Handler1, Add.BookIssue,
                            isbn: BookNameController.text,
                            username: UsernameController.text)));
                        channel.stream.listen((event) {
                          channel.sink.close();
                        });

                        // print('Due date - $DueDate');
                        setState(() {});
                        Navigator.of(context).pop();
                      },
                      child: const Text('Add record'),
                    ),
                  ],
                  scrollable: true,
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: BookNameController,
                            decoration: const InputDecoration(
                              labelText: 'Enter ISBN',
                              icon: Icon(Icons.book),
                            ),
                          ),
                          TextFormField(
                            controller: UsernameController,
                            decoration: const InputDecoration(
                              labelText: 'Enter username',
                              icon: Icon(Icons.account_circle),
                            ),
                          ),
                          // ListTile(
                          //   title: Text('Due Date'),
                          //   subtitle: Text(
                          //       '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                          //   leading: IconButton(
                          //     icon: Icon(Icons.calendar_today),
                          //     onPressed: () {
                          //       _selectDate(context);
                          //     },
                          //   ),
                          // ),
                          // TextFormField(
                          //   controller: DueDateController,
                          //   decoration: InputDecoration(
                          //     labelText: 'Due Date',
                          //     icon: IconButton(icon:Icon(Icons.calendar_today), onPressed: () {_selectDate(context);},),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                );
              });
            },
            context: context);
        setState(() {});
        break;
    }
  }

  void selectedItemBudget(BuildContext context, int item) {
    //////add Budget details here
    switch (item) {
      case 0:
        showDialog(
            builder: (BuildContext context) {
              var srcController = TextEditingController();
              var amtController = TextEditingController();
              var usedAmtController = TextEditingController();
              var typeController = TextEditingController();
              return StatefulBuilder(builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return AlertDialog(
                  title: const Text('Add Budget'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // print('Due date - $DueDate');
                        final channel = WebSocketChannel.connect(
                          webSocket(),
                        );
                        channel.sink.add(parser(packet(
                            widget.id, Handler.Handler1, Add.BudgetRecord,
                            src: srcController.text,
                            budgetAmt: int.parse(amtController.text),
                            usedBudgetAmt: int.parse(usedAmtController.text),
                            budgetType: typeController.text)));
                        channel.stream.listen((event) {
                          channel.sink.close();
                        });
                        setState(() {});
                        Navigator.of(context).pop();
                      },
                      child: const Text('Add record'),
                    ),
                  ],
                  scrollable: true,
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: srcController,
                            decoration: const InputDecoration(
                              labelText: 'Source',
                              icon: Icon(Icons.book),
                            ),
                          ),
                          TextFormField(
                            controller: amtController,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              icon: Icon(Icons.account_circle),
                            ),
                          ),
                          TextFormField(
                            controller: usedAmtController,
                            decoration: const InputDecoration(
                              labelText: 'Used Amount',
                              icon: Icon(Icons.account_circle),
                            ),
                          ),
                          TextFormField(
                            controller: typeController,
                            decoration: const InputDecoration(
                              labelText: 'Type',
                              icon: Icon(Icons.account_circle),
                            ),
                          ),
                          // ListTile(
                          //   title: Text('Due Date'),
                          //   subtitle: Text(
                          //       '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                          //   leading: IconButton(
                          //     icon: Icon(Icons.calendar_today),
                          //     onPressed: () {
                          //       _selectDate(context);
                          //     },
                          //   ),
                          // ),
                          // TextFormField(
                          //   controller: DueDateController,
                          //   decoration: InputDecoration(
                          //     labelText: 'Due Date',
                          //     icon: IconButton(icon:Icon(Icons.calendar_today), onPressed: () {_selectDate(context);},),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                );
              });
            },
            context: context);
        setState(() {});

        break;
      case 1:
        showDialog(
            builder: (BuildContext context) {
              var budgetIdController = TextEditingController();
              var amtController = TextEditingController();
              var investedController = TextEditingController();
              return StatefulBuilder(builder: (BuildContext context,
                  void Function(void Function()) setState) {
                return AlertDialog(
                  title: const Text('Add Expenditure'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // print('Due date - $DueDate');
                        final channel = WebSocketChannel.connect(
                          webSocket(),
                        );
                        channel.sink.add(parser(packet(
                            widget.id, Handler.Handler1, Add.ExpenditureRecord,
                            budgetID: budgetIdController.text,
                            investedOn: investedController.text,
                            expAmt: int.parse(amtController.text))));
                        channel.stream.listen((event) {
                          channel.sink.close();
                        });
                        setState(() {});
                        Navigator.of(context).pop();
                      },
                      child: const Text('Add record'),
                    ),
                  ],
                  scrollable: true,
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: budgetIdController,
                            decoration: const InputDecoration(
                              labelText: 'Budget ID',
                              icon: Icon(Icons.book),
                            ),
                          ),
                          TextFormField(
                            controller: amtController,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              icon: Icon(Icons.account_circle),
                            ),
                          ),
                          TextFormField(
                            controller: investedController,
                            decoration: const InputDecoration(
                              labelText: 'Invested On',
                              icon: Icon(Icons.account_circle),
                            ),
                          ),

                          // ListTile(
                          //   title: Text('Due Date'),
                          //   subtitle: Text(
                          //       '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                          //   leading: IconButton(
                          //     icon: Icon(Icons.calendar_today),
                          //     onPressed: () {
                          //       _selectDate(context);
                          //     },
                          //   ),
                          // ),
                          // TextFormField(
                          //   controller: DueDateController,
                          //   decoration: InputDecoration(
                          //     labelText: 'Due Date',
                          //     icon: IconButton(icon:Icon(Icons.calendar_today), onPressed: () {_selectDate(context);},),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                );
              });
            },
            context: context);
        setState(() {});
        break;
      case 2:
        Navigator.pushNamed(context, '/BudgetDistributionPage');
        break;
      case 3:
        Navigator.pushNamed(context, '/TotalBudgetPage');
        break;
      case 4:
        Navigator.pushNamed(context, '/RemainingBudgetPage');
        break;
    }
  }

  var UsernameController = TextEditingController();
  var BookNameController = TextEditingController();
  var DueDateController = TextEditingController();

  String IssueDate =
      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
  DateTime selectedDate = DateTime.now();
  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (selected != null) {
      setState(() {
        selectedDate = selected;
      });
    }
    setState(() {});
  }

  Uint8List pickedFileByteStream = Uint8List.fromList([]);
  late Uint8List pickedFileByteStreamTn;
  late PlatformFile objFile;
  late PlatformFile objFileTn;
  ListView userListView(context) {
    return ListView(
      // Remove padding
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(widget.username),
          accountEmail: Text(widget.curStatus),
          currentAccountPicture: CircleAvatar(
            backgroundImage:
                AssetImage('assets/${widget.username[0].toLowerCase()}.png'),
            // backgroundImage: AssetImage('assets/a.png'),
            radius: 30,
          ),
          decoration: const BoxDecoration(
            color: Colors.blue,
          ),
        ),
        ListTile(
            leading: const Icon(Icons.book),
            title: const Text("My magazines"),
            onTap: () {
              Navigator.pushNamed(context, '/MyMagazine');
            }),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.add),
          title: const Text('Request Book'),
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  var bookNameController = TextEditingController();
                  var authorController = TextEditingController();
                  return StatefulBuilder(
                    builder: (BuildContext context,
                        void Function(void Function()) setState) {
                      return AlertDialog(
                        scrollable: true,
                        title: const Text('Create new book request'),
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  controller: bookNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Name',
                                    icon: Icon(Icons.drive_file_rename_outline),
                                  ),
                                ),
                                TextFormField(
                                  controller: authorController,
                                  decoration: const InputDecoration(
                                    labelText: 'Author',
                                    icon: Icon(Icons.account_box),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                              child: const Text("Submit"),
                              onPressed: () {
                                addBookRequest(
                                    widget.username,
                                    authorController.text,
                                    bookNameController.text);
                                Navigator.pop(context);
                              })
                        ],
                      );
                    },
                  );
                });
          },
        ),
        ListTile(
          leading: const Icon(Icons.add),
          title: const Text('Request Magazine'),
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  var bookNameController = TextEditingController();
                  var authorController = TextEditingController();
                  return StatefulBuilder(
                    builder: (BuildContext context,
                        void Function(void Function()) setState) {
                      return AlertDialog(
                        scrollable: true,
                        title: const Text('Create new magazine request'),
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  controller: bookNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Name',
                                    icon: Icon(Icons.drive_file_rename_outline),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                              child: const Text("Submit"),
                              onPressed: () {
                                addMagazineRequest(
                                    widget.username,
                                    authorController.text,
                                    bookNameController.text);
                                Navigator.pop(context);
                              })
                        ],
                      );
                    },
                  );
                });
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.book),
          title: const Text("Book Request status"),
          onTap: () {
            Navigator.pushNamed(context, '/BookRequestStatus');
          },
        ),
        ListTile(
            leading: const Icon(Icons.book),
            title: const Text("Magazine Request status"),
            onTap: () {
              Navigator.pushNamed(context, "/MagazineRequestStatus");
            }),
        ListTile(
            leading: const Icon(Icons.book),
            title: const Text("Borrowed Books"),
            onTap: () {
              Navigator.pushNamed(context, "/UserBorrowedBooks");
              // Navigator.push(context, MaterialPageRoute(builder: (context)=>UserBorrowedBooks()));
              // Navigator.push(context, MaterialPageRoute(builder: (context)=>UserBorrowedBooks()));
            }),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.password),
          title: const Text("Change Password"),
          onTap: () {
            showDialog(
                builder: (BuildContext context) {
                  return StatefulBuilder(builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    var oldPassController = TextEditingController();
                    var newPassController = TextEditingController();
                    var confirmPassController = TextEditingController();
                    return AlertDialog(
                      title: const Text('Change Password'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (newPassController.text !=
                                confirmPassController.text) {
                              showSnackbar(context,
                                  "New and Confirm passwords don't match");
                            } else {
                              changePasswordAPI(
                                  oldPassController, newPassController);
                            }
                          },
                          child: const Text('Change Password'),
                        ),
                      ],
                      scrollable: true,
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: oldPassController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Old Password',
                                  icon: Icon(Icons.password_rounded),
                                ),
                              ),
                              TextFormField(
                                controller: newPassController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'New Password',
                                  icon: Icon(Icons.fiber_new_rounded),
                                ),
                              ),
                              TextFormField(
                                controller: confirmPassController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Confirm Password',
                                  icon: Icon(Icons.new_label),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                },
                context: context);
            setState(() {});
          },
        ),
        ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove("Name");
              await prefs.remove("Id");
              await prefs.remove("Status");
              Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
            }),
      ],
    );
  }

  ListView adminListView(context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(widget.username),
          accountEmail: Text(widget.curStatus),
          currentAccountPicture: CircleAvatar(
            backgroundImage:
                AssetImage('assets/${widget.username[0].toLowerCase()}.png'),
            // backgroundImage: AssetImage('assets/a.png'),
            radius: 30,
          ),
          decoration: const BoxDecoration(
            color: Colors.blue,
          ),
        ),
        ListTile(
          leading: Icon(Icons.book),
          title: Text('Pending Book Requests'),
          onTap: () => Navigator.pushNamed(context, '/PendingBookRequests'),
        ),
        ListTile(
          leading: Icon(Icons.library_books),
          title: Text('Pending Magazine Requests'),
          onTap: () => Navigator.pushNamed(context, '/PendingMagazineRequests'),
        ),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add new book'),
          onTap: () {
            var bookNameController = TextEditingController();
            var authorController = TextEditingController();
            var isbnController = TextEditingController();
            var availController = TextEditingController();
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (BuildContext context,
                        void Function(void Function()) setState) {
                      return AlertDialog(
                        scrollable: true,
                        title: Text('Add Book'),
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  controller: bookNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Name',
                                    icon: Icon(Icons.drive_file_rename_outline),
                                  ),
                                ),
                                TextFormField(
                                  controller: isbnController,
                                  decoration: const InputDecoration(
                                    labelText: 'ISBN',
                                    icon: Icon(Icons.add),
                                  ),
                                ),
                                TextFormField(
                                  controller: authorController,
                                  decoration: const InputDecoration(
                                    labelText: 'Author',
                                    icon: Icon(Icons.account_box),
                                  ),
                                ),
                                TextFormField(
                                  controller: availController,
                                  decoration: InputDecoration(
                                    labelText: 'Availablity',
                                    icon: Icon(Icons.category),
                                  ),
                                ),
                                DropdownButton(
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
                                dropdownvalue == 'Online' ||
                                        dropdownvalue == 'Both'
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                            child: Text('Upload Pdf'),
                                            onPressed: () async {
                                              var result = await FilePicker
                                                  .platform
                                                  .pickFiles(
                                                type: FileType.custom,
                                                allowedExtensions: ['pdf'],
                                              );
                                              if (result != null) {
                                                Uint8List? fileBytes =
                                                    result.files.first.bytes;
                                                pickedFileByteStream =
                                                    (fileBytes)!;
                                                // var paths = result.files.first.path!;
                                                // var file = File(paths);
                                                // objFile =  result.files.single;
                                                // String toRet =  pickedFileByteStream.toString();
                                                // print('toRet $fileBytes');
                                              }
                                              if (pickedFileByteStream !=
                                                  null) {
                                                setState(() {});
                                              }
                                            }),
                                      )
                                    : SizedBox(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                      onPressed: () async {
                                        var result =
                                            await FilePicker.platform.pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: ['jpg'],
                                        );
                                        if (result != null) {
                                          Uint8List? fileBytes =
                                              await result.files.first.bytes;
                                          // objFileTn = result.files.single;
                                          pickedFileByteStreamTn = fileBytes!;
                                          String toRet =
                                              pickedFileByteStreamTn.toString();
                                        }
                                        if (pickedFileByteStreamTn != null) {
                                          setState(() {});
                                        }
                                      },
                                      child: Text('Upload Thumbnail')),
                                )
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                              child: Text("Submit"),
                              onPressed: () {
                                print(bookNameController.text);
                                // if (dropdownvalue == 'Online' || dropdownvalue == 'Both') {
                                //   showDialog(
                                //       context: context,
                                //       builder: (BuildContext context) {
                                //         return AlertDialog(
                                //           title: Text('Upload the pdf!'),
                                //           content: ElevatedButton(
                                //               onPressed: () {},
                                //               child: Text('Upload')),
                                //           actions: [
                                //             TextButton(
                                //               onPressed: () =>
                                //                   Navigator.pop(context),
                                //               child: Text('Cancel'),
                                //             ),
                                //             TextButton(
                                //               onPressed: () {
                                //                 Navigator.pop(context);
                                //               },
                                //               child: Text('Submit'),
                                //             ),
                                //           ],
                                //         );
                                //       });
                                // }
                                final channel =
                                    WebSocketChannel.connect(webSocket());
                                channel.sink.add(parser(packet(
                                    widget.id, Handler.Handler1, Add.BookRecord,
                                    bookName: bookNameController.text,
                                    isbn: isbnController.text,
                                    author: [authorController.text],
                                    availability:
                                        int.parse(availController.text),
                                    type: dropdownvalue == 'Online'
                                        ? Avail.Online
                                        : dropdownvalue == 'Offline'
                                            ? Avail.Offline
                                            : 3,
                                    book: pickedFileByteStream.toString(),
                                    thumbnail:
                                        pickedFileByteStreamTn.toString())));

                                // pickedFileByteStream.toString() -------- filestream for pdf
                                // pickedFileByteStreamTn.toString()  ----- filestream for thumbnail
                                Navigator.pop(context);
                              })
                        ],
                      );
                    },
                  );
                });
          },
        ),
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text('Delete Book'),
          onTap: () => {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  var ISBNController = TextEditingController();
                  return StatefulBuilder(builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return AlertDialog(
                      scrollable: true,
                      title: const Text('Delete Book'),
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: ISBNController,
                                decoration: const InputDecoration(
                                  labelText: 'ISBN',
                                  icon: Icon(Icons.book),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () async {
                              final channel =
                                  WebSocketChannel.connect(webSocket());
                              channel.sink.add(parser(packet(widget.id,
                                  Handler.Handler1, Remove.DeleteBook,
                                  isbn: ISBNController.text)));
                              channel.stream.listen((event) {
                                event = event.split(Header.Split)[1];
                                print(event);
                                channel.sink.close();
                                setState(() {});
                              });
                              Navigator.pop(context);
                            },
                            child: Text('Delete Book')),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                      ],
                    );
                  });
                })
          },
        ), //delete book
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Delete Book History'),
          onTap: () => {Navigator.pushNamed(context, '/History')},
        ),
        ListTile(
          leading: const Icon(Icons.add),
          title: const Text('Add new magazine'),
          onTap: () {
            DueDate =
                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  var journalController = TextEditingController();
                  var authorController = TextEditingController();
                  var volumeController = TextEditingController();
                  var releaseDateController = TextEditingController();
                  var issueController = TextEditingController();
                  Uint8List pickedFileMagByteStream = Uint8List.fromList([]);
                  return StatefulBuilder(
                    builder: (BuildContext context,
                        void Function(void Function()) setState) {
                      return AlertDialog(
                        scrollable: true,
                        title: const Text('Add Magazine'),
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  controller: journalController,
                                  decoration: const InputDecoration(
                                    labelText: 'Journal Name',
                                    icon: Icon(Icons.drive_file_rename_outline),
                                  ),
                                ),
                                TextFormField(
                                  controller: volumeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Volume',
                                    icon: Icon(Icons.add),
                                  ),
                                ),
                                TextFormField(
                                  controller: authorController,
                                  decoration: const InputDecoration(
                                    labelText: 'Author',
                                    icon: Icon(Icons.account_box),
                                  ),
                                ),
                                TextFormField(
                                  controller: DueDateController,
                                  decoration: InputDecoration(
                                    labelText: 'Published Date',
                                    icon: IconButton(
                                        icon: Icon(Icons.calendar_today),
                                        onPressed: () {
                                          _selectDate(context);
                                          DueDateController.text = DueDate;
                                        }),
                                  ),
                                ),
                                TextFormField(
                                  controller: issueController,
                                  decoration: const InputDecoration(
                                    labelText: 'Issue',
                                    icon: Icon(Icons.book_outlined),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                      onPressed: () async {
                                        var result =
                                            await FilePicker.platform.pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: ['pdf'],
                                        );
                                        if (result != null) {
                                          Uint8List? fileBytes =
                                              await result.files.first.bytes;
                                          // objFileTn = result.files.single;
                                          pickedFileMagByteStream = fileBytes!;
                                          String toRet = pickedFileMagByteStream
                                              .toString();
                                        }
                                        if (pickedFileMagByteStream != null) {
                                          setState(() {});
                                        }
                                      },
                                      child: Text('Upload Magazine!')),
                                )
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                              child: const Text("Submit"),
                              onPressed: () {
                                final channel =
                                    WebSocketChannel.connect(webSocket());
                                channel.sink.add(parser(packet(widget.id,
                                    Handler.Handler1, Add.MagazineRecord,
                                    bookName: journalController.text,
                                    author: [authorController.text],
                                    volume: volumeController.text,
                                    issue: issueController.text,
                                    misc: DueDateController.text)));
                                channel.stream.listen((event) {
                                  event = event.split(Header.Split)[1];
                                  event = jsonDecode(event);
                                  if (event["Header"] == Header.Success) {
                                    showSnackbar(context, "Magazine uploaded");
                                  } else {
                                    showSnackbar(context,
                                        "Upload failed try after sometime");
                                  }
                                });
                                Navigator.pop(context);
                              })
                        ],
                      );
                    },
                  );
                });
          },
        ),
        PopupMenuButton<int>(
          child: ListTile(
            leading: Icon(Icons.all_out),
            title: Text('Book Circulation'),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('New Book Borrowal'),
                  leading: CircleAvatar(
                    child: Icon(Icons.add),
                    radius: 30,
                  ),
                ),
              ),
              value: 0,
            ),
            PopupMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Outstanding Books'),
                  leading: CircleAvatar(
                    child: Icon(Icons.outbond),
                    radius: 30,
                  ),
                ),
              ),
              value: 1,
            ),
            // PopupMenuItem(
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: ListTile(
            //       title: Text('Post due!'),
            //       leading: CircleAvatar(
            //         child: Icon(Icons.warning),
            //         radius: 30,
            //       ),
            //     ),
            //   ),
            //   value: 2,
            // ),
          ],
          onSelected: (item) {
            selectedItemCirculation(context, item);
          },
        ),
        PopupMenuButton<int>(
          child: ListTile(
            leading: Icon(Icons.money),
            title: Text('Budget Allocation'),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Add Budget Details'),
                  leading: CircleAvatar(
                    child: Icon(Icons.add),
                    radius: 30,
                  ),
                ),
              ),
              value: 0,
            ),
            PopupMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Add Expenditure Details'),
                  leading: CircleAvatar(
                    child: Icon(Icons.outbond),
                    radius: 30,
                  ),
                ),
              ),
              value: 1,
            ),
            PopupMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Budget Distribution'),
                  leading: CircleAvatar(
                    child: Icon(Icons.outbond),
                    radius: 30,
                  ),
                ),
              ),
              value: 2,
            ),
            PopupMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Total Budget'),
                  leading: CircleAvatar(
                    child: Icon(Icons.all_inclusive),
                    radius: 30,
                  ),
                ),
              ),
              value: 3,
            ),
            PopupMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Remaining Budget'),
                  leading: CircleAvatar(
                    child: Icon(Icons.read_more),
                    radius: 30,
                  ),
                ),
              ),
              value: 4,
            ),
            // PopupMenuItem(
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: ListTile(
            //       title: Text('Post due!'),
            //       leading: CircleAvatar(
            //         child: Icon(Icons.warning),
            //         radius: 30,
            //       ),
            //     ),
            //   ),
            //   value: 2,
            // ),
          ],
          onSelected: (item) {
            selectedItemBudget(context, item);
          },
        ),
        Divider(),
        ListTile(
          leading: const Icon(Icons.password),
          title: const Text("Change Password"),
          onTap: () {
            showDialog(
                builder: (BuildContext context) {
                  return StatefulBuilder(builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    var oldPassController = TextEditingController();
                    var newPassController = TextEditingController();
                    var confirmPassController = TextEditingController();
                    return AlertDialog(
                      title: const Text('Change Password'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (newPassController.text !=
                                confirmPassController.text) {
                              showSnackbar(context,
                                  "New and Confirm passwords don't match");
                            } else {
                              changePasswordAPI(
                                  oldPassController, newPassController);
                            }
                          },
                          child: const Text('Change Password'),
                        ),
                      ],
                      scrollable: true,
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: oldPassController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Old Password',
                                  icon: Icon(Icons.password_rounded),
                                ),
                              ),
                              TextFormField(
                                controller: newPassController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'New Password',
                                  icon: Icon(Icons.fiber_new_rounded),
                                ),
                              ),
                              TextFormField(
                                controller: confirmPassController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Confirm Password',
                                  icon: Icon(Icons.new_label),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                },
                context: context);
            setState(() {});
          },
        ),
        ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove("Name");
              await prefs.remove("Id");
              await prefs.remove("Status");
              Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
            }),
      ],
    );
  }

  ListView superAdminListView(context) {
    late Uint8List pickedFileByteStream;
    late Uint8List pickedFileByteStreamTn;
    late PlatformFile objFile;
    late PlatformFile objFileTn;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(widget.username),
          accountEmail: Text(widget.curStatus),
          currentAccountPicture: CircleAvatar(
            backgroundImage:
                AssetImage('assets/${widget.username[0].toLowerCase()}.png'),
            // backgroundImage: AssetImage('assets/a.png'),
            radius: 30,
          ),
          decoration: const BoxDecoration(
            color: Colors.blue,
          ),
        ),
        ListTile(
          leading: Icon(Icons.book),
          title: Text('Pending Book Requests'),
          onTap: () => Navigator.pushNamed(context, '/PendingBookRequests'),
        ),
        ListTile(
          leading: Icon(Icons.library_books),
          title: Text('Pending Magazine Requests'),
          onTap: () => Navigator.pushNamed(context, '/PendingMagazineRequests'),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add new book'),
          onTap: () {
            var bookNameController = TextEditingController();
            var authorController = TextEditingController();
            var isbnController = TextEditingController();
            var availController = TextEditingController();
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (BuildContext context,
                        void Function(void Function()) setState) {
                      return AlertDialog(
                        scrollable: true,
                        title: Text('Add Book'),
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  controller: bookNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Name',
                                    icon: Icon(Icons.drive_file_rename_outline),
                                  ),
                                ),
                                TextFormField(
                                  controller: isbnController,
                                  decoration: const InputDecoration(
                                    labelText: 'ISBN',
                                    icon: Icon(Icons.add),
                                  ),
                                ),
                                TextFormField(
                                  controller: authorController,
                                  decoration: const InputDecoration(
                                    labelText: 'Author',
                                    icon: Icon(Icons.account_box),
                                  ),
                                ),
                                TextFormField(
                                  controller: availController,
                                  decoration: InputDecoration(
                                    labelText: 'Availablity',
                                    icon: Icon(Icons.category),
                                  ),
                                ),
                                DropdownButton(
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
                                dropdownvalue == 'Online' ||
                                        dropdownvalue == 'Both'
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                            child: Text('Upload Pdf'),
                                            onPressed: () async {
                                              var result = await FilePicker
                                                  .platform
                                                  .pickFiles(
                                                type: FileType.custom,
                                                allowedExtensions: ['pdf'],
                                              );
                                              if (result != null) {
                                                Uint8List? fileBytes =
                                                    result.files.first.bytes;
                                                pickedFileByteStream =
                                                    (fileBytes)!;
                                                // var paths = result.files.first.path!;
                                                // var file = File(paths);
                                                // objFile =  result.files.single;
                                                // String toRet =  pickedFileByteStream.toString();
                                                // print('toRet $fileBytes');
                                              }
                                              if (pickedFileByteStream !=
                                                  null) {
                                                setState(() {});
                                              }
                                            }),
                                      )
                                    : SizedBox(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                      onPressed: () async {
                                        var result =
                                            await FilePicker.platform.pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: ['jpg'],
                                        );
                                        if (result != null) {
                                          Uint8List? fileBytes =
                                              await result.files.first.bytes;
                                          // objFileTn = result.files.single;
                                          pickedFileByteStreamTn = fileBytes!;
                                          String toRet =
                                              pickedFileByteStreamTn.toString();
                                        }
                                        if (pickedFileByteStreamTn != null) {
                                          setState(() {});
                                        }
                                      },
                                      child: Text('Upload Thumbnail')),
                                )
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                              child: Text("Submit"),
                              onPressed: () {
                                print(bookNameController.text);
                                // if (dropdownvalue == 'Online' || dropdownvalue == 'Both') {
                                //   showDialog(
                                //       context: context,
                                //       builder: (BuildContext context) {
                                //         return AlertDialog(
                                //           title: Text('Upload the pdf!'),
                                //           content: ElevatedButton(
                                //               onPressed: () {},
                                //               child: Text('Upload')),
                                //           actions: [
                                //             TextButton(
                                //               onPressed: () =>
                                //                   Navigator.pop(context),
                                //               child: Text('Cancel'),
                                //             ),
                                //             TextButton(
                                //               onPressed: () {
                                //                 Navigator.pop(context);
                                //               },
                                //               child: Text('Submit'),
                                //             ),
                                //           ],
                                //         );
                                //       });
                                // }
                                final channel =
                                    WebSocketChannel.connect(webSocket());
                                channel.sink.add(parser(packet(
                                    widget.id, Handler.Handler1, Add.BookRecord,
                                    bookName: bookNameController.text,
                                    isbn: isbnController.text,
                                    author: [authorController.text],
                                    availability:
                                        int.parse(availController.text),
                                    type: dropdownvalue == 'Online'
                                        ? Avail.Online
                                        : dropdownvalue == 'Offline'
                                            ? Avail.Offline
                                            : 3,
                                    book: pickedFileByteStream.toString(),
                                    thumbnail:
                                        pickedFileByteStreamTn.toString())));

                                // pickedFileByteStream.toString() -------- filestream for pdf
                                // pickedFileByteStreamTn.toString()  ----- filestream for thumbnail
                                Navigator.pop(context);
                              })
                        ],
                      );
                    },
                  );
                });
          },
        ),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add new magazine'),
          onTap: () {
            DueDate =
                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  var journalController = TextEditingController();
                  var authorController = TextEditingController();
                  var volumeController = TextEditingController();
                  var releaseDateController = TextEditingController();
                  var issueController = TextEditingController();
                  Uint8List pickedFileMagByteStream = Uint8List.fromList([]);
                  return StatefulBuilder(
                    builder: (BuildContext context,
                        void Function(void Function()) setState) {
                      return AlertDialog(
                        scrollable: true,
                        title: Text('Add Magazine'),
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  controller: journalController,
                                  decoration: const InputDecoration(
                                    labelText: 'Journal Name',
                                    icon: Icon(Icons.drive_file_rename_outline),
                                  ),
                                ),
                                TextFormField(
                                  controller: volumeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Volume',
                                    icon: Icon(Icons.add),
                                  ),
                                ),
                                TextFormField(
                                  controller: authorController,
                                  decoration: const InputDecoration(
                                    labelText: 'Author',
                                    icon: Icon(Icons.account_box),
                                  ),
                                ),
                                TextFormField(
                                  controller: DueDateController,
                                  decoration: InputDecoration(
                                    labelText: 'Published Date',
                                    icon: IconButton(
                                        icon: Icon(Icons.calendar_today),
                                        onPressed: () {
                                          _selectDate(context);
                                          DueDateController.text = DueDate;
                                        }),
                                  ),
                                ),
                                TextFormField(
                                  controller: issueController,
                                  decoration: const InputDecoration(
                                    labelText: 'Issue',
                                    icon: Icon(Icons.book_outlined),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                      onPressed: () async {
                                        var result =
                                            await FilePicker.platform.pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: ['pdf'],
                                        );
                                        if (result != null) {
                                          Uint8List? fileBytes =
                                              await result.files.first.bytes;
                                          // objFileTn = result.files.single;
                                          pickedFileMagByteStream = fileBytes!;
                                          String toRet = pickedFileMagByteStream
                                              .toString();
                                        }
                                        if (pickedFileMagByteStream != null) {
                                          setState(() {});
                                        }
                                      },
                                      child: Text('Upload Magazine!')),
                                )
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                              child: const Text("Submit"),
                              onPressed: () {
                                final channel =
                                    WebSocketChannel.connect(webSocket());
                                channel.sink.add(parser(packet(widget.id,
                                    Handler.Handler1, Add.MagazineRecord,
                                    bookName: journalController.text,
                                    author: [authorController.text],
                                    volume: volumeController.text,
                                    issue: issueController.text,
                                    misc: DueDateController.text)));
                                channel.stream.listen((event) {
                                  event = event.split(Header.Split)[1];
                                  event = jsonDecode(event);
                                  if (event["Header"] == Header.Success) {
                                    showSnackbar(context, "Magazine uploaded");
                                  } else {
                                    showSnackbar(context,
                                        "Upload failed try after sometime");
                                  }
                                });
                                Navigator.pop(context);
                              })
                        ],
                      );
                    },
                  );
                });
          },
        ),
        Divider(),
        PopupMenuButton<int>(
          child: ListTile(
            leading: Icon(Icons.all_out),
            title: Text('Book Circulation'),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('New Book Borrowal'),
                  leading: CircleAvatar(
                    child: Icon(Icons.add),
                    radius: 30,
                  ),
                ),
              ),
              value: 0,
            ),
            PopupMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Outstanding Books'),
                  leading: CircleAvatar(
                    child: Icon(Icons.outbond),
                    radius: 30,
                  ),
                ),
              ),
              value: 1,
            ),
            // PopupMenuItem(
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: ListTile(
            //       title: Text('Post due!'),
            //       leading: CircleAvatar(
            //         child: Icon(Icons.warning),
            //         radius: 30,
            //       ),
            //     ),
            //   ),
            //   value: 2,
            // ),
          ],
          onSelected: (item) {
            selectedItemCirculation(context, item);
          },
        ),
        PopupMenuButton<int>(
          child: ListTile(
            leading: Icon(Icons.money),
            title: Text('Budget Allocation'),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Add Budget Details'),
                  leading: CircleAvatar(
                    child: Icon(Icons.add),
                    radius: 30,
                  ),
                ),
              ),
              value: 0,
            ),
            PopupMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Add Expenditure Details'),
                  leading: CircleAvatar(
                    child: Icon(Icons.outbond),
                    radius: 30,
                  ),
                ),
              ),
              value: 1,
            ),
            PopupMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Budget Distribution'),
                  leading: CircleAvatar(
                    child: Icon(Icons.outbond),
                    radius: 30,
                  ),
                ),
              ),
              value: 2,
            ),
            PopupMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Total Budget'),
                  leading: CircleAvatar(
                    child: Icon(Icons.all_inclusive),
                    radius: 30,
                  ),
                ),
              ),
              value: 3,
            ),
            PopupMenuItem(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Remaining Budget'),
                  leading: CircleAvatar(
                    child: Icon(Icons.read_more),
                    radius: 30,
                  ),
                ),
              ),
              value: 4,
            ),
            // PopupMenuItem(
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: ListTile(
            //       title: Text('Post due!'),
            //       leading: CircleAvatar(
            //         child: Icon(Icons.warning),
            //         radius: 30,
            //       ),
            //     ),
            //   ),
            //   value: 2,
            // ),
          ],
          onSelected: (item) {
            selectedItemBudget(context, item);
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text('Add User'),
          onTap: () => {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  String userPrevilege = 'User';
                  // List<DropdownMenuItem> items = [DropdownMenuItem(child: Text('User')),DropdownMenuItem(child: Text('Admin'))];
                  var items = [
                    'User',
                    'Admin',
                  ];
                  var usernameController = TextEditingController();
                  var passwordController = TextEditingController();
                  return StatefulBuilder(builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return AlertDialog(
                      scrollable: true,
                      title: const Text('Add User'),
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: usernameController,
                                decoration: const InputDecoration(
                                  labelText: 'User Name',
                                  icon: Icon(Icons.drive_file_rename_outline),
                                ),
                              ),
                              TextFormField(
                                controller: passwordController,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                  icon: Icon(Icons.password),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DropdownButton(
                                  // Initial Value
                                  value: userPrevilege,
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
                                      userPrevilege = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            if (userPrevilege == 'Admin') {
                              final channel =
                                  WebSocketChannel.connect(webSocket());
                              channel.sink.add(parser(packet(
                                  widget.id, Handler.Handler1, Create.Admin,
                                  username: usernameController.text.toString(),
                                  password: sha512
                                      .convert(utf8.encode(
                                          passwordController.text.toString()))
                                      .toString())));
                              channel.stream.listen((event) {
                                event = event.split(Header.Split)[1];
                                var out = jsonDecode(event);
                                if (out["Header"] == Header.Success) {
                                  showSnackbar(context, "User Created");
                                } else {
                                  showSnackbar(
                                      context, "Unable to create user");
                                }
                                channel.sink.close();
                              });
                            } else {
                              final channel =
                                  WebSocketChannel.connect(webSocket());
                              channel.sink.add(parser(packet(
                                  widget.id, Handler.Handler1, Create.User,
                                  username: usernameController.text.toString(),
                                  password: sha512
                                      .convert(utf8.encode(
                                          passwordController.text.toString()))
                                      .toString())));
                              channel.stream.listen((event) {
                                event = event.split(Header.Split)[1];
                                var out = jsonDecode(event);
                                if (out["Header"] == Header.Success) {
                                  showSnackbar(context, "User Created");
                                } else {
                                  showSnackbar(
                                      context, "Unable to create user");
                                }
                                channel.sink.close();
                              });
                            }
                            Navigator.pop(context);
                          },
                          child: Text('Create new user'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                      ],
                    );
                  });
                })
          },
        ),
        ListTile(
          leading: Icon(Icons.account_circle),
          title: const Text('Delete User'),
          onTap: () => {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  String userPrevilege = 'User';
                  var usernameController = TextEditingController();
                  return StatefulBuilder(builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return AlertDialog(
                      scrollable: true,
                      title: const Text('Delete User'),
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: usernameController,
                                decoration: const InputDecoration(
                                  labelText: 'User Name',
                                  icon: Icon(Icons.drive_file_rename_outline),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () async{
                              final channel = WebSocketChannel.connect(webSocket());
                              channel.sink.add(parser(
                                  packet(widget.id, Handler.Handler1, Remove.UserRecord,username: UsernameController.text)));
                              channel.stream.listen((event) {
                                event = event.split(Header.Split)[1];
                                channel.sink.close();
                                setState(() {});
                              });

                              Navigator.pop(context);

                            },
                            child: Text('Delete User')),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                      ],
                    );
                  });
                })
          },
        ),
        ListTile(
          leading: Icon(Icons.account_circle),
          title: Text('Edit User'),
          onTap: () => {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  String userPrevilege = 'User';
                  // List<DropdownMenuItem> items = [DropdownMenuItem(child: Text('User')),DropdownMenuItem(child: Text('Admin'))];
                  var items = [
                    'User',
                    'Admin',
                  ];
                  var usernameController = TextEditingController();
                  return StatefulBuilder(builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return AlertDialog(
                      scrollable: true,
                      title: const Text('Edit User'),
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: usernameController,
                                decoration: const InputDecoration(
                                  labelText: 'User Name',
                                  icon: Icon(Icons.drive_file_rename_outline),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DropdownButton(
                                  // Initial Value
                                  value: userPrevilege,
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
                                      userPrevilege = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                            onPressed: () {
                              final channel = WebSocketChannel.connect(webSocket());
                              if(userPrevilege == "User"){
                                channel.sink.add(parser(
                                    packet(widget.id, Handler.Handler1, Update.UserStatus,username: usernameController.text,status: Privileges.User.toString())));
                              }
                              else{
                                channel.sink.add(parser(
                                    packet(widget.id, Handler.Handler1, Update.UserStatus,username: usernameController.text,status: Privileges.Admin.toString())));
                              }

                              channel.stream.listen((event) {
                                event = event.split(Header.Split)[1];
                                channel.sink.close();
                                setState(() {});
                              });

                              Navigator.pop(context);
                            },
                            child: const Text('Edit User')),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ],
                    );
                  });
                })
          },
        ),
        Divider(),
        ListTile(
          leading: const Icon(Icons.password),
          title: const Text("Change Password"),
          onTap: () {
            showDialog(
                builder: (BuildContext context) {
                  return StatefulBuilder(builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    var oldPassController = TextEditingController();
                    var newPassController = TextEditingController();
                    var confirmPassController = TextEditingController();
                    return AlertDialog(
                      title: const Text('Change Password'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (newPassController.text !=
                                confirmPassController.text) {
                              showSnackbar(context,
                                  "New and Confirm passwords don't match");
                            } else {
                              changePasswordAPI(
                                  oldPassController, newPassController);
                            }
                          },
                          child: const Text('Change Password'),
                        ),
                      ],
                      scrollable: true,
                      content: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: oldPassController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Old Password',
                                  icon: Icon(Icons.password_rounded),
                                ),
                              ),
                              TextFormField(
                                controller: newPassController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'New Password',
                                  icon: Icon(Icons.fiber_new_rounded),
                                ),
                              ),
                              TextFormField(
                                controller: confirmPassController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'Confirm Password',
                                  icon: Icon(Icons.new_label),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
                },
                context: context);
            setState(() {});
          },
        ),
        ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove("Name");
              await prefs.remove("Id");
              await prefs.remove("Status");
              Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
            }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: widget.curStatus == UserStat.User
          ? userListView(context)
          : widget.curStatus == UserStat.SuperAdmin
              ? superAdminListView(context)
              : adminListView(context),
    );
  }
}
