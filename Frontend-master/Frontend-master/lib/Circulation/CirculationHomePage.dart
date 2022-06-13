import 'package:flutter/material.dart';
import 'package:library_management/Constants.dart';

class circulationHomePage extends StatefulWidget {
  const circulationHomePage({Key? key}) : super(key: key);

  @override
  State<circulationHomePage> createState() => _circulationHomePageState();
}

class _circulationHomePageState extends State<circulationHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Circulation Control'),
      ),
      body: Container(
        child: Column(
              children: [
            CustomCard(title: 'New Borrowal',button: TextButton(child:Text('Enter'),onPressed: (){},),)
],
        ),
      ),
    );
  }
}

class CustomCard extends StatefulWidget {
  String title;
  Widget button;
  CustomCard({required this.title,required this.button});


  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 200,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Padding(
            padding: const EdgeInsets.all(8.0),
            child: Title(color: Colors.black, child: Text(widget.title),),
          ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.button,
            )
          ],
        ),
      ),
    );
  }
}
