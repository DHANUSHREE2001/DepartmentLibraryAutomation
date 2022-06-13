import 'package:flutter/material.dart';
import 'package:library_management/HomePage/News/news.dart';
import 'package:library_management/HomePage/GlobalSearchBar.dart';
import 'package:library_management/Navbar/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:library_management/Constants.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String curStatus;
  String username="";
  String id="";
  int status = 0;
  bool loaded=false;

  @override
  void initState() {
    GetState();
    super.initState();
  }


  void GetState() async {
    final prefs = await SharedPreferences.getInstance();
    id = prefs.getString("Id")!;
    username=prefs.getString("Name")!;
    status = prefs.getInt("Status")!;
    loaded=true;
    setState(() {});
    if (status & Privileges.SuperAdmin == Privileges.SuperAdmin) {
      curStatus = UserStat.SuperAdmin;
    } else if (status & Privileges.Admin == Privileges.Admin) {
      curStatus = UserStat.Admin;
    } else {
      curStatus = UserStat.User;
    }
  }


  @override
  Widget build(BuildContext context) {
    return !loaded ? const Scaffold(body: Center(child: CircularProgressIndicator())) : DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        drawer: NavBar(
          id: id,
          curStatus: curStatus,
          username: username,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            TabBarView(
              children: [Container(
                decoration: const BoxDecoration(
                  image:DecorationImage(
                      image: AssetImage('assets/background.png'),
                      fit: BoxFit.cover
                  ),
                ),
                child:Container() ,), news(id: id)],
            ),
          ],
        ),
        // body: TabBarView(
        //   children: [Container(), news(id: id)],
        // ),
        appBar: AppBar(
          title: Row(
            children: const [
              Text('Libria '),
              // exampleTextField(),3
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home_filled), text: "Home"),
              Tab(
                  icon: Icon(
                    Icons.feed_outlined,
                  ),
                  text: "News")
            ],
          ),
        ),
        floatingActionButton: Center(
            child: SizedBox(width: 500, child: SearchBar(id))),
        floatingActionButtonLocation:
        FloatingActionButtonLocation.miniCenterDocked,
      ),
    );
  }
}

