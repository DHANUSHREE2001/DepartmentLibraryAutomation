import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:library_management/Constants.dart';
import 'package:library_management/Network.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var username = TextEditingController();
  var password = TextEditingController();

  void fin(out) async {
    final prefs = await SharedPreferences.getInstance();
    if (out["Header"] == Header.Success) {
      Navigator.pushNamed(context, "/Home");
      await prefs.setString("Name", username.text.toString());
      await prefs.setString("Id", out["Data"]);
      await prefs.setInt("Status", out['Misc']);
    } else if (out["Header"] == Header.Failed) {
      _asyncConfirmDialog(context);
    }
    username.text="";
    password.text="";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("lib/Login/bg.jpg"), fit: BoxFit.fitHeight)),
        height: double.infinity,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: Container(
                width: 400,
                height: 250,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey.shade300,
                    boxShadow: const [
                      BoxShadow(
                          offset: Offset(10, 10),
                          color: Colors.black,
                          blurRadius: 20)
                    ]),
                child: SizedBox(
                  width: 400,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            decoration:
                            const InputDecoration(labelText: "Username"),
                            controller: username,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: password,
                            obscureText: true,
                            decoration:
                            const InputDecoration(labelText: "Password"),
                            onSubmitted: (str) async {
                              var data = packet(
                                  "", Handler.Handler1, Header.Login,
                                  username: username.text.toString(),
                                  password: sha512
                                      .convert(utf8.encode(password.text))
                                      .toString());
                              communicate(data, fin);
                            },
                          ),
                        ),
                        Center(
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  var data = packet(
                                      "", Handler.Handler1, Header.Login,
                                      username: username.text.toString(),
                                      password: sha512
                                          .convert(utf8.encode(password.text))
                                          .toString());
                                  communicate(data, fin);
                                },
                                child: const Text("Login"),
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  // Widget build(BuildContext context) {
  //   return WillPopScope(
  //     onWillPop: () async {
  //       return false;
  //     },
  //     child: Scaffold(
  //       body: Container(
  //         decoration: const BoxDecoration(
  //             image: DecorationImage(
  //                 image: AssetImage("lib/Login/bg.jpg"), fit: BoxFit.fitHeight)),
  //         height: double.infinity,
  //         child: Center(
  //           child: Padding(
  //             padding: const EdgeInsets.all(10.0),
  //             child: Center(
  //               child: Container(
  //                 width: 400,
  //                 height: 250,
  //                 alignment: Alignment.center,
  //                 decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(16),
  //                     color: Colors.grey.shade300,
  //                     boxShadow: const [
  //                       BoxShadow(
  //                           offset: Offset(10, 10),
  //                           color: Colors.black,
  //                           blurRadius: 20)
  //                     ]),
  //                 child: SizedBox(
  //                   width: 400,
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(20.0),
  //                     child: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       crossAxisAlignment: CrossAxisAlignment.center,
  //                       children: [
  //                         Padding(
  //                           padding: const EdgeInsets.all(10.0),
  //                           child: TextField(
  //                             decoration:
  //                                 const InputDecoration(labelText: "Username"),
  //                             controller: username,
  //                           ),
  //                         ),
  //                         Padding(
  //                           padding: const EdgeInsets.all(10.0),
  //                           child: TextField(
  //                             controller: password,
  //                             obscureText: true,
  //                             decoration:
  //                                 const InputDecoration(labelText: "Password"),
  //                             onSubmitted: (str) async {
  //                               var data = packet(
  //                                   "", Handler.Handler1, Header.Login,
  //                                   username: username.text.toString(),
  //                                   password: sha512
  //                                       .convert(utf8.encode(password.text))
  //                                       .toString());
  //                               communicate(data, fin);
  //                             },
  //                           ),
  //                         ),
  //                         Center(
  //                           child: Padding(
  //                               padding: const EdgeInsets.all(10.0),
  //                               child: ElevatedButton(
  //                                 onPressed: () async {
  //                                   var data = packet(
  //                                       "", Handler.Handler1, Header.Login,
  //                                       username: username.text.toString(),
  //                                       password: sha512
  //                                           .convert(utf8.encode(password.text))
  //                                           .toString());
  //                                   communicate(data, fin);
  //                                 },
  //                                 child: const Text("Login"),
  //                               )),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

Future<void> _asyncConfirmDialog(BuildContext context) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Invalid Credentials'),
        content: const Text('Check your username and password.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}

AppBar appBar() {
  return AppBar(
    title: const Text("Library management system"),
    elevation: 0,
  );
}
