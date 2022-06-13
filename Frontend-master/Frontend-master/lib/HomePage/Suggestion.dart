import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants.dart';

class Suggestions extends StatefulWidget {
  const Suggestions({Key? key}) : super(key: key);

  @override
  State<Suggestions> createState() => _SuggestionsState();
}

class _SuggestionsState extends State<Suggestions> {
  String curStatus = Privileges.User.toString();
  String username = "";
  String id = "";
  int status = 0;
  bool loaded = false;

  @override
  void initState() {
    GetState();
    super.initState();
  }

  Future<bool> GetState() async {
    final prefs = await SharedPreferences.getInstance();
    id = prefs.getString("Id")!;
    username = prefs.getString("Name")!;
    status = prefs.getInt("Status")!;
    loaded = true;
    setState(() {});
    if (status & Privileges.SuperAdmin == Privileges.SuperAdmin) {
      curStatus = UserStat.SuperAdmin;
    } else if (status & Privileges.Admin == Privileges.Admin) {
      curStatus = UserStat.Admin;
    } else {
      curStatus = UserStat.User;
    }
    return true;
  }

  Future<dynamic> GetSuggetions()async{

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: FutureBuilder(builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      if(snapshot.connectionState == ConnectionState.done){
        return Container();
      }
      else{
        return const CircularProgressIndicator();
      }

    },future: GetState(),),);
  }
}
