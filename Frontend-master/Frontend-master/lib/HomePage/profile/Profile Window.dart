import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileWindow extends StatelessWidget {
  const ProfileWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String username = "";
    void GetState() async {
      final prefs = await SharedPreferences.getInstance();
      username=prefs.getString("Id")!;
    }
    GetState();

    var controller1 = TextEditingController();
    controller1.text = username;
    return Scaffold(
      body:Center(
        child: SizedBox(
          width: 600,
          child: Column(
            children: [Row(children: [const Text("Name: "),TextField(enabled: false,controller: controller1,)],)],
          ),
        ),
      ),
    );
  }
}
