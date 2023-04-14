import 'package:flutter/material.dart';
import 'package:zegocloud_tutorial_test/utils/permission.dart';

import 'call_page.dart';

class HomePage extends StatefulWidget {
  final String localUserID;
  final String localUserName;

   HomePage({Key? key,required this.localUserID,required this.localUserName}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

final roomTextCtrl=TextEditingController();

@override
  void initState() {
    // TODO: implement initState
  requestPermission();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Page"),
      ),
      body: Column(
         children: [
           Text("Your ID ${widget.localUserID}"),
           Text("Your UserName ${widget.localUserName}"),

           TextFormField(controller: roomTextCtrl,
             decoration: InputDecoration(label: Text("Room ID"),),),

           ElevatedButton(onPressed: (){
             print("hello");
             Navigator.pushReplacement(
                 context,
                 MaterialPageRoute(
                     builder: (context) => CallPage(
                       localUserID: widget.localUserID,
                         localUserName: widget.localUserName,
                       roomID: roomTextCtrl.text,
                         )));


           }, child: Text("Call Page"),),
         ],
        ),

    );
  }
}
