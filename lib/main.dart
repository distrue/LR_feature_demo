import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import './pages/tflite.dart';
import './pages/socketio.dart';
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
    return MaterialApp(
      title: "LoyalRoader Demo",
      theme: ThemeData(
        primaryColor: Colors.greenAccent
      ),
      home: MyHome(cameras: cameras)
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
    return Scaffold(
      appBar: AppBar(title: Text('Feature Demo')),
      body: TabBarView(
        controller: controller,
        children: <Widget>[TfliteExample(cameras: cameras,), SocketIO(), RestApi()],
      ),
      bottomNavigationBar: Container(
        child: TabBar(
          controller: controller,
          tabs: [
            Tab(icon: Icon(Icons.table_chart), text: 'TFLiteExample'),
            Tab(icon: Icon(Icons.donut_small), text: 'socketio',),
            Tab(icon: Icon(Icons.cloud), text: 'restApi'),
          ]
        ),
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}