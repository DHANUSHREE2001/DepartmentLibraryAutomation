import 'package:flutter/material.dart';

class addBookPage extends StatefulWidget {
  const addBookPage({Key? key}) : super(key: key);

  @override
  State<addBookPage> createState() => _addBookPageState();
}

class _addBookPageState extends State<addBookPage> {
  var bookNameController = TextEditingController();
  var authorController = TextEditingController();
  var isbnController = TextEditingController();
  var availController = TextEditingController();
  String dropdownvalue = 'Offline';
  var items = [
    'Online',
    'Offline',
    'Both',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add new Book'),
      ),
      body: Container(
        child: Form(
          child: Column(
            children: <Widget>[
              TextFormField(
                controller :bookNameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  icon: Icon(Icons.drive_file_rename_outline),
                ),
              ),
              TextFormField(
                controller :isbnController,
                decoration: InputDecoration(
                  labelText: 'ISBN',
                  icon: Icon(Icons.add),
                ),
              ),
              TextFormField(
                controller :authorController,
                decoration: InputDecoration(
                  labelText: 'Author',
                  icon: Icon(Icons.account_box ),
                ),
              ),
              TextFormField(
                controller :availController,
                decoration: InputDecoration(
                  labelText: 'Availablity',
                  icon: Icon(Icons.category),
                ),
              ),
              // CheckboxListTile(
              //   title: Text('Online : '),
              //   value: online_avail,
              //   onChanged: (value) {
              //     setState(() {
              //       online_avail = value!;
              //     });
              //     setState(() {});
              //   },
              // ),
              // CheckboxListTile(
              //   title: Text('Offline : '),
              //   value: offline_avail,
              //   onChanged: (value) {
              //     setState(() {
              //       print(1);
              //       offline_avail = value!;
              //     });},
              // ),
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
              dropdownvalue=='Online'||dropdownvalue=='Both'?ElevatedButton(onPressed: (){}, child: Text('Upload')):SizedBox(),
              TextButton(
                  child: Text("Submit"),
                  onPressed: () {
                    if(dropdownvalue=='Online' || dropdownvalue=='Both')
                    {
                      showDialog(context: context, builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Upload the pdf!'),
                          content: ElevatedButton(onPressed: (){}, child: Text('Upload')),
                          actions: [TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);},
                              child: Text('Submit'),
                            ),],
                        );
                      });

                    }

                    Navigator.pop(context);
                  })
            ],
          ),
        ),

      ),
    );;
  }
}
