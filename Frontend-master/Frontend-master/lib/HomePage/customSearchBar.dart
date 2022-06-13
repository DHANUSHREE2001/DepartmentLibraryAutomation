import 'package:flutter/material.dart';
class customSearchBar extends StatefulWidget {
  const customSearchBar({Key? key}) : super(key: key);

  @override
  _customSearchBarState createState() => _customSearchBarState();
}

class _customSearchBarState extends State<customSearchBar> {
  TextEditingController _textcontroller = TextEditingController();
  bool _secureText = true;
  String _errMsg="";
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width/2,
      child: Card(
        child: TextField(
          controller: _textcontroller,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: "Search here...",
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
            border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 2,
                  style: BorderStyle.solid,
                )
            ),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 1,
                  style: BorderStyle.solid,
                )
            ),
            prefixIcon: IconButton(
              icon: Icon(
                  Icons.search),
              onPressed: () {
              },
            ),
            // icon: Icon(Icons.weekend_sharp) ,
            suffixIcon: IconButton(
              icon: Icon(
                  Icons.filter_alt),
              onPressed: () {},
            ),
          ),

        ),
      ),
    );
  }
}
