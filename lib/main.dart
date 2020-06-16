import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hello/login_info.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import './pages/tflite.dart';
import 'pages/SocketIO/socketio.dart';
import 'pages/SocketIO/recentchat_info.dart';
import 'pages/RestAPI/restapi.dart';

List<CameraDescription> cameras;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginInfo()),
        ChangeNotifierProvider(create: (context) => RecentChatInfo()),
      ],
      child: MaterialApp(
          title: "LoyalRoader Demo",
          theme: ThemeData(primaryColor: Colors.greenAccent),
          home: MyHome(cameras: cameras)),
    );
  }
}

class MyHome extends StatefulWidget {
  MyHome({Key key, this.title, this.cameras}) : super(key: key);
  // This widget is the root of your application.

  final String title;
  final List<CameraDescription> cameras;

  @override
  MyTabsState createState() => MyTabsState();
}

class MyTabsState extends State<MyHome> with SingleTickerProviderStateMixin {
  static TabController controller;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginInfo>(
      builder: (context, loginInfo, child) {
        if (loginInfo.token == "") {
          return Scaffold(
            body: Center(
              child: Container(
                padding: EdgeInsets.all(80.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Login',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Username',
                      ),
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'Password',
                      ),
                      obscureText: true,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: RaisedButton(
                        color: Colors.yellow,
                        child: Text('ENTER'),
                        onPressed: () {
                          fetchLoginInfo().then((value) => loginInfo.login(
                              value.token, value.id, value.key));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(title: Text('Feature Demo')),
            body: TabBarView(
              controller: controller,
              children: <Widget>[
                RestApi(),
                SocketIO(),
                TfliteExample(
                  cameras: cameras,
                )
              ],
            ),
            bottomNavigationBar: Container(
              child: TabBar(controller: controller, tabs: [
                Tab(
                  icon: Icon(Icons.group),
                  text: '친구',
                ),
                Tab(icon: Icon(Icons.chat_bubble), text: '채팅'),
                Tab(icon: Icon(Icons.table_chart), text: 'TFLite'),
              ]),
              color: Theme.of(context).primaryColor,
            ),
          );
        }
      },
    );
  }

  Future<LoginInfoModel> fetchLoginInfo() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    var requestsBody = json.encode({'id': username, 'pass': password});
    const String BASE_URL = 'http://15.164.167.20:5000';
    final response = await http.post(BASE_URL + '/login',
        headers: {'Content-Type': 'application/json'}, body: requestsBody);
    if (response.statusCode == 200) {
      return LoginInfoModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load LoginInfo');
    }
  }
}
