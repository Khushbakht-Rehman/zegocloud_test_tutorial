import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:zegocloud_tutorial_test/home_page.dart';
import 'package:zegocloud_tutorial_test/utils/permission.dart';

import 'key_center.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userIDTextCtrl = TextEditingController(text: Random().nextInt(100000).toString());
  final userNameTextCtrl = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState

    userNameTextCtrl.text = "user_${userIDTextCtrl.text}";

    requestPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: Column(
        children: [
          TextFormField(
            controller: userIDTextCtrl,
            decoration: InputDecoration(label: Text("Your User ID")),
          ),
          TextFormField(
            controller: userNameTextCtrl,
            decoration: InputDecoration(label: Text("Your User Name")),
          ),
          ElevatedButton(
            onPressed: () async {
              await createEngine();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage(
                          localUserID: userIDTextCtrl.text,
                          localUserName: userNameTextCtrl.text)));
            },
            child: Text("Login"),
          ),
        ],
      ),
    );
  }

  Future<void> createEngine() async {
    WidgetsFlutterBinding.ensureInitialized();
    // Get your AppID and AppSign from ZEGOCLOUD Console
    //[My Projects -> AppID] : https://console.zegocloud.com/project
    await ZegoExpressEngine.createEngineWithProfile(ZegoEngineProfile(
      appID,
      ZegoScenario.Default,
      appSign: kIsWeb ? null : appSign,
    ));
  }
}
