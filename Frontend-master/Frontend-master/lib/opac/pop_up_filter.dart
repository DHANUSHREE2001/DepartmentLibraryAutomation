import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class placeHolder extends StatelessWidget {
  String username;
  placeHolder({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
      ),
      body: Container(
        child: Text(username),
      ),
    );
  }
}

class popUpFilterButton extends StatefulWidget {
  @override
  _popUpFilterButtonState createState() => _popUpFilterButtonState();
}

class _popUpFilterButtonState extends State<popUpFilterButton> {
  bool bookNameCheckbox = false;
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
  var filteritems=[
    'ASC','DESC'
  ];
  void selectedItem(BuildContext context, int item) {
    switch (item) {
      case 0:
        print('Author');
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => placeHolder(username:"temp" )));

        setState(() {});
        break;
      case 1:
        print('ISBN');
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => placeHolder(username:"temp" )));
        setState(() {});
        break;
      case 2:
        print('logout');
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => placeHolder(username:"temp" )));
        // Navigator.pop(context);
        break;
    }
  }

  Widget build(BuildContext context)  {
    return PopupMenuButton<int>(
        child: Padding(
          padding: EdgeInsets.only(right: 4),
          child: Icon(
            Icons.filter_alt,
          ),
        ),
        itemBuilder: (context) =>  [
          PopupMenuItem(
            child: StatefulBuilder(
              builder: (BuildContext context, void Function(void Function()) setState) {

                return Column(
                children: [
                  Row(
                    children:  [
                      Icon(
                        Icons.library_books,
                        color: Colors.blue,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Type'),
                      SizedBox(
                        width: 75,
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
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownvalue = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.article_outlined,
                        color: Colors.blue,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Order'),
                      SizedBox(
                        width: 85,
                      ),
                      DropdownButton(
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
                      )
                    ],
                  ),
                  dropdownvalue == 'Books'?Row(
                    children:  [
                      Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Author'),
                      SizedBox(
                        width: 75,
                      ),
                      Checkbox(
                        value: this.bookAuthorCheckbox,
                        onChanged: (bool? value) {
                          setState(() {
                            this.bookAuthorCheckbox = value!;
                          });
                        },
                      ),
                    ],
                  ):Row(
                    children:  [
                      Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Author'),
                      SizedBox(
                        width: 75,
                      ),
                      Checkbox(
                        value: this.magAuthorCheckbox,
                        onChanged: (bool? value) {
                          setState(() {
                            this.magAuthorCheckbox = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  dropdownvalue == 'Books'?Row(
                    children:  [
                      Icon(
                        Icons.assignment_outlined,
                        color: Colors.blue,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Title'),
                      SizedBox(
                        width: 89,
                      ),
                      Checkbox(
                        value: this.bookNameCheckbox,
                        onChanged: (bool? value) {
                          setState(() {
                            this.bookNameCheckbox = value!;
                          });
                        },
                      ),

                    ],
                  ):Row(
                    children:  [
                      Icon(
                        Icons.assignment_outlined,
                        color: Colors.blue,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Title'),
                      SizedBox(
                        width: 89,
                      ),
                      Checkbox(
                        value: this.magNameCheckbox,
                        onChanged: (bool? value) {
                          setState(() {
                            this.magNameCheckbox = value!;
                          });
                        },
                      ),

                    ],
                  ),
                  dropdownvalue == 'Books'?Row(
                    children: [
                      const Icon(
                        Icons.article_outlined,
                        color: Colors.blue,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('ISBN'),
                      SizedBox(
                        width: 85,
                      ),
                      Checkbox(
                        value: this.bookISBNCheckbox,
                        onChanged: (bool? value) {
                          setState(() {
                            Icon(
                              Icons.assignment_outlined,
                              color: Colors.blue,
                            );
                            this.bookISBNCheckbox = value!;
                          });
                        },
                      ),
                    ],
                  ):SizedBox(),
                ],
              ); },
            ),
            value: 1,
          ),
          // PopupMenuItem(
          //   child: Row(
          //     children: [
          //       Icon(
          //         Icons.article_outlined,
          //         color: Colors.blue,
          //       ),
          //       SizedBox(
          //         width: 10,
          //       ),
          //       Text('Order'),
          //       SizedBox(
          //         width: 85,
          //       ),
          //       DropdownButton(
          //         // Initial Value
          //         value: dropdownvaluefilter,
          //
          //         // Down Arrow Icon
          //         icon: const Icon(Icons.keyboard_arrow_down),
          //
          //         // Array list of items
          //         items: filteritems.map((String items) {
          //           return DropdownMenuItem(
          //             value: items,
          //             child: Text(items),
          //           );
          //         }).toList(),
          //         // After selecting the desired option,it will
          //         // change button value to selected value
          //         onChanged: (String? newValue) {
          //           setState(() {
          //             dropdownvaluefilter = newValue!;
          //           });
          //         },
          //       )
          //     ],
          //   ),
          //   value: 2,
          // ),
          // dropdownvalue == 'Books'?PopupMenuItem(
          //   child: Row(
          //     children:  [
          //       Icon(
          //         Icons.person,
          //         color: Colors.blue,
          //       ),
          //       SizedBox(
          //         width: 10,
          //       ),
          //       Text('Author'),
          //       SizedBox(
          //         width: 75,
          //       ),
          //       Checkbox(
          //         value: this.bookAuthorCheckbox,
          //         onChanged: (bool? value) {
          //           setState(() {
          //             this.bookAuthorCheckbox = value!;
          //           });
          //         },
          //       ),
          //     ],
          //   ),
          //   value: 1,
          // ):PopupMenuItem(
          //   child: Row(
          //     children:  [
          //       Icon(
          //         Icons.person,
          //         color: Colors.blue,
          //       ),
          //       SizedBox(
          //         width: 10,
          //       ),
          //       Text('Author'),
          //       SizedBox(
          //         width: 75,
          //       ),
          //       Checkbox(
          //         value: this.magAuthorCheckbox,
          //         onChanged: (bool? value) {
          //           setState(() {
          //             this.magAuthorCheckbox = value!;
          //           });
          //         },
          //       ),
          //     ],
          //   ),
          //   value: 1,
          // ),
          // dropdownvalue == 'Books'?PopupMenuItem(
          //   child: Row(
          //     children:  [
          //       Icon(
          //         Icons.assignment_outlined,
          //         color: Colors.blue,
          //       ),
          //       SizedBox(
          //         width: 10,
          //       ),
          //       Text('Title'),
          //       SizedBox(
          //         width: 89,
          //       ),
          //       Checkbox(
          //         value: this.bookNameCheckbox,
          //         onChanged: (bool? value) {
          //           setState(() {
          //             this.bookNameCheckbox = value!;
          //           });
          //         },
          //       ),
          //
          //     ],
          //   ),
          //   value: 3,
          // ):PopupMenuItem(
          //   child: Row(
          //     children:  [
          //       Icon(
          //         Icons.assignment_outlined,
          //         color: Colors.blue,
          //       ),
          //       SizedBox(
          //         width: 10,
          //       ),
          //       Text('Title'),
          //       SizedBox(
          //         width: 89,
          //       ),
          //       Checkbox(
          //         value: this.magNameCheckbox,
          //         onChanged: (bool? value) {
          //           setState(() {
          //             this.magNameCheckbox = value!;
          //           });
          //         },
          //       ),
          //
          //     ],
          //   ),
          //   value: 3,
          // ),
          // dropdownvalue == 'Books'?PopupMenuItem(
          //   child: Row(
          //     children: [
          //       Icon(
          //         Icons.article_outlined,
          //         color: Colors.blue,
          //       ),
          //       SizedBox(
          //         width: 10,
          //       ),
          //       Text('ISBN'),
          //       SizedBox(
          //         width: 85,
          //       ),
          //       Checkbox(
          //         value: this.bookISBNCheckbox,
          //         onChanged: (bool? value) {
          //           setState(() {
          //             Icon(
          //               Icons.assignment_outlined,
          //               color: Colors.blue,
          //             );
          //             this.bookISBNCheckbox = value!;
          //           });
          //         },
          //       ),
          //     ],
          //   ),
          //   value: 2,
          // ):PopupMenuItem(child: SizedBox()),

        ]
    );
  }
}

