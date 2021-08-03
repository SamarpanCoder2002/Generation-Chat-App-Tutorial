import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'chatAndActivityScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int _currIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: WillPopScope(
        onWillPop: () async {
          if (_currIndex > 0)
            return false;
          else {
            return true;
          }
        },
        child: Scaffold(
          backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
          appBar: AppBar(
            brightness: Brightness.dark,
            backgroundColor: const Color.fromRGBO(25, 39, 52, 1),
            elevation: 10.0,
            shadowColor: Colors.white70,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40.0),
                bottomRight: Radius.circular(40.0),
              ),
              side: BorderSide(width: 0.7),
            ),
            title: Text(
              "Generation",
              style: TextStyle(
                  fontSize: 25.0, fontFamily: 'Lora', letterSpacing: 1.0),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: Icon(
                  Icons.search_outlined,
                  size: 25.0,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  right: 20.0,
                ),
                child: IconButton(
                  tooltip: 'Refresh',
                  icon: Icon(
                    Icons.refresh_outlined,
                    size: 25.0,
                  ),
                  onPressed: () async {},
                ),
              ),
            ],
            bottom: _bottom(),
          ),
          body: TabBarView(
            children: [
              ChatAndActivityScreen(),
              Center(),
              Center(),
            ],
          ),
        ),
      ),
    );
  }

  TabBar _bottom() {
    return TabBar(
      indicatorPadding: EdgeInsets.only(left: 20.0, right: 20.0),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white60,
      indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 2.0, color: Colors.lightBlue),
          insets: EdgeInsets.symmetric(horizontal: 15.0)),
      automaticIndicatorColorAdjustment: true,
      labelStyle: TextStyle(
        fontFamily: 'Lora',
        fontWeight: FontWeight.w500,
        letterSpacing: 1.0,
      ),
      onTap: (index) {
        print("\nIndex is: $index");
        if (mounted) {
          setState(() {
            _currIndex = index;
          });
        }
      },
      tabs: [
        Tab(
          child: Text(
            "Chats",
            style: TextStyle(
              fontSize: 20.0,
              fontFamily: 'Lora',
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Tab(
          child: Text(
            "Logs",
            style: TextStyle(
              fontSize: 20.0,
              fontFamily: 'Lora',
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Tab(
          icon: Icon(
            Icons.store,
            size: 25.0,
          ),
        ),
      ],
    );
  }
}
